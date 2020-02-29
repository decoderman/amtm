#!/bin/sh
#bof
check_ps_version(){
	psVersion="$(pixelserv-tls -v | awk 'NR == 1 {print $2}')"
	[ -z "$psVersion" ] && psVersion="likely v.Kk"
	case $psVersion in
	  v*|*v.K*) ;;
	  * ) psVersion="v$psVersion" ;;
	esac
}
entware_installed(){
	atii=1
	if [ "$su" = 1 ]; then
		opkg update >/tmp/amtm-entware-check 2>&1
		if [ -s /tmp/amtm-entware-check ]; then
			if grep -q 'pdated list' /tmp/amtm-entware-check; then
				rm /tmp/amtm-entware-check
				opkg list-upgradable >/tmp/amtm-entware-check
				if [ -s /tmp/amtm-entware-check ]; then
					suUpd=1
					if [ "$tpu" ]; then
						[ "$tpu" ] && echo "<br>Entware package updates:<br>" >>/tmp/amtm-tpu-check
					else
						printf "${GN_BG} ep${NC} %-9s%-20s%${COR}s\\n" "manage" "Entware packages" "${E_BG}-> upd avail${NC}"
						while read line; do
							printf "- %-22s%-10s%${COR}s\\n" "$(echo $line | awk '{print $1}')" " $(echo $line | awk '{print $3}')" " $(echo $line | awk '{print "'${E_BG}'-> " $5 "'${NC}'"}')"
							[ "$tpu" ] && echo "&nbsp;- $(echo $line | awk '{print $1}') v$(echo $line | awk '{print $3}') -> v$(echo $line | awk '{print $5}')<br>" >>/tmp/amtm-tpu-check
						done </tmp/amtm-entware-check
						echo
					fi
				else
					printf "${GN_BG} ep${NC} %-9s%-21s%${COR}s\\n" "manage" "Entware packages    " " ${GN_BG}no upd${NC}"
				fi

			elif grep -q 'ailed to' /tmp/amtm-entware-check; then
				printf "${GN_BG} ep${NC} %-9s%-21s%${COR}s\\n" "manage" "Entware packages    " " ${E_BG}upd err${NC}"
				if grep -q 'bin.entware.net' /opt/etc/opkg.conf; then
					a_m " ! Entware: ${R}bin.entware.net${NC} unreachable"
				elif grep -q 'maurerr.github.io' /opt/etc/opkg.conf; then
					a_m " ! Entware: ${R}pkg.entware.net${NC} and\\n   ${R}maurerr.github.io${NC} unreachable"
				else
					a_m " ! Entware: ${R}pkg.entware.net${NC} unreachable"
				fi
			fi
		fi
		rm -f /tmp/amtm-entware-check
	else
		printf "${GN_BG} ep${NC} %-9s%s\\n" "manage" "Entware packages"
	fi
	case_ep(){
		p_e_l
		echo " Entware package options"
		echo
		echo " 1. Update and upgrade Entware packages"
		echo " 2. Show installed Scripts and Entware packages"
		while true; do
			printf "\\n Enter selection [1-2 e=Exit] ";read -r continue
			case "$continue" in
				1)		p_e_l
						echo " This updates and upgrades Entware packages"
						if [ -f /jffs/scripts/install_stubby.sh ] && [ -f /opt/etc/stubby/stubby.yml ]; then
							echo
							echo " Note: Stubby DNS Privacy Daemon is installed"
							echo " on this router."
							echo " It's recommended to update Entware packages"
							echo " selectively through the Stubby DNS menu to"
							echo " prevent overwriting configuration files."
						fi
						c_d

						if [ -f /opt/bin/pixelserv-tls ]; then
							check_ps_version
							oldpsv=$psVersion
						fi

						echo "${GY}"
						opkg update
						opkg upgrade
						echo "${NC}"

						[ -f /opt/bin/pixelserv-tls ] && check_ps_version
						pstext=
						if [ -f /opt/bin/pixelserv-tls ] && [ "$oldpsv" != "$psVersion" ]; then
							[ -f /opt/share/diversion/file/S80pixelserv-tls ] && cp -f /opt/share/diversion/file/S80pixelserv-tls /opt/etc/init.d/
							[ -f /opt/etc/init.d/S80pixelserv-tls ] && [ ! -x /opt/etc/init.d/S80pixelserv-tls ] && chmod 0755 /opt/etc/init.d/S80pixelserv-tls
							echo "${GY}"
							/opt/etc/init.d/S80pixelserv-tls restart $0
							echo "${NC}"
							pstext=",\\n pixelserv-tls $psVersion restarted"
						fi
						show_amtm " Entware packages updated and upgraded${pstext}";break;;
				2)		if [ ! -f /opt/bin/column ];then
							echo
							echo " Installing missing Entware package 'column'"
							echo " for a better file presentation."
							echo "${GY}"
							opkg update
							opkg install column
							echo "${NC}"
							p_e_l
						else
							echo
						fi

						opkg list-installed | sed 's/^/ /' >/tmp/column.txt
						echo "${R_BG} List of installed Entware packages ($(wc -l < /tmp/column.txt)) ${NC}"
						echo "${GN}";column -or /tmp/column.txt;echo "${NC}"

						ls -l /opt/bin | grep -v "opkg" | grep -v /jffs/scripts | awk '{print $9}' | sed 's/^/ /' >/tmp/column.txt
						echo "${R_BG} Entware Apps installed in /opt/bin/ ($(wc -l < /tmp/column.txt)) ${NC}"
						echo "${GN}";column -or /tmp/column.txt;echo "${NC}"

						rm /tmp/column.txt
						[ -f /opt/bin/diversion ] && echo "diversion" >/tmp/column.txt
						ls -l /opt/bin | awk '/scripts/ {print $9}' >>/tmp/column.txt
						if [ -s /tmp/column.txt ];then
							sort /tmp/column.txt -o /tmp/column.txt
							sed -i 's/^/ /;s/firewall/firewall (Skynet)/' /tmp/column.txt
							echo "${R_BG} Non-Entware Scripts installed in /opt/bin/ ($(wc -l < /tmp/column.txt)) ${NC}"
							echo "${B}";column -or /tmp/column.txt;echo "${NC}"
						fi

						ls -l /opt/sbin | grep -v "opkg" | grep -v /jffs/scripts | awk '{print $9}' | sed 's/^/ /' >/tmp/column.txt
						echo "${R_BG} Entware Apps installed in /opt/sbin/ ($(wc -l < /tmp/column.txt)) ${NC}"
						echo "${GN}";column -or /tmp/column.txt;echo "${NC}"

						ls -l /opt/sbin | awk '/scripts/ {print $9}' | sed 's/^/ /' >/tmp/column.txt
						if [ -s /tmp/column.txt ];then
							echo "${R_BG} Non-Entware Scripts installed in /opt/sbin/ ($(wc -l < /tmp/column.txt)) ${NC}"
							echo "${B}";column -or /tmp/column.txt;echo "${NC}"
						fi
						rm /tmp/column.txt
						p_e_t "return to menu"
						show_amtm menu;break;;
				[Ee])	show_amtm menu;break;;
				*)		printf "\\n input is not an option\\n";;
			esac
		done
	}
}
#eof
