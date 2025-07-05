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
		cru a amtm_ScriptsUpdateNotification "10 5 * * Sun /bin/sh ${add}/sc_update.mod -run"
		show_amtm " Scripts update notification installed\\n or updated."
	elif [ "$1" = manage ]; then
		[ -f "${add}/sc_update.cfg" ] && . "${add}/sc_update.cfg" || scChkFreq=Sunday
		p_e_l
		printf " Scripts update notification options\\n\\n The update check runs ${GN}$scChkFreq @ 05:10${NC}\\n\\n"
		printf " 1. Change update check frequency\\n 2. Send a test notification email\\n 3. Remove scripts update notification script\\n"

		while true; do
			printf "\\n Enter selection [1-3 e=Exit] ";read -r continue
			case "$continue" in
				1)		check_email_conf
						p_e_l
						printf " This sets the day(s) the notification checks\\n for updates.\\n Current setting: ${GN}$scChkFreq @ 05:10${NC}\\n\\n"
						printf " Day                   Twice a week\\n"
						printf " ------------    OR    --------------------------\\n"
						printf " 1. Monday             91. Monday & Thursday\\n"
						printf " 2. Tuesday            92. Tuesday & Friday\\n"
						printf " 3. Wednesday          93. Wednesday & Saturday\\n"
						printf " 4. Thursday           94. Thursday & Sunday\\n"
						printf " 5. Friday             95. Friday & Monday\\n"
						printf " 6. Saturday           96. Saturday & Tuesday\\n"
						printf " 7. Sunday             97. Sunday & Wednesday\\n"
						printf " 8. Check daily\\n"
						while true; do
							printf "\\n Select update day(s): [1-8 OR 91-97 e=Exit] ";read -r input
							case "$input" in
								1)		scChkFreq=Monday;scChkDOW=Mon;break;;
								2)		scChkFreq=Tuesday;scChkDOW=Tue;break;;
								3)		scChkFreq=Wednesday;scChkDOW=Wed;break;;
								4)		scChkFreq=Thursday;scChkDOW=Thu;break;;
								5)		scChkFreq=Friday;scChkDOW=Fri;break;;
								6)		scChkFreq=Saturday;scChkDOW=Sat;break;;
								7)		scChkFreq=Sunday;scChkDOW=Sun;break;;
								8)		scChkFreq=Daily;scChkDOW=*;break;;
								91)		scChkFreq="Monday & Thursday";scChkDOW="Mon,Thu";break;;
								92)		scChkFreq="Tuesday & Friday";scChkDOW="Tue,Fri";break;;
								93)		scChkFreq="Wednesday & Saturday";scChkDOW="Wed,Sat";break;;
								94)		scChkFreq="Thursday & Sunday";scChkDOW="Thu,Sun";break;;
								95)		scChkFreq="Friday & Monday";scChkDOW="Fri,Mon";break;;
								96)		scChkFreq="Saturday & Tuesday";scChkDOW="Sat,Tue";break;;
								97)		scChkFreq="Sunday & Wednesday";scChkDOW="Sun,Wed";break;;
								[Ee]) 	show_amtm menu;;
								*) 	printf "\\n input is not an option\\n";;
							esac
						done
						printf "scChkFreq=\"$scChkFreq\"\\nscChkDOW=\"$scChkDOW\"" > "${add}"/sc_update.cfg
						/bin/sh "${add}"/sc_update.mod -set
						show_amtm " Scripts update notification frequency\\n set to $scChkFreq"
						break;;
				2)		check_email_conf
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
				3)		p_e_l
						printf " This removes the scripts update notification\\n script.\\n"
						c_d
						cru d amtm_ScriptsUpdateNotification
						sed -i "\~sc_update.mod ~d" /jffs/scripts/services-start
						r_w_e /jffs/scripts/services-start
						rm -f ${add}/sc_update.cfg
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
	-set) 	[ -f /jffs/addons/amtm/sc_update.cfg ] && . /jffs/addons/amtm/sc_update.cfg || scChkDOW=Sun
			cru a amtm_ScriptsUpdateNotification "10 5 * * $scChkDOW /bin/sh /jffs/addons/amtm/sc_update.mod -run";;
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

				/usr/sbin/curl --url $PROTOCOL://$SMTP:$PORT/$SMTP \
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
