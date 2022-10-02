#!/bin/sh
#bof
EMAIL_DIR=/jffs/addons/amtm/mail
email_installed(){
	atii=1

	emMan=setup
	[ -f "${EMAIL_DIR}"/emailpw.enc ] && emMan=open
	[ -z "$su" ] && printf "${GN_BG} em${NC} %-9s%-19s\\n" "$emMan" "email settings"
	case_em(){
		email_manage
		show_amtm menu
	}
}
install_email(){
	p_e_l
	echo " This sets up email settings"
	echo " on your router."
	echo
	echo " These settings are used by multiple third"
	echo " party scripts, including Diversion (if installed)."
	echo
	echo " Author: thelonelycoder"
	echo " https://www.snbforums.com/forums/asuswrt-merlin-addons.60/?prefix_id=16&starter_id=25480"
	c_d

	g_m email.mod include
	if [ -f "${add}/email.mod" ]; then
		email_manage
	else
		am=;show_amtm " email settings installation failed"
	fi
}
email_manage(){
	p_e_l
	if [ -f "${EMAIL_DIR}/email.conf" ]; then
		. "${EMAIL_DIR}/email.conf"
		prevEmailPwEnc=$emailPwEnc
	fi
	/usr/sbin/openssl version | awk '$2 ~ /(^0\.)|(^1\.(0\.|1\.0))/ { exit 1 }' && emailPwEnc=-pbkdf2 || emailPwEnc=
	if [ -f "${EMAIL_DIR}/email.conf" ] && [ "$prevEmailPwEnc" != "$emailPwEnc" ]; then
		sed -i "/emailPwEnc/d" "${EMAIL_DIR}/email.conf"
		echo "emailPwEnc=$emailPwEnc" >> "${EMAIL_DIR}/email.conf"
	fi

	notice_email_settings(){
		echo " If you have Two Factor Authentication (2FA)"
		echo " enabled, use an App password, or get a new email"
		echo " address without 2FA (not recommended)."
		echo
		echo " Common SMTP Server settings"
		echo " Provider    Server                 Port Protocol"
		echo " ------------------------------------------------"
		echo " Gmail       smtp.gmail.com         465  smtps"
		echo " mail.com    smtp.mail.com          587  smtp"
		echo " Yahoo!      smtp.mail.yahoo.com    465  smtps"
		echo " outlook.com smtp-mail.outlook.com  587  smtp"
	}
	writePW=
	if [ ! -f "${EMAIL_DIR}/email.conf" ]; then
		echo " You need to first set your email settings"
		echo
		echo " Example settings:"
		echo "${R_BG} From address    ${NC} e.g. \"john.doe@gmail.com\""
		echo "${R_BG} To name         ${NC} e.g. \"John Doe\""
		echo "${R_BG} To address (1)  ${NC} e.g. \"kate.austen@lost.com\""
		echo "${R_BG} Router name (2) ${NC} e.g. \"Fishing-Cabin\""
		echo "${R_BG} User name       ${NC} e.g. \"john.doe@gmail.com\""
		echo "${R_BG} Password (3)    ${NC} e.g. \"Sup3rPa##w0rd\""
		echo "${R_BG} SMTP Server     ${NC} e.g. \"smtp.gmail.com\""
		echo "${R_BG} Server port     ${NC} e.g. \"465\""
		echo "${R_BG} Protocol (4)    ${NC} e.g. \"smtps\""
		echo "${R_BG} SSL flag (5)    ${NC} e.g. \"--insecure\""
		echo
		echo " (1) To address can be your email or another"
		echo "     email address."
		echo " (2) This friendly router name may only contain"
		echo "     alphanumeric, - and _ characters. No spaces"
		echo "     and not more than 16 characters. The word"
		echo "     \"Router\" is auto-added after the name."
		echo " (3) Password may NOT contain \" character."
		echo " (4) smtps works for most, outlook.com may need smtp."
		echo " (5) some servers may require the --insecure flag."
		echo
		notice_email_settings
		p_e_l
		echo " You are about to enter your email credentials."
		echo " If you make a mistake, fill in all fields anyway."
		echo
		echo " The Edit function is available afterwards."
		echo " Caution: Password is in clear text."
		echo
		c_d
		printf "\\n${R_BG} Enter From address: ${NC} ";read -r FROM_ADDRESS
		printf "\\n${R_BG} Enter To name: ${NC} ";read -r TO_NAME
		printf "\\n${R_BG} Enter To address: ${NC} ";read -r TO_ADDRESS
		printf "\\n${R_BG} Enter friendly router name: ${NC} ";read -r FRIENDLY_ROUTER_NAME
		printf "\\n${R_BG} Enter User name: ${NC} ";read -r USERNAME
		printf "\\n${R_BG} Enter Password: ${NC} ";read -r PASSWORD
		writePW=1
		printf "\\n${R_BG} Enter SMTP Server: ${NC} ";read -r SMTP
		printf "\\n${R_BG} Enter Server port: ${NC} ";read -r PORT
		printf "\\n${R_BG} Enter Protocol: ${NC} ";read -r PROTOCOL
		printf "\\n${R_BG} Enter SSL flag: ${NC} ";read -r SSL_FLAG
		write_email_config_file
		check_friendly_name
		email_manage
	else
		. "${EMAIL_DIR}/email.conf"
		echo " Your email credentials are saved at:"
		echo " ${EMAIL_DIR}"
		echo
		notice_email_settings
		echo
		echo "  1. Edit From address:   ${GN}$FROM_ADDRESS${NC}"
		echo "  2. Edit To name:        ${GN}$TO_NAME${NC}"
		echo "  3. Edit To address:     ${GN}$TO_ADDRESS${NC}"
		echo "  4. Edit Router name:    ${GN}$FRIENDLY_ROUTER_NAME${NC}"
		echo "  5. Edit User name:      ${GN}$USERNAME${NC}"
		echo "  6. Edit Password:       select Edit to view"
		echo "  7. Edit SMTP Server:    ${GN}$SMTP${NC}"
		echo "  8. Edit Server port:    ${GN}$PORT${NC}"
		echo "  9. Edit Protocol:       ${GN}$PROTOCOL${NC}"
		if [ "$SSL_FLAG" ]; then
			echo " 10. Edit SSL flag:       ${GN}$SSL_FLAG${NC}"
		else
			echo " 10. Edit SSL flag:       ${GY}Set to${NC} ${GN}--insecure${NC} ${GY}if curl problems occur${NC}"
		fi
		echo " 11. Send testmail to confirm settings"

		if [ -f "${EMAIL_DIR}/email.conf" ] && grep -q 'PUT YOUR PASSWORD HERE' "${EMAIL_DIR}/email.conf"; then
			printf "\\n${R} Set your email password, it has been redacted\\n for security reasons.${NC}\\n"
		elif [ ! -f "${EMAIL_DIR}/emailpw.enc" ]; then
			printf "\\n${R} Set your email password, it has not been set.${NC}\\n"
		fi

		while true; do
			printf "\\n Enter your selection [1-11 e=Exit] ";read -r continue
			case "$continue" in
				1)	printf "\\n${R_BG} Enter From address: ${NC} [e=Exit] ";read -r value
					FROM_ADDRESS=$value;break;;
				2)	printf "\\n${R_BG} Enter To name: ${NC} [e=Exit] ";read -r value
					TO_NAME=$value;break;;
				3)	printf "\\n${R_BG} Enter To address: ${NC} [e=Exit] ";read -r value
					TO_ADDRESS=$value;break;;
				4)	printf "\\n This friendly router name may only consist of\\n alphanumeric, - and _ characters. No spaces and\\n"
					printf " not more than 16 characters.\\n The word \"Router\" is auto-added after the name.\\n"
					printf "\\n${R_BG} Enter Router name: ${NC} [e=Exit] ";read -r value
					case "$value" in
					 [Ee])	email_manage;;
						*)	;;
					esac
					FRIENDLY_ROUTER_NAME=$value
					check_friendly_name;break;;
				5)	printf "\\n${R_BG} Enter User name: ${NC} [e=Exit] ";read -r value
					USERNAME=$value;break;;
				6)	p_e_l
					[ -f "${EMAIL_DIR}/emailpw.enc" ] && echo " $(/usr/sbin/openssl aes-256-cbc $emailPwEnc -d -in "${EMAIL_DIR}/emailpw.enc" -pass pass:ditbabot,isoi) ${R}<-- current password${NC}"
					while true; do
						printf "\\n Edit password now? [1=Yes e=Exit] ";read -r continue
						case "$continue" in
							1)		printf "\\n${R_BG} Enter new Password: ${NC} [e=Exit] ";read -r value
									if [ "$value" != e ]; then
										writePW=1
										PASSWORD=$value
									fi
									break;;
							[Ee])	email_manage;break;;
							*)		printf "\\n input is not an option\\n";;
						esac
					done
					break;;
				7)	printf "\\n${R_BG} Enter SMTP Server: ${NC} [e=Exit] ";read -r value
					SMTP=$value;break;;
				8)	printf "\\n${R_BG} Enter Server port: ${NC} [e=Exit] ";read -r value
					PORT=$value;break;;
				9)	printf "\\n${R_BG} Enter Protocol: ${NC} [e=Exit] ";read -r value
					PROTOCOL=$value;break;;
				10)	printf "\\n${R_BG} Enter SSL flag: ${NC} [e=Exit] ";read -r value
					SSL_FLAG=$value;break;;
				11)	p_e_l
					verbose=
					printf " This will send a testmail\\n\\n From: $FROM_ADDRESS\\n To:   $TO_NAME <$TO_ADDRESS>\\n\\n"
					echo " 1. Send testmail"
					echo " 2. Send testmail, verbose output"
					while true; do
						printf "\\n Enter your selection [1-2 e=Exit] ";read -r continue
						case "$continue" in
							1)	send_testmail;break;;
							2)	verbose=-v
								send_testmail;break;;
						 [Ee])	email_manage;break;;
							*)	printf "\\n input is not an option\\n";;
						esac
					done;break;;
			 [Ee])  show_amtm menu;break;;
				*)	printf "\\n input is not an option\\n";;
			esac
		done

		case "$value" in
		 [Ee])	email_manage;break;;
			*)	write_email_config_file;email_manage;break;;
		esac
	fi
}

