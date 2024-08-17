#!/bin/sh
#bof
fw_update_installed(){
	[ -z "$su" ] && atii=1
	if ! grep -qE "^VERSION=$fw_version" /jffs/scripts/update-notification 2> /dev/null; then
		write_fw_update_file
		a_m " - Firmware update notification script updated to v$fw_version"
	fi
	[ -z "$su" -a -z "$ss" ] && printf "${GN_BG} fw${NC} %-9s%-19s%${COR}s\\n" "manage" "Firmware update notification"
	case_fw(){
		[ -f "${add}"/fw_update.mod ] && fw_update manage
		show_amtm menu
	}
}
install_fw_update(){
	check_email_conf fw_update.mod
	p_e_l
	printf " This installs the Firmware update notification script\\n on this router.\\n\\n Receive email notification for newer\\n"
	printf " Asuswrt-Merlin firmware availability for this\\n router within hours of release.\\n\\n Author: thelonelycoder\\n"
	c_d fw_update.mod
	fw_update install
}
fw_update(){
	rm_fw_files(){
		r_m fw_update.mod
		rm -f /jffs/scripts/update-notification
		am=
	}

	if [ "$1" = install ]; then
		if [ "$(v_c $(nvram get buildno))" -ge "$(v_c 380.65)" -o "$(v_c $(nvram get firmver))" -ge "$(v_c 3.0.0.6)" ]; then
			isEligible=
			if [ -f /www/Advanced_FirmwareUpgrade_Content.asp ] && grep -q 'asuswrt-merlin.net/download' /www/Advanced_FirmwareUpgrade_Content.asp; then
				isEligible=1
			fi
			if [ "$(nvram get firmware_server)" = "https://fwupdate.lostrealm.ca/asuswrt-merlin" ] || [ "$(nvram get firmware_server)" = "https://fwupdate.asuswrt-merlin.net" ] || [ "$isEligible" = 1 ]; then
				if [ "$(nvram get firmware_check_enable)" = "1" ]; then
					do_install(){
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
									2)	rm_fw_files;show_amtm " Exited update notification install";break;;
									*)	printf "\\n input is not an option\\n";;
								esac
							done
						fi
					else
						do_install
					fi
				else
					printf " New firmware version check is not enabled,\\n you must enable it first:\\n\\n In the router WebUI, go to Administration / Firmware Upgrade\\n"
					printf " and set 'Scheduled check for new firmware availability' to 'Yes'\\n\\n Or for older firmware versions:\\n In the router Web UI, go to Tools / Other Settings\\n"
					printf " and set 'New firmware version check' to 'Yes'\\n then click 'Apply'\\n"
					p_e_t "return to acknowledge"
					rm_fw_files
					show_amtm " Cannot install firmware version check"
				fi
			else
				printf " Your firmware does not support Asuswrt-Merlin\\n update notification\\n"
				p_e_t "return to acknowledge"
				rm_fw_files
				show_amtm " Cannot install firmware version check"
			fi
		else
			printf " Your firmware ($(nvram get buildno)) does not\\n support update notification. This feature was\\n introduced in Asuswrt-Merlin 380.65.\\n"
			p_e_t "return to acknowledge"
			rm_fw_files
			show_amtm " Cannot install firmware version check"
		fi
	elif [ "$1" = manage ]; then
		p_e_l
		printf " Firmware update notification options\\n\\n"
		printf " 1. Send a test notification email\\n 2. Remove firmware notification script\\n"

		while true; do
			printf "\\n Enter selection [1-2 e=Exit] ";read -r continue
			case "$continue" in
				1)		check_email_conf
						echo
						/jffs/scripts/update-notification test
						if [ $? = 0 ]; then
							echo "${NC}"
							. /jffs/addons/amtm/mail/email.conf
							show_amtm " Firmware notification test sent to\\n $TO_NAME at $TO_ADDRESS"
						else
							printf "${NC} sending test notification failed\\n Note the curl: error above and check your settings\\n"
							p_e_t "return to menu"
							show_amtm
						fi
						break;;
				2)		p_e_l
						printf " This removes the Firmware update notification\\n script.\\n"
						c_d
						rm_fw_files
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

	    /usr/sbin/curl --url \$PROTOCOL://\$SMTP:\$PORT/\$SMTP \\
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
