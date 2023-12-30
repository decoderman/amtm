#!/bin/sh
#bof
fw_update_installed(){
	[ -z "$su" ] && atii=1
	if ! grep -qE "^VERSION=$fw_version" /jffs/scripts/update-notification 2> /dev/null; then
		write_fw_update_file
		a_m " - Firmware update notification script updated to v$fw_version"
	fi
	[ -z "$su" ] && printf "${GN_BG} fw${NC} %-9s%-19s%${COR}s\\n" "manage" "Firmware update notification"
	case_fw(){
		[ -f "${add}"/fw_update.mod ] && fw_update manage
		show_amtm menu
	}
}
install_fw_update(){
	p_e_l
	printf " This installs the Firmware update notification script\\n on this router.\\n\\n Receive email notification for newer\\n"
	printf " Asuswrt-Merlin firmware availability for this\\n router within hours of release.\\n\\n Author: thelonelycoder\\n"
	p_e_l;while true;do printf " Continue? [1=Yes e=Exit] ";read -r continue;case "$continue" in 1)echo;break;;[Ee])am=;r_m fw_update.mod;show_amtm menu;break;;*)printf "\\n input is not an option\\n\\n";;esac done
	fw_update install
}
fw_update(){
	if [ "$1" = install ]; then
		if [ "$(v_c $(nvram get buildno))" -ge "$(v_c 380.65)" ]; then
			isEligible=
			if [ -f /www/Advanced_FirmwareUpgrade_Content.asp ] && grep -q 'asuswrt-merlin.net/download' /www/Advanced_FirmwareUpgrade_Content.asp; then
				isEligible=1
			fi
			if [ "$(nvram get firmware_server)" = "https://fwupdate.lostrealm.ca/asuswrt-merlin" ] || [ "$(nvram get firmware_server)" = "https://fwupdate.asuswrt-merlin.net" ] || [ "$isEligible" = 1 ]; then
				if [ "$(nvram get firmware_check_enable)" = "1" ]; then
					do_install(){
						check_email_conf
						write_fw_update_file
						[ -f /jffs/scripts/update-notification ] && show_amtm " Firmware update notification installed" || show_amtm " Firmware update notification install failed"
					}
					if [ -f "/jffs/scripts/update-notification" ]; then
						if grep -wq '^#bof' /jffs/scripts/update-notification || grep -wq '^# Script created by amtm' /jffs/scripts/update-notification; then
							do_install
						else
							printf " Found a custom notification script at:\\n ${GREEN}/jffs/scripts/update-notification${NC}\\n"
							printf " This needs to be removed first.\\n"
							while true; do
								printf "\\n Remove the file? [1=Yes 2=No] ";read -r confirm
								case "$confirm" in
									1)	rm -f /jffs/scripts/update-notification
										do_install
										break;;
									2)	show_amtm " Exited update notification install";break;;
									*)	printf "\\n input is not an option\\n";;
								esac
							done
						fi
					else
						do_install
					fi
				else
					echo " New firmware version check is not enabled,"
					echo " you must enable it first:"
					echo
					echo " In the router WebUI, go to Administration / Firmware Upgrade"
					echo " and set 'Scheduled check for new firmware availability' to 'Yes'"
					echo
					echo " Or for older firmware versions:"
					echo " In the router Web UI, go to Tools / Other Settings"
					echo " and set 'New firmware version check' to 'Yes'"
					echo " then click 'Apply'"
					p_e_t "return to acknowledge"
					show_amtm
				fi
			else
				echo " Your firmware does not support Asuswrt-Merlin"
				echo " update notification"
				p_e_t "return to acknowledge"
				show_amtm
			fi
		else
			echo " Your firmware ($(nvram get buildno)) does not support"
			echo " update notification. This feature was introduced"
			echo " in Asuswrt-Merlin 380.65."
			p_e_t "return to acknowledge"
			show_amtm
		fi
	elif [ "$1" = manage ]; then
		p_e_l
		printf " Firmware update notification options\\n\\n"
		printf " 1. Send a test notification email\\n 2. Remove firmware notification script\\n"

		while true; do
			printf "\\n Enter selection [1-2 e=Exit] ";read -r continue
			case "$continue" in
				1)		check_email_conf
						/jffs/scripts/update-notification test
						if [ "$?" = "0" ]; then
							echo "${NC}"
							. /jffs/addons/amtm/mail/email.conf
							show_amtm " Firmware notification test email sent\\n to $TO_NAME at $TO_ADDRESS"
						else
							echo "${NC}"
							echo "${NOK} sending test notification failed"
							echo
							echo " Note the curl: error above and check your settings"
							echo
							p_e_t "return to menu"
							show_amtm
						fi
						break;;
				2)		p_e_l
						printf " This removes the Firmware update notification\\n script.\\n"
						c_d
						rm -f "${add}"/fw_update.mod
						rm -f /jffs/scripts/update-notification
						show_amtm " Firmware update notification script removed"
						break;;
				[Ee])	show_amtm menu;;
				*)		printf "\\n input is not an option\\n";;
			esac
		done
	fi
}

