#!/bin/sh
#bof
sc_update_installed(){
	[ -z "$su" ] && atii=1
	if ! grep -q "^/bin/sh ${add}/sc_update.mod" /jffs/scripts/services-start 2> /dev/null; then
		sc_update install
	fi
	[ -z "$su"  -a -z "$ss" ] && printf "${GN_BG} sc${NC} %-9s%-19s%${COR}s\\n" "manage" "Scripts update notification"
	case_sc(){
		[ -f "${add}"/sc_update.mod ] && sc_update manage
		show_amtm menu
	}
}
install_sc_update(){
	check_email_conf sc_update.mod
	p_e_l
	printf " This installs scripts update notification\\n on this router.\\n\\n Receive email notification when updates\\n"
	printf " are available for installed scripts.\\n\\n Author: thelonelycoder\\n"
	c_d sc_update.mod
	sc_update install
}
sc_update(){
	if [ "$1" = install ]; then
		c_j_s /jffs/scripts/services-start
		if ! grep -q "^/bin/sh ${add}/sc_update.mod" /jffs/scripts/services-start; then
			sed -i "\~sc_update.mod ~d" /jffs/scripts/services-start
			echo "/bin/sh ${add}/sc_update.mod -set # Added by amtm" >> /jffs/scripts/services-start
		fi
		cru a amtm_ScriptsUpdateNotification "10 7 * * Sun /bin/sh ${add}/sc_update.mod -run"
		show_amtm " Scripts update notification installed\\n or updated"
	elif [ "$1" = manage ]; then
		p_e_l
		printf " Scripts update notification options\\n\\n The update check runs every Sunday at 07:10\\n\\n"
		printf " 1. Send a test notification email\\n 2. Remove scripts update notification script\\n"

		while true; do
			printf "\\n Enter selection [1-2 e=Exit] ";read -r continue
			case "$continue" in
				1)		check_email_conf
						touch /tmp/amtmtest
						/bin/sh ${add}/sc_update.mod -run
						if [ "$?" = "0" ]; then
							echo "${NC}"
							. /jffs/addons/amtm/mail/email.conf
							show_amtm " Scripts update notification test sent to\\n $TO_NAME at $TO_ADDRESS"
						else
							printf "${NC} sending test notification failed\\n Note the curl: error above and check your settings\\n"
							p_e_t "return to menu"
							show_amtm
						fi
						break;;
				2)		p_e_l
						printf " This removes the scripts update notification\\n script.\\n"
						c_d
						cru d amtm_ScriptsUpdateNotification
						sed -i "\~sc_update.mod ~d" /jffs/scripts/services-start
						r_w_e /jffs/scripts/services-start
						rm -f ${add}/sc_update.mod
						show_amtm " Scripts update notification removed"
						break;;
				[Ee])	show_amtm menu;;
				*)		printf "\\n input is not an option\\n";;
			esac
		done
	fi
}

case "${1}" in
	"") 	;;
	-set) 	cru a amtm_ScriptsUpdateNotification "10 7 * * Sun /bin/sh /jffs/addons/amtm/sc_update.mod -run";;
	-run) 	EMAIL_DIR=/jffs/addons/amtm/mail
			if [ -f $EMAIL_DIR/email.conf ]; then
				. $EMAIL_DIR/email.conf

				[ -z "$(nvram get odmpid)" ] && routerModel=$(nvram get productid) || routerModel=$(nvram get odmpid)
				[ -z "$FRIENDLY_ROUTER_NAME" ] && FRIENDLY_ROUTER_NAME=$routerModel

				rm_temp_files(){ rm -f /tmp/amtm-* /tmp/amtmtest;}

				rm -f /tmp/amtm-*
				touch /tmp/amtm-no-delete
				amtm updcheck

				if [ -s /tmp/amtm-tpu-check ]; then
					if grep -q 'No script updates available' /tmp/amtm-tpu-check; then
						haveUpd=
					else
						haveUpd=1
						sed -i 's/^Available /Available amtm /' /tmp/amtm-tpu-check
					fi
				else
					logger -t amtm "unable to check for scripts update, unknown error"
					exit 1
				fi
			else
				logger -t amtm "unable to send scripts update notification, email.conf not found"
				exit 1
			fi

			if [ "$haveUpd" ] || [ -f /tmp/amtmtest ]; then
				FROM_NAME="amtm scripts update notification"
				echo "From: \"$FROM_NAME\" <$FROM_ADDRESS>" >/tmp/amtm-mail-body
				echo "To: \"$TO_NAME\" <$TO_ADDRESS>" >>/tmp/amtm-mail-body
				echo "Subject: $FRIENDLY_ROUTER_NAME Router amtm scripts update notification" >>/tmp/amtm-mail-body
				echo "Date: $(date -R)" >>/tmp/amtm-mail-body
				echo >>/tmp/amtm-mail-body
				echo "Hey there!" >>/tmp/amtm-mail-body
				echo >>/tmp/amtm-mail-body
				cat /tmp/amtm-tpu-check >>/tmp/amtm-mail-body
				echo >>/tmp/amtm-mail-body
				echo "Very truly yours," >>/tmp/amtm-mail-body
				echo "Your $FRIENDLY_ROUTER_NAME router (Model type $routerModel)" >>/tmp/amtm-mail-body
				echo >>/tmp/amtm-mail-body

				/usr/sbin/curl --url $PROTOCOL://$SMTP:$PORT \
					--mail-from "$FROM_ADDRESS" --mail-rcpt "$TO_ADDRESS" \
					--upload-file /tmp/amtm-mail-body \
					--ssl-reqd \
					--crlf \
					--user "$USERNAME:$(/usr/sbin/openssl aes-256-cbc $emailPwEnc -d -in $EMAIL_DIR/emailpw.enc -pass pass:ditbabot,isoi)" $SSL_FLAG

				if [ "$?" = "0" ]; then
					rm_temp_files
					logger -t amtm "sent scripts update notification"
					return 0
				else
					rm_temp_files
					logger -t amtm "was unable to send scripts update notification, check settings"
					return 1
				fi
			else
				logger -t amtm "scripts update check, no updates available"
				rm_temp_files
			fi
			;;
esac
#eof
