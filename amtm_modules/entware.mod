#!/bin/sh
#bof
check_ps_version(){
	psVersion="$(pixelserv-tls -v | awk 'NR == 1 {print $2}')"
	[ -z "$psVersion" ] && psVersion="likely v.Kk"
	case $psVersion in
	  v*|*v.K*) ;;
	  * ) psVersion="$psVersion" ;;
	esac
}

entware_installed(){

	check_entware_https(){
		if [ -f /opt/etc/opkg.conf ] && /usr/sbin/openssl version | awk '$2 ~ /(^0\.)|(^1\.(0\.|1\.0))/ { exit 1 }' && grep -q 'http:' /opt/etc/opkg.conf; then
			 sed -i 's/http:/https:/g' /opt/etc/opkg.conf
		fi
	}

	ENTURL="$(awk 'NR == 1 {print $3}' /opt/etc/opkg.conf)"
	ENTDOMAIN=$(echo $ENTURL | awk -F'/' '{print $1FS$2FS$3}' | sed 's%http.*://%%')
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
						echo "- Entware, $(wc -l </tmp/amtm-entware-check) new package(s) available<br>" >>/tmp/amtm-tpu-check
					else
						[ -z "$updcheck" ] && printf "${GN_BG} ep${NC} %-9s%-20s%${COR}s\\n" "manage" "Entware packages" "${E_BG}-> upd avail${NC}"
						i=0
						while read line; do
							i=$((i+1))
							printf "- %-22s%-10s%${COR}s\\n" "$(echo $line | awk '{print $1}')" " $(echo $line | awk '{print $3}')" " $(echo $line | awk '{print "'${E_BG}'-> " $5 "'${NC}'"}')"
							[ "$tpu" ] && echo "&nbsp;- $(echo $line | awk '{print $1}') $(echo $line | awk '{print $3}') -> $(echo $line | awk '{print $5}')<br>" >>/tmp/amtm-tpu-check
						done </tmp/amtm-entware-check
						echo
						echo "EntwareUpate=\"$i\"">>"${add}"/availUpd.txt
						echo "EntwareMD5=\"$(md5sum /opt/lib/opkg/status | awk '{print $1}')\"">>"${add}"/availUpd.txt
					fi
				else
					[ -z "$updcheck" ] && printf "${GN_BG} ep${NC} %-9s%-21s%${COR}s\\n" "manage" "Entware packages    " " ${GN_BG}no upd${NC}"
				fi
			elif grep -q 'ailed to' /tmp/amtm-entware-check; then
				[ -z "$updcheck" ] && printf "${GN_BG} ep${NC} %-9s%-21s%${COR}s\\n" "manage" "Entware packages    " " ${E_BG}upd err${NC}"
				if grep -q 'maurerr.github.io' /opt/etc/opkg.conf; then
					a_m " ! Entware: ${R}$ENTDOMAIN${NC} and\\n   ${R}maurerr.github.io${NC} unreachable"
				else
					a_m " ! Entware: ${R}$ENTDOMAIN${NC} unreachable"
				fi
				[ "$updcheck" ] && echo "- Entware server unreachable." >>/tmp/amtm-tpu-check
			fi
		fi
		rm -f /tmp/amtm-entware-check
	else
		entUpd=
		if [ "$EntwareUpate" ]; then
			entUpd=1
			[ "$EntwareUpate" -lt 10 ] && EntwareUpate="$EntwareUpate p" || EntwareUpate="${EntwareUpate}p"
			if [ "$EntwareMD5" != "$(md5sum /opt/lib/opkg/status | awk '{print $1}')" ]; then
				sed -i '/^Entware.*/d' "${add}"/availUpd.txt
				unset EntwareUpate EntwareMD5 entUpd
			fi
		fi
		if [ ! -L /opt/bin/entware-services ]; then
			ln -nsf /opt/etc/init.d/rc.unslung /opt/bin/entware-services
			a_m " entware-services symlink set for rc.unslung"
		fi
		[ "$entUpd" = 1 ] && printf "${GN_BG} ep${NC} %-9s%-20s%${COR}s\\n" "manage" "Entware packages" "${E_BG}-> $EntwareUpate avail${NC}"
		[ -z "$entUpd" ] && printf "${GN_BG} ep${NC} %-9s%s\\n" "manage" "Entware packages"
	fi
	case_ep(){
		p_e_l
		echo " Entware package options"
		echo
		entVersion=; bpe=
		[ "$(echo $ENTURL | grep 'aarch64\|armv7\|mipsel')" ] && entVersion="${ENTURL##*/}"

		printf " This router runs ${GN}Entware $entVersion${NC}\\n Server in use: ${GN}$ENTDOMAIN${NC}\\n"
		if [ "$(uname -m)" = "mips" ]; then
			printf "\\n See available packages list here:\\n $ENTURL/Packages.html\\n\\n"
			if [ "$(grep 'maurerr.github.io' /opt/etc/opkg.conf)" ]; then
				printf " with updates from ${GN}maurerr.github.io${NC}\\n\\n See available packages list here:\\n https://maurerr.github.io/packages/\\n\\n"
				bpe="${GN}on${NC}"
			else
				printf "\\n"
				bpe=off
			fi
		else
			printf "\\n See available packages list here:\\n $ENTURL/Packages.html\\n\\n"
		fi

		echo " 1. Check for updated Entware packages"
		echo " 2. Show installed Scripts and Entware packages"

		if [ "$bpe" ]; then
			printf " 3. Parallel use Entware-backports Repo $bpe\\n"
		else
			printf " 3. Select Entware server to use\\n"
		fi
		echo " 4. Remove Entware"

		while true; do
			printf "\\n Enter selection [1-4 e=Exit] ";read -r continue
			case "$continue" in
				1)		echo
						check_entware_https

						if [ -f /opt/bin/pixelserv-tls ]; then
							check_ps_version
							oldpsv=$psVersion
						fi

						if $(opkg update | grep -q 'pdated list'); then
							if [ "$(opkg list-upgradable)" ]; then
								p_e_l
								echo " These Entware updates are available:"
								opkg list-upgradable | sed 's/^/ - /'
								c_d

								echo " Stopping Entware services before updating packages"
								echo "${GY}"
								/opt/etc/init.d/rc.unslung stop
								echo "${NC}"

								echo " Updating / upgrading Entware packages"
								echo "${GY}"
								opkg upgrade
								echo "${NC}"

								echo " Re-starting Entware services"
								echo "${GY}"
								if [ -f /opt/bin/pixelserv-tls ]; then
									if ! grep -q 'Diversion' /opt/etc/init.d/S80pixelserv-tls; then
										[ -f /opt/share/diversion/file/S80pixelserv-tls ] && cp -f /opt/share/diversion/file/S80pixelserv-tls /opt/etc/init.d/
										[ -f /opt/etc/init.d/S80pixelserv-tls ] && [ ! -x /opt/etc/init.d/S80pixelserv-tls ] && chmod 0755 /opt/etc/init.d/S80pixelserv-tls
									fi
								fi
								/opt/etc/init.d/rc.unslung start
								echo "${NC}"
								p_e_t "return to menu"

								show_amtm " Entware packages updated and upgraded"
							else
								show_amtm " No Entware package updates available at\\n this time."
							fi
						else
							a_m " Entware update check failed:"
							if grep -q 'maurerr.github.io' /opt/etc/opkg.conf; then
								a_m " ${R}$ENTDOMAIN${NC} and\\n ${R}maurerr.github.io${NC} unreachable"
							else
								a_m " ${R}$ENTDOMAIN${NC} unreachable"
							fi
						fi
						echo "${NC}"
						show_amtm
						break;;
				2)		check_entware_https
						if [ ! -f /opt/bin/column ]; then
							echo
							echo " Installing required Entware package 'column'"
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
						if [ -s /tmp/column.txt ]; then
							sort /tmp/column.txt -o /tmp/column.txt
							sed -i 's/^/ /;s/firewall/firewall (Skynet)/' /tmp/column.txt
							echo "${R_BG} Non-Entware Scripts installed in /opt/bin/ ($(wc -l < /tmp/column.txt)) ${NC}"
							echo "${B}";column -or /tmp/column.txt;echo "${NC}"
						fi

						ls -l /opt/sbin | grep -v "opkg" | grep -v /jffs/scripts | awk '{print $9}' | sed 's/^/ /' >/tmp/column.txt
						echo "${R_BG} Entware Apps installed in /opt/sbin/ ($(wc -l < /tmp/column.txt)) ${NC}"
						echo "${GN}";column -or /tmp/column.txt;echo "${NC}"

						ls -l /opt/sbin | awk '/scripts/ {print $9}' | sed 's/^/ /' >/tmp/column.txt
						if [ -s /tmp/column.txt ]; then
							echo "${R_BG} Non-Entware Scripts installed in /opt/sbin/ ($(wc -l < /tmp/column.txt)) ${NC}"
							echo "${B}";column -or /tmp/column.txt;echo "${NC}"
						fi
						rm /tmp/column.txt
						p_e_t "return to menu"
						show_amtm menu;break;;
				3)		if [ "$bpe" ]; then
							p_e_l
							echo " Parallel use of Entware-backports Repo is $bpe"
							if [ "$bpe" != off ]; then
								while true; do
									printf "\\n Disable it? [1=Yes e=Exit] ";read -r confirm
									case "$confirm" in
										1)	sed -i '/pkg.entware-backports.tk/d' /opt/etc/opkg.conf
											sed -i '/maurerr.github.io/d' /opt/etc/opkg.conf
											show_amtm " Entware-backports Repo disabled"
											break;;
									[Ee])	show_amtm menu;break;;
										*)	printf "\\n input is not an option\\n";;
									esac
								done
							else
								echo
								echo " This repository for MIPS based routers received"
								echo " Entware package updates until December 2019,"
								echo " while the original repo did not."
								echo
								echo " The additional backports source is added:"
								echo " - maurerr.github.io/packages"
								echo
								echo " Maintained by @maurer, see this thread for details:"
								echo " https://www.snbforums.com/threads/mips-entware-backports-repo-entware-ng-reloaded.49468/"
								while true; do
									printf "\\n Enable it? [1=Yes e=Exit] ";read -r confirm
									case "$confirm" in
										1)	sed -i '2i\src/gz entware-backports-mirror https://maurerr.github.io/packages' /opt/etc/opkg.conf
											p_e_l
											echo " Do you want to update and upgrade all packages now?"
											while true; do
												printf "\\n Enter your selection [1=Yes 2=No] ";read -r confirm
												case "$confirm" in
													1)	echo "${GY}"
														if [ -f /opt/bin/pixelserv-tls ]; then
															check_ps_version
															oldpsv=$psVersion
														fi
														opkg update >/dev/null
														opkg upgrade
														if [ "$?" -ne "1" ]; then
															if [ -f /opt/bin/pixelserv-tls ]; then
																check_ps_version
																pstext=
																if [ "$oldpsv" != "$psVersion" ] || ! grep -q 'Diversion' /opt/etc/init.d/S80pixelserv-tls; then
																	[ -f /opt/share/diversion/file/S80pixelserv-tls ] && cp -f /opt/share/diversion/file/S80pixelserv-tls /opt/etc/init.d/
																	[ -f /opt/etc/init.d/S80pixelserv-tls ] && [ ! -x /opt/etc/init.d/S80pixelserv-tls ] && chmod 0755 /opt/etc/init.d/S80pixelserv-tls
																	echo "${GY}"
																	/opt/etc/init.d/S80pixelserv-tls restart $0
																	echo "${NC}"
																	pstext=",\\n pixelserv-tls $psVersion restarted"
																fi
															fi
															a_m " Entware packages action: all packages upgraded"
														else
															a_m " ! Entware packages action: upgrade failed, network error"
														fi
														echo "${NC}"
														show_amtm;break;;
													2)	break;;
													*)	printf "\\n input is not an option\\n";;
												esac
											done
											show_amtm " Entware-backports Repo enabled";break;;
									[Ee])	show_amtm menu;break;;
										*)	printf "\\n input is not an option\\n";;
									esac
								done
							fi
						else
							p_e_l
							printf " Testing Entware servers, current server in\\n use: ${GN}$ENTDOMAIN${NC}\\n\\n"

							es=
							server=bin.entware.net
							if ping -c2 -W3 $server &> /dev/null; then
								es=$((es+1))
								echo " ${es}. ${GN}$server${NC} - Primary server by Entware team (recommended)"
								eval servers$es="$server"
							else
								echo "    ${R}$server${NC} failed, primary server"
							fi
							server=entware.diversion.ch
							if ping -c2 -W3 $server &> /dev/null; then
								es=$((es+1))
								echo " ${es}. ${GN}$server${NC} - Mirror by thelonelycoder"
								eval servers$es="$server"
							else
								echo "    ${R}$server${NC} failed, mirror by thelonelycoder"
							fi
							server=mirrors.bfsu.edu.cn
							if ping -c2 -W3 $server &> /dev/null; then
								es=$((es+1))
								echo " ${es}. ${GN}$server${NC} - Mirror by Beijing Foreign Studies University"
								eval servers$es="$server/entware"
							else
								echo "    ${R}$server${NC} failed, mirror by Beijing Foreign Studies University"
							fi

							selectServer() {
								if [ -z "$es" ]; then
									printf "\\n Sorry, no Entware servers responded.\\n"
									p_e_t return
									show_amtm " Sorry, no Entware servers responded."
								else
									printf "\\n Select Entware server to use [1-$es e=Exit] ";read -r server
									case "$server" in
										1|2|3) 	if [ "$server" -ge 1 ] && [ "$server" -le "$es" ]; then
													eval server="\$servers$server"
													sed -i "1s#.*#src\/gz entware https://$server/$entVersion#" /opt/etc/opkg.conf
													show_amtm " Entware server $server set."
												else
													printf "\\n input is not an option\\n"
													selectServer
												fi
												;;
										[Ee])	show_amtm menu;break;;
										*)		printf "\\n input is not an option\\n"
												selectServer;break;;
									esac
								fi
							}
							selectServer
						fi
						show_amtm menu;break;;
				4)		reset_amtm;break;;
				[Ee])	show_amtm menu;break;;
				*)		printf "\\n input is not an option\\n";;
			esac
		done
	}
}
#eof