check_friendly_name(){
	check_subroutine(){
		printf "\\n${R_BG} Enter Router name: ${NC} [e=Exit] ";read -r value
		case "$value" in
		 [Ee])	email_manage;;
			*)	;;
		esac
		FRIENDLY_ROUTER_NAME=$value
		check_friendly_name
	}

	if [ "${#FRIENDLY_ROUTER_NAME}" -lt "2" ] || [ "${#FRIENDLY_ROUTER_NAME}" -gt "16" ]; then
		echo
		echo "${R} Router name length under or over 2 to 16 characters${NC}"
		check_subroutine
	fi
	case "$FRIENDLY_ROUTER_NAME" in
				   -*|_* )	echo
							echo "${R} Router name not OK, starts with hyphen or underscore${NC}"
							check_subroutine;;
				   *-|*_ )	echo
							echo "${R} Router name not OK, ends with hyphen or underscore${NC}"
							check_subroutine;;
		*[^a-zA-Z0-9-_]* )	echo
							echo "${R} Router name not OK, special characters are not allowed${NC}"
							check_subroutine;;
	esac
	write_email_config_file
	email_manage
}

write_email_config_file(){
	mkdir -p "${EMAIL_DIR}"
	[ "$writePW" = 1 ] && echo -n $PASSWORD | /usr/sbin/openssl aes-256-cbc $emailPwEnc -out "${EMAIL_DIR}/emailpw.enc" -pass pass:ditbabot,isoi
	writePW=
	echo "# Email settings (mail envelope) #" > "${EMAIL_DIR}/email.conf"
	echo "FROM_ADDRESS=\"$FROM_ADDRESS\"" >> "${EMAIL_DIR}/email.conf"
	echo "TO_NAME=\"$TO_NAME\"" >> "${EMAIL_DIR}/email.conf"
	echo "TO_ADDRESS=\"$TO_ADDRESS\"" >> "${EMAIL_DIR}/email.conf"
	echo "FRIENDLY_ROUTER_NAME=\"$FRIENDLY_ROUTER_NAME\"" >> "${EMAIL_DIR}/email.conf"
	echo >> "${EMAIL_DIR}/email.conf"
	echo "# Email credentials #" >> "${EMAIL_DIR}/email.conf"
	echo "USERNAME=\"$USERNAME\"" >> "${EMAIL_DIR}/email.conf"
	echo "# Encrypted Password is stored in emailpw.enc file." >> "${EMAIL_DIR}/email.conf"
	echo >> "${EMAIL_DIR}/email.conf"
	echo "# Server settings #" >> "${EMAIL_DIR}/email.conf"
	echo "SMTP=\"$SMTP\"" >> "${EMAIL_DIR}/email.conf"
	echo "PORT=\"$PORT\"" >> "${EMAIL_DIR}/email.conf"
	echo "PROTOCOL=\"$PROTOCOL\"" >> "${EMAIL_DIR}/email.conf"
	echo "SSL_FLAG=\"$SSL_FLAG\"" >> "${EMAIL_DIR}/email.conf"
	[ "$emailPwEnc" ] && echo "emailPwEnc=$emailPwEnc" >> "${EMAIL_DIR}/email.conf"
}