write_fw_update_file(){
	cat <<-EOF > /jffs/scripts/update-notification
	#!/bin/sh
	# This is an amtm script that sends a notification
	# email when a new firmware version is available for this router.
	# Script created by amtm $version

	VERSION=$fw_version

	if [ -f ${EMAIL_DIR}/email.conf ]; then
	    . ${EMAIL_DIR}/email.conf

	    TEMPVERS=\$(nvram get webs_state_info)

	    if [ "\$(echo "\$(nvram get buildno)" | grep "380.65")" ]; then
	        STABLEVERS=\${TEMPVERS:5:3}.\${TEMPVERS:8:10}
	    else
	        if echo \$TEMPVERS | grep -q 3004_; then
	            STABLEVERS=\$(echo \$TEMPVERS | sed 's/3004_//')
	        else
	            STABLEVERS=\$TEMPVERS
	        fi
	    fi

	    FROM_NAME="amtm Router Firmware notification"
	    [ -z "\$(nvram get odmpid)" ] && routerModel=\$(nvram get productid) || routerModel=\$(nvram get odmpid)
	    [ -z "\$FRIENDLY_ROUTER_NAME" ] && FRIENDLY_ROUTER_NAME=\$routerModel

	    echo "From: \"\$FROM_NAME\" <\$FROM_ADDRESS>" >/tmp/amtm-mail-body
	    echo "To: \"\$TO_NAME\" <\$TO_ADDRESS>" >>/tmp/amtm-mail-body
	    echo "Subject: \$FRIENDLY_ROUTER_NAME Router Asuswrt-Merlin new firmware notification" >>/tmp/amtm-mail-body
	    echo "Date: \$(date -R)" >>/tmp/amtm-mail-body
	    echo >>/tmp/amtm-mail-body
	    echo "Hey there!" >>/tmp/amtm-mail-body
	    echo >>/tmp/amtm-mail-body
	    if [ "\$1" = test ]; then
	        echo "Note that this is a firmware update notification test, the output below may not be correct." >>/tmp/amtm-mail-body
	        echo >>/tmp/amtm-mail-body
	    fi
	    echo "A new stable Asuswrt-Merlin firmware is available for your \$FRIENDLY_ROUTER_NAME router at \$(nvram get lan_ipaddr)." >>/tmp/amtm-mail-body
	    echo >>/tmp/amtm-mail-body
	    echo "Installed version: \$(nvram get buildno)_\$(nvram get extendno)" >>/tmp/amtm-mail-body
	    echo >>/tmp/amtm-mail-body
	    echo "Latest available stable version: \$STABLEVERS" >>/tmp/amtm-mail-body
	    echo >>/tmp/amtm-mail-body
	    echo "See the Asuswrt-Merlin changelog for what's new:" >>/tmp/amtm-mail-body
	    echo "https://asuswrt-merlin.net/changelog" >>/tmp/amtm-mail-body
	    echo >>/tmp/amtm-mail-body
	    echo "Downloads are available at: https://asuswrt-merlin.net/download" >>/tmp/amtm-mail-body
	    echo >>/tmp/amtm-mail-body
	    echo "Very truly yours," >>/tmp/amtm-mail-body
	    echo "Your \$FRIENDLY_ROUTER_NAME router (Model type \$routerModel)" >>/tmp/amtm-mail-body
	    echo >>/tmp/amtm-mail-body

	    /usr/sbin/curl --url \$PROTOCOL://\$SMTP:\$PORT \\
	    --mail-from "\$FROM_ADDRESS" --mail-rcpt "\$TO_ADDRESS" \\
	    --upload-file /tmp/amtm-mail-body \\
	    --ssl-reqd \\
	    --crlf \\
	    --user "\$USERNAME:\$(/usr/sbin/openssl aes-256-cbc \$emailPwEnc -d -in /jffs/addons/amtm/mail/emailpw.enc -pass pass:ditbabot,isoi)" \$SSL_FLAG

	    if [ "\$?" = "0" ]; then
	        logger -t amtm "sent firmware notification"
	    else
	        logger -t amtm "was unable to send firmware notification, check settings"
	    fi
	    rm -f /tmp/amtm-mail*
	else
	    logger -t amtm "was unable to send firmware notification, email.conf not found"
	fi

	EOF

	[ ! -x /jffs/scripts/update-notification ] && chmod 0755 /jffs/scripts/update-notification
}

#eof
