#!/bin/sh
#bof
entware_installed(){
	if [ "$cleanup" ]; then
		if [ ! -f /jffs/scripts/post-mount ] || ! grep -q ". ${add}/mount-entware.mod" /jffs/scripts/post-mount; then
			c_j_s /jffs/scripts/post-mount
			sed -i "2s~^~. ${add}/mount-entware.mod # Added by amtm\n~" /jffs/scripts/post-mount
		fi
		if [ ! -f "${add}"/mount-entware.mod ]; then
			g_m mount-entware.mod new
		fi
	fi

	get_entware_identifiers(){
		ENTURL="$(awk 'NR == 1 {print $3}' /opt/etc/opkg.conf)"
		ENTDOMAIN=$(echo $ENTURL | awk -F'/' '{print $1FS$2FS$3}' | sed 's%http.*://%%')
		VERSION_ID=
		[ -f /opt/etc/entware_release ] && VERSION_ID=", release ${GN}$(grep 'VERSION_ID' /opt/etc/entware_release | sed 's/VERSION_ID=//' | sed 's/"//g')${NC}"
		entVersion=
		[ "$(echo $ENTURL | grep 'aarch64\|armv7\|mipsel')" ] && entVersion="${ENTURL##*/}"
		entServer='bin.entware.net Primary¦server¦by¦Entware¦team¦(recommended) primary¦server¦by¦Entware¦team
		entware.diversion.ch Mirror¦by¦thelonelycoder mirror¦by¦thelonelycoder
		mirrors.cernet.edu.cn/entware Multiple¦mirrors¦by¦CERNET¦(China¦Education¦and¦Research¦Network) multiple¦mirrors¦by¦CERNET'
	}
	get_entware_identifiers

	case "$(uname -m)" in
		armv7l)	if [ "$(v_c $(uname -r))" -lt "$(v_c 3.2)" ] && grep -q 'maurerr.github.io' /opt/etc/opkg.conf && ! grep -q 'garycnew.github.io' /opt/etc/opkg.conf; then
					sed -i '/maurerr.github.io/d' /opt/etc/opkg.conf
					sed -i '2i\src/gz entware-backports-maurerr https://maurerr.github.io/entware-armv7-k26/' /opt/etc/opkg.conf
					sed -i '3i\src/gz entware-backports-garycnew https://garycnew.github.io/Entware/armv7sf-k2.6/' /opt/etc/opkg.conf
					a_m " Entware backports repo by @garycnew added.\\n Check for Entware updates."
				fi;
	esac

	atii=1
	[ -f /opt/bin/curl ] && curlv=/opt/bin/curl || curlv=/usr/sbin/curl
	if [ "$su" = 1 ]; then
		opkg_update(){
			opkg update >/tmp/amtm-entware-check 2>&1
		}
		use_alternate_server(){
			printf "- Entware server ${R}$ENTDOMAIN${NC} unreachable\\n"
			change_opkg_server(){
				sed -i "1s#.*#src\/gz entware https://$1/$entVersion#" /opt/etc/opkg.conf
			}
			serverOK=
			if [ "$ENTDOMAIN" != pkg.entware.net ]; then
				es=
				IFS='
				'
				set -f
				for i in $entServer; do
					if [ -z "$serverOK" ]; then
						i1=$(echo $i | awk '{print $1}')
						if [ "$ENTDOMAIN" != "$i1" ]; then
							if $curlv -IsL https://$i1 | head -n 1 | grep 'OK\|Found' >/dev/null; then
								printf "- Using Entware server ${GN}$i1${NC},\\n  $(echo $i | awk '{print $2}' | sed 's/¦/ /g')\\n"
								change_opkg_server $i1
								opkg_update
								[ -s /tmp/amtm-entware-check ] && grep -q 'pdated list' /tmp/amtm-entware-check && serverOK=1
							else
								printf "- Entware server ${R}$i1${NC} unreachable\\n"
								echo 'ailed to' >/tmp/amtm-entware-check
							fi
						fi
					fi
				done
				set +f
				IFS=
			else
				if grep -q 'maurerr.github.io' /opt/etc/opkg.conf; then
					entServer=maurerr.github.io
					if $curlv -IsL https://$entServer | head -n 1 | grep 'OK\|Found' >/dev/null; then
						printf "- Using Entware server ${GN}$entServer${NC},\\n  entware-backports-mirror\\n"
						opkg update >/tmp/amtm-entware-check 2>&1
					else
						printf "- Entware server ${R}$entServer${NC} unreachable\\n"
						echo 'ailed to' >/tmp/amtm-entware-check
					fi
				else
					echo 'ailed to' >/tmp/amtm-entware-check
				fi
			fi
		}

		if $curlv -IsL https://$ENTDOMAIN | head -n 1 | grep 'OK\|Found' >/dev/null; then
			opkg_update
			if grep -q 'ailed to' /tmp/amtm-entware-check; then
				use_alternate_server
			fi
		else
			use_alternate_server
		fi

		if [ -s /tmp/amtm-entware-check ]; then
			if grep -q 'pdated list' /tmp/amtm-entware-check; then
				rm /tmp/amtm-entware-check
				opkg list-upgradable >/tmp/amtm-entware-check
				if [ -s /tmp/amtm-entware-check ]; then
					suUpd=1
					if [ "$tpu" ]; then
						echo "- Entware, $(wc -l </tmp/amtm-entware-check) new package(s) available<br>" >>/tmp/amtm-tpu-check
					else
						[ -z "$updcheck" -a -z "$ss" ] && printf "${GN_BG} ep${NC} %-9s%-20s%${COR}s\\n" "manage" "Entware packages" "${E_BG}-> upd avail${NC}"
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
					[ -z "$updcheck" -a -z "$ss" ] && printf "${GN_BG} ep${NC} %-9s%-21s%${COR}s\\n" "manage" "Entware packages    " " ${GN_BG}no upd${NC}"
				fi
			elif grep -q 'ailed to' /tmp/amtm-entware-check; then
				[ -z "$updcheck" -a -z "$ss" ] && printf "${GN_BG} ep${NC} %-9s%-21s%${COR}s\\n" "manage" "Entware packages    " " ${E_BG}upd err${NC}"
				a_m " Entware: ${R}All servers failed to respond${NC}"
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
				[ -f "${add}"/availUpd.txt ] && sed -i '/^Entware.*/d' "${add}"/availUpd.txt
				unset EntwareUpate EntwareMD5 entUpd
			fi
		fi
		[ "$entUpd" = 1 -a -z "$ss" ] && printf "${GN_BG} ep${NC} %-9s%-20s%${COR}s\\n" "manage" "Entware packages" "${E_BG}-> $EntwareUpate avail${NC}"
		[ -z "$entUpd" -a -z "$ss" ] && printf "${GN_BG} ep${NC} %-9s%s\\n" "manage" "Entware packages"
	fi

	case_ep(){
		p_e_l
		echo " Entware package options"
		echo
		sel=5
		unset bpe bparm pUse
		get_entware_identifiers

		printf " This router runs ${GN}Entware $entVersion${NC}$VERSION_ID\\n Server in use: ${GN}$ENTDOMAIN${NC}\\n"
		printf "\\n See available packages list here:\\n $ENTURL/Packages.html\\n\\n"
		case "$(uname -m)" in
			armv7l)	if [ "$(v_c $(uname -r))" -lt "$(v_c 3.2)" ]; then
						pUse=6;sel=6
						if [ "$(grep 'maurerr.github.io\|garycnew' /opt/etc/opkg.conf)" ]; then
							printf " with updates from ${GN}maurerr.github.io${NC}\\n and ${GN}garycnew.github.io${NC}\\n\\n See available packages list here:\\n"
							printf " https://maurerr.github.io/entware-armv7-k26/\\n https://garycnew.github.io/Entware/armv7sf-k2.6/\\n\\n"
							bparm="${GN}on${NC}"
						else
							bparm=off
						fi
					fi
					;;
			mips)	if [ "$(grep 'maurerr.github.io' /opt/etc/opkg.conf)" ]; then
						printf " with updates from ${GN}maurerr.github.io${NC}\\n\\n See available packages list here:\\n https://maurerr.github.io/packages/\\n\\n"
						bpe="${GN}on${NC}"
					else
						bpe=off
					fi
					;;
		esac

		echo " 1. Check for updated Entware packages"
		echo " 2. Show installed Scripts and Entware packages"

		if [ "$bpe" ]; then
			printf " 3. Parallel use Entware-backports Repo $bpe\\n"
		else
			printf " 3. Select Entware server to use\\n"
		fi
		echo " 4. Entware repair options"
		echo " 5. Remove Entware"
		if [ "$bparm" ]; then
			printf " 6. Parallel use Entware-backports Repos $bparm\\n"
		fi

		while true; do
			printf "\\n Enter selection [1-$sel e=Exit] ";read -r continue
			case "$continue" in
				1)		echo
						if $curlv -IsL https://$ENTDOMAIN | head -n 1 | grep 'OK\|Found' >/dev/null; then
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
						else
							show_amtm " Entware update check failed,\\n $ENTDOMAIN failed to resolve"
						fi

						echo "${NC}"
						show_amtm
						break;;
				2)		if [ ! -f /opt/bin/column ]; then
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
							printf " Parallel use of Entware-backports Repo is $bpe\\n\\n Note if you disable this, Entware\\n repair options might no longer work.\\n"
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
								printf "\\n This repository for MIPS based routers received\\n Entware package updates until December 2019,\\n"
								printf " while the original repo did not.\\n\\n This additional backports source is added:\\n - maurerr.github.io/packages\\n\\n"
								printf " Maintained by @maurer, see this thread for details:\\n snbforums.com/threads/mips-entware-backports-repo-entware-ng-reloaded.49468/\\n\\n"
								printf " Be aware that some of these packported packages\\n may not be compatible or functional on your router.\\n\\n"
								while true; do
									printf " Enable it? [1=Yes e=Exit] ";read -r confirm
									case "$confirm" in
										1)	sed -i '2i\src/gz entware-backports-mirror https://maurerr.github.io/packages' /opt/etc/opkg.conf
											p_e_l
											echo " Do you want to update and upgrade all packages now?"
											while true; do
												printf "\\n Enter selection [1=Yes 2=No] ";read -r confirm
												case "$confirm" in
													1)	echo "${GY}"
														opkg update >/dev/null
														opkg upgrade
														if [ "$?" -ne "1" ]; then
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
							IFS='
							'
							set -f
							for i in $entServer; do
								i1=$(echo $i | awk '{print $1}')
								if $curlv -IsL https://$i1 | head -n 1 | grep 'OK\|Found' >/dev/null; then
									es=$((es+1))
									printf " ${es}. %-$(( 22 + $COR ))s%s\\n" "${GN}$i1${NC}" "- $(echo $i | awk '{print $2}' | sed 's/¦/ /g')"
									eval entServers$es="$i1"
								else
									printf "    %-$(( 22 + $COR ))s%s\\n" "${R}$i1${NC}" "failed, $(echo $i | awk '{print $3}' | sed 's/¦/ /g')"
								fi
							done
							set +f
							IFS=

							selectServer() {
								if [ -z "$es" ]; then
									printf "\\n Sorry, no Entware servers responded.\\n"
									p_e_t return
									show_amtm " Sorry, no Entware servers responded."
								else
									printf "\\n Select Entware server to use [1-$es e=Exit] ";read -r selection
									case "$selection" in
										1|2|3) 	if [ "$selection" -ge 1 ] && [ "$selection" -le "$es" ]; then
													eval entServer="\$entServers$selection"
													sed -i "1s#.*#src\/gz entware https://$entServer/$entVersion#" /opt/etc/opkg.conf
													show_amtm " Entware server $entServer set."
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
				4)		p_e_l
						printf " Entware repair options\\n\\n"
						printf " 1. Reinstall Entware.\\n    This will make sure all necessary\\n    Entware core files are present.\\n\\n"
						printf " 2. Reinstall all installed packages.\\n    This may help when some weird errors\\n    occur with Entware packages.\\n    Be aware that certain package config files\\n    will be overwritten by default values.\\n"
						while true; do
							printf "\\n Enter selection [1-2 e=Exit] ";read -r confirm
							case "$confirm" in
								1)	p_e_l
									printf " Stopping Entware services before\\n reinstalling Entware\\n"
									echo "${GY}"
									/opt/etc/init.d/rc.unslung stop
									echo "${NC}"

									echo " Reinstalling Entware"
									echo "${GY}"
									case "$(uname -m)" in
										armv7l)	if [ "$bparm" != off ]; then
													c_url "$ENTURL/installer/generic.sh" | sed "s#URL=http://bin.entware.net/#URL=https://$ENTDOMAIN/#g" \
													| sed -e "41 i sed -i 's#http://bin.entware.net/#https://$ENTDOMAIN/#g' /opt/etc/opkg.conf" \
													| sed -e "42 i sed -i '2isrc/gz entware-backports-maurerr https://maurerr.github.io/entware-armv7-k26/' /opt/etc/opkg.conf" \
													| sed -e "43 i sed -i '3isrc/gz entware-backports-garycnew https://garycnew.github.io/Entware/armv7sf-k2.6/' /opt/etc/opkg.conf" | sh
													echo "${NC}"
													echo " Installing required $entVersion packages: wget-ssl ca-certificates"
													echo " for use with Entware backports mirrors"
													echo "${GY}"
													opkg install wget-ssl ca-certificates
													echo "${NC}"
												else
													c_url "$ENTURL/installer/generic.sh" | sed "s#URL=http://bin.entware.net/#URL=https://$ENTDOMAIN/#g" \
													| sed -e "41 i sed -i 's#http://bin.entware.net/#https://$ENTDOMAIN/#g' /opt/etc/opkg.conf" | sh
												fi
												;;
										mips)	if [ "$bpe" = off ]; then
													c_url https://pkg.entware.net/binaries/mipsel/installer/installer.sh | sed 's/http:/https:/g' \
													| sed -e "41 i sed -i 's/http:/https:/g' /opt/etc/opkg.conf" | sh
												else
													c_url https://pkg.entware.net/binaries/mipsel/installer/installer.sh | sed 's/http:/https:/g' \
													| sed -e "41 i sed -i 's/http:/https:/g' /opt/etc/opkg.conf" \
													| sed -e "42 i sed -i '2isrc/gz entware-backports-mirror https://maurerr.github.io/packages' /opt/etc/opkg.conf" | sh
												fi
												;;
										*)		c_url "$ENTURL/installer/generic.sh" | sed "s#URL=http://bin.entware.net/#URL=https://$ENTDOMAIN/#g" \
												| sed -e "41 i sed -i 's#http://bin.entware.net/#https://$ENTDOMAIN/#g' /opt/etc/opkg.conf" | sh
												;;
									esac
									echo "${NC}"

									printf " Re-starting Entware services.\\n Output below may be empty for some.\\n"
									echo "${GY}"
									/opt/etc/init.d/rc.unslung start
									echo "${NC}"
									p_e_t "return to menu"

									show_amtm " Entware reinstalled"
									break;;
								2)	p_e_l
									printf " Again, be aware that certain package config\\n files will be overwritten by default values\\n and services may not start afterwards.\\n Be sure to have a recent backup ready.\\n"
									c_d
									printf " Stopping Entware services before\\n reinstalling all packages\\n"
									echo "${GY}"
									/opt/etc/init.d/rc.unslung stop
									echo "${NC}"

									echo " Reinstalling Entware packages"
									echo "${GY}"
									opkg --force-reinstall install $(opkg list_installed | sed 's/ - .*//')
									echo "${NC}"

									printf " Re-starting Entware services.\\n Output below may be empty for some.\\n"
									echo "${GY}"
									/opt/etc/init.d/rc.unslung start
									echo "${NC}"
									printf " Entware packages reinstall completed.\\n If any of the services failed to start reinstate\\n previous config file(s) from a backup.\\n"
									p_e_t "return to menu"

									show_amtm " All Entware packages reinstalled"
									break;;
							[Ee])	break;;
								*)	printf "\\n input is not an option\\n";;
							esac
						done
						show_amtm menu;break;;
				5)		reset_amtm;break;;
				[$pUse])p_e_l
						printf " Parallel use of Entware-backports Repos is $bparm\\n"
						if [ "$bparm" != off ]; then
							printf "\\n Note if you disable this, Entware\\n repair options might no longer work.\\n"
							while true; do
								printf "\\n Disable it? [1=Yes e=Exit] ";read -r confirm
								case "$confirm" in
									1)	sed -i '/maurerr.github.io/d' /opt/etc/opkg.conf
										sed -i '/garycnew.github.io/d' /opt/etc/opkg.conf
										show_amtm " Entware-backports Repos disabled"
										break;;
								[Ee])	show_amtm menu;break;;
									*)	printf "\\n input is not an option\\n";;
								esac
							done
						else
							printf "\\n These repositories for armv7sf-k2.6 based routers receive\\n Entware package updates until further notice,\\n"
							printf " while the original repo no longer does.\\n\\n These additional backports sources are added:\\n - maurerr.github.io/entware-armv7-k26/\\n - garycnew.github.io/Entware/armv7sf-k2.6/\\n\\n"
							printf " Maintained by @maurer and @garycnew, see this thread for details:\\n snbforums.com/threads/entware-armv7sf-k2-6-eos.89032/\\n\\n"
							printf " Be aware that some of these packported packages\\n may not be compatible or functional on your router.\\n\\n"
							while true; do
								printf " Enable it? [1=Yes e=Exit] ";read -r confirm
								case "$confirm" in
									1)	opkg update >/dev/null
										echo " Installing required $entVersion packages: wget-ssl ca-certificates"
										echo "${GY}"
										opkg install wget-ssl ca-certificates
										echo "${NC}"
										sed -i '2i\src/gz entware-backports-maurerr https://maurerr.github.io/entware-armv7-k26/' /opt/etc/opkg.conf
										sed -i '3i\src/gz entware-backports-garycnew https://garycnew.github.io/Entware/armv7sf-k2.6/' /opt/etc/opkg.conf
										p_e_l
										echo " Do you want to update and upgrade all packages now?"
										while true; do
											printf "\\n Enter selection [1=Yes 2=No] ";read -r confirm
											case "$confirm" in
												1)	echo "${GY}"
													opkg update >/dev/null
													opkg upgrade
													if [ "$?" -ne "1" ]; then
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
										show_amtm " Entware-backports Repos enabled";break;;
								[Ee])	show_amtm menu;break;;
									*)	printf "\\n input is not an option\\n";;
								esac
							done
						fi
						show_amtm menu;break;;
				[Ee])	show_amtm menu;break;;
				*)		printf "\\n input is not an option\\n";;
			esac
		done
	}
}
#eof