check_email_conf_file(){
	if [ ! -f "${EMAIL_DIR}/email.conf" ]; then
		email_manage
	else
		unset FROM_ADDRESS TO_NAME TO_ADDRESS USERNAME PASSWORD SMTP PORT PROTOCOL
		. "${EMAIL_DIR}/email.conf"
		if [ -z "$FROM_ADDRESS" ] || [ -z "$TO_NAME" ] || [ -z "$TO_ADDRESS" ] || [ -z "$USERNAME" ] || [ ! -f "${EMAIL_DIR}/emailpw.enc" ] || [ -z "$SMTP" ] || [ -z "$PORT" ] || [ -z "$PROTOCOL" ]; then
			printf "\\n${R_BG} email settings not set or incomplete.${NC}\\n"
			p_e_t "email settings";email_manage
		elif [ "$PASSWORD" = "PUT YOUR PASSWORD HERE" ]; then
			printf "\\n${R_BG} email password has not been set.${NC}\\n"
			p_e_t "email settings";email_manage
		fi
	fi
}

send_testmail(){
	check_email_conf_file
	. "${EMAIL_DIR}/email.conf"
	[ -z "$(nvram get odmpid)" ] && routerModel=$(nvram get productid) || routerModel=$(nvram get odmpid)
	rm -f /tmp/amtm-mail-body
	echo
	echo "Subject: Router testmail $(date +"%a %b %d %Y")" >/tmp/amtm-mail-body
	echo "From: \"amtm\" <$FROM_ADDRESS>" >>/tmp/amtm-mail-body
	echo "Date: $(date -R)" >>/tmp/amtm-mail-body
	echo "To: \"$TO_NAME\" <$TO_ADDRESS>" >>/tmp/amtm-mail-body
	echo >>/tmp/amtm-mail-body
	echo " Greetings from amtm $version" >>/tmp/amtm-mail-body
	echo >>/tmp/amtm-mail-body
	echo " This is a testmail." >>/tmp/amtm-mail-body
	echo >>/tmp/amtm-mail-body
	echo " Very truly yours," >>/tmp/amtm-mail-body
	echo " Your $FRIENDLY_ROUTER_NAME router (Model type $routerModel)" >>/tmp/amtm-mail-body
	echo >>/tmp/amtm-mail-body

	/usr/sbin/curl $verbose --url $PROTOCOL://$SMTP:$PORT \
		--mail-from "$FROM_ADDRESS" --mail-rcpt "$TO_ADDRESS" \
		--upload-file /tmp/amtm-mail-body \
		--ssl-reqd \
		--user "$USERNAME:$(/usr/sbin/openssl aes-256-cbc $emailPwEnc -d -in "${EMAIL_DIR}/emailpw.enc" -pass pass:ditbabot,isoi)" $SSL_FLAG

	if [ "$?" = "0" ]; then
		rm -f /tmp/amtm-mail*
		echo
		sleep 2
		logger -t amtm "sent a testmail (user action)"
		show_amtm " Success: testmail sent to $TO_NAME\\n at $TO_ADDRESS"
	else
		rm -f /tmp/amtm-mail*
		printf "\\n${R_BG} sending testmail failed${NC}\\n\\n"
		printf " Note the curl: error above and check your settings\\n"
		logger -t amtm "sending of a testmail failed (user action)"
		p_e_t "return to menu"
		email_manage
	fi
}
#eof
