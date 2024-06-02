#!/bin/sh
#bof
version=4.8
release="June 02 2024"
amtmTitle="Asuswrt-Merlin Terminal Menu"
rd_version=1.3 # Router date keeper
fw_version=1.2 # Firmware update notification
wl_MD5=757e79826a752563375aa4c803599e0f # shared-amtm-whitelist
EMAIL_DIR="${add}/mail"
[ -f "${add}"/amtmBranch ] && . "${add}"/amtmBranch

# Begin updates for /usr/sbin/amtm
r_m(){ [ -f "${add}/$1" ] && rm -f "${add}/$1";}
s_d_u(){ case "$amtmBranch" in LOCAL)amtmURL=http://diversion.test/amtm_fw;brTxt=$amtmBranch;;BETA)amtmURL=https://diversion.ch/amtm_fw_beta;brTxt=$amtmBranch;;*)amtmURL=https://fwupdate.asuswrt-merlin.net/amtm_fw;brTxt=;;esac;};s_d_u
if [ "$amtmRev" -lt 7 ]; then
	if [ "$amtmRev" = 1 ]; then g_m amtm_rev1.mod include; elif [ "$amtmRev" -ge 2 ]; then r_m amtm_rev1.mod; fi
	if [ "$amtmRev" -le 3 ]; then g_m amtm_rev3.mod include; elif [ "$amtmRev" -gt 3 ]; then r_m amtm_rev3.mod; fi
	if [ "$amtmRev" = 4 ]; then	g_m amtm_rev4.mod include; elif [ "$amtmRev" -gt 4 ]; then r_m amtm_rev4.mod; fi
	if [ "$amtmRev" = 5 ]; then	g_m amtm_rev5.mod include; elif [ "$amtmRev" -gt 5 ]; then r_m amtm_rev5.mod; fi
	if [ "$amtmRev" = 6 ]; then g_m amtm_rev6.mod include; elif [ "$amtmRev" -gt 6 ]; then r_m amtm_rev6.mod; fi
fi
# End updates for /usr/sbin/amtm

ascii_logo(){
	echo "              _"
	echo "   ____ ____ | |_  ____"
	echo "  / _  |    \|  _)|    \ "
	echo " ( ( | | | | | |__| | | |"
	echo "  \_||_|_|_|_|\___)_|_|_|"
	echo
	echo " $1"
	[ "$1" = "  Goodbye" ] && [ -f "${add}"/shell_history.mod ] && /bin/sh "${add}"/shell_history.mod -run >/dev/null 2>&1
}

about_amtm(){
	p_e_l
	echo " amtm, the $amtmTitle
 Version $version FW (built-in firmware version), released on $release
 amtm firmware file revision: $amtmRev
 Device operation mode NVRAM setting: sw_mode: $(nvram get sw_mode), wlc_psta: $(nvram get wlc_psta)

 amtm is a front end that manages popular scripts
 for wireless routers running Asuswrt-Merlin firmware.

 For updates and discussion visit:
 https://www.snbforums.com/forums/asuswrt-merlin-addons.60/

 Proudly coded by thelonelycoder:
 Copyright (c) 2016-2066 thelonelycoder - All Rights Reserved
 https://www.snbforums.com/members/thelonelycoder.25480
 https://diversion.ch/amtm.html

 Contributors: Adamm, ColinTaylor, Martineau, Stuart MacDonald,
 RavenSystem, orionstar, Martinski

 amtm is free to use under the GNU General
 Public License, version 3 (GPL-3.0).
 https://opensource.org/licenses/GPL-3.0"
	p_r_l
	p_e_t "return to menu"
	show_amtm menu
}

c_e(){ [ ! -f /opt/bin/opkg ] && show_amtm " $1 requires the Entware repository\\n installed. Enter ${GN_BG}ep${NC} to install Entware now.";}
c_ntp(){ [ "$(nvram get ntp_ready)" = 0 ] && show_amtm " NTP not ready, check that router time is synced";}
c_j_s(){ if [ ! -f "$1" ]; then echo "#!/bin/sh" >"$1"; echo >>"$1"; elif [ -f "$1" ] && ! head -1 "$1" | grep -qE "^#!/bin/sh"; then c_nl "$1"; echo >>"$1"; sed -i '1s~^~#!/bin/sh\n~' "$1";fi; d_t_u "$1"; c_nl "$1"; [ ! -x "$1" ] && chmod 0755 "$1";}
c_d(){ p_e_l;while true;do printf " Continue? [1=Yes e=Exit] ";read -r continue;case "$continue" in 1)echo;break;;[Ee])[ "$1" ] && r_m "$1";am=;show_amtm menu;break;;*)printf "\\n input is not an option\\n\\n";;esac done;}
o_g_s(){ show_amtm " ${R}Open games section with${NC} ${GN_BG} g ${NC} ${R}to play a game${NC}";}
p_e_t(){ printf "\\n Press Enter to $1 ";read -r;echo;}
s_p(){ for i in "$1"/*; do if [ -d "$i" ]; then s_p "$i";elif [ -f "$i" ]; then [ ! -w "$i" ] && chmod 0666 "$i";d_t_u "$i";fi;done;}
v_c(){ echo "$@" | awk -F. '{ printf("%d%03d%03d%03d\n", $1,$2,$3,$4); }';}

g_i_m(){
	for i in "$1"/*; do
		if [ -d "$i" ]; then
			g_i_m "$i"
		elif [ "${i##*.}" = mod ]; then
			case "$(basename ${i})" in
				FreshJR_QOS.mod)	r_m "$(basename ${i})";;
				pixelserv-tls.mod)	r_m "$(basename ${i})";;
				nsrum.mod)			r_m "$(basename ${i})";;
				*)					rdl=re
									g_m "${i##*/}" new;;
			esac
		fi
	done
	s_p "${add}"
	rdl=
}

check_email_conf(){
	if [ ! -f ${EMAIL_DIR}/email.conf -o ! -f ${EMAIL_DIR}/emailpw.enc ]; then
		[ "$1" ] && r_m "$1";am=
		show_amtm " Setup mail settings in ${GN_BG} em${NC} first"
	else
		unset FROM_ADDRESS TO_NAME TO_ADDRESS USERNAME SMTP PORT PROTOCOL
		. ${EMAIL_DIR}/email.conf
		if [ -z "$FROM_ADDRESS" -o -z "$TO_NAME" -o -z "$TO_ADDRESS" -o -z "$USERNAME" -o -z "$SMTP" -o -z "$PORT" -o -z "$PROTOCOL" ]; then
			[ "$1" ] && r_m "$1";am=
			show_amtm " email settings not set or incomplete.\\n Use ${GN_BG} em${NC} to setup mail settings."
		fi
	fi
}

show_amtm(){
	s_d_u
	c_t
	[ "$su" = 1 ] && [ "$theme" = solarized ] && COR=30
	if [ -z "$su" -a -s "${add}"/availUpd.txt ]; then
		. "${add}"/availUpd.txt
	else
		[ -z "$updcheck" -a -z "$tpu" ] && rm -f "${add}"/availUpd.txt
	fi
	unset dlok dfc
	if [ -z "$updcheck" ]; then
		echo
		clear
		printf "${R_BG}%-27s%s\\n\\n" " amtm $version FW $brTxt" "by thelonelycoder ${NC}"
		[ -z "$(nvram get odmpid)" ] && model="$(nvram get productid)" || model="$(nvram get odmpid)"
		extendno=$(nvram get extendno)
		[ "$(echo $extendno | wc -c)" -gt 4 ] && extendno="$(echo $extendno | cut -b 1-5).."
		[ "$extendno" = 0 ] && extendno= || extendno=_$extendno
		[ "$(v_c $(nvram get buildno))" -ge "$(v_c 388)" ] && fwVersion=$(nvram get firmver | sed 's/\.//g').$(nvram get buildno)$extendno || fwVersion=$(nvram get buildno)$extendno
		printf " ASUS $model HW: $(uname -m) Kernel: $(uname -r | sed 's/brcmarm//g')\\n FW: $fwVersion IP address: $(nvram get lan_ipaddr)\\n"

		OM='Operation Mode:'
		case "$(nvram get sw_mode)" in
			1) echo " $OM Wireless router";;
			2) echo " $OM Repeater";;
			3) 	case "$(nvram get wlc_psta)" in
					0) echo " $OM Access Point (AP)";;
					1) echo " $OM Media Bridge";;
					2) echo " $OM Repeater/AiMesh Node";;
					*) echo " $OM sw_mode:$(nvram get sw_mode),wlc_psta:$(nvram get wlc_psta),Unknown";;
				esac;;
			4) echo " $OM Media Bridge";;
			5) echo " $OM AiMesh Node";;
			*) echo " $OM sw_mode:$(nvram get sw_mode),wlc_psta:$(nvram get wlc_psta),Unknown";;
		esac
		printf " $(TZ=$(nvram get time_zone_x) date)\\n"
		printf "\\n${R_BG}%-44s ${NC}\\n\\n" " amtm - the $amtmTitle"
		if [ -f /opt/bin/opkg ]; then
			thisDev="$(readlink /tmp/opt | sed 's#/tmp/#/#')"
			printf "${R_BG}%-44s ${NC}\\n\\n" " $(df -kh ${thisDev%/entware} | xargs | awk '{print "'${thisDev%/entware}' "$2" "$9" "$3" "$10" ("$12")"}')"
		fi
		[ "$ss" ] && printf "${GN_BG}%-44s ${NC}\\n\\n" "    Third-party scripts"
		shared_amtm_wl=/jffs/addons/shared-whitelists/shared-amtm-whitelist
		if [ ! -f /jffs/addons/shared-whitelists/shared-Diversion-whitelist ]; then
			if [ ! -f "$shared_amtm_wl" ] || [ "$wl_MD5" != "$(md5sum "$shared_amtm_wl" | awk '{print $1}')" ]; then
				mkdir -p /jffs/addons/shared-whitelists
				cat <<-EOF >"$shared_amtm_wl"
				1drv.ms
				asuswrt-merlin.net
				asuswrt.lostrealm.ca
				big.oisd.nl
				bin.entware.net
				codeload.github.com
				diversion.ch
				entware.diversion.ch
				entware.net
				fwupdate.asuswrt-merlin.net
				localhost.localdomain
				maurerr.github.io
				mirrors.bfsu.edu.cn
				oisd.nl
				onedrive.live.com
				pgl.yoyo.org
				pkg.entware.net
				raw.githubusercontent.com
				small.oisd.nl
				snbforums.com
				someonewhocares.org
				sourceforge.net
				urlhaus.abuse.ch
				www.asuswrt-merlin.net
				www.snbforums.com
				EOF
				a_m " - shared-amtm-whitelist created or updated"
			fi
		else
			rm -f "$shared_amtm_wl"
		fi
	fi
	[ "$(echo $am | grep 'update')" -o "$(echo $1 | grep 'update')" ] && cleanup=on

	modules='/opt/bin/diversion diversion 1 Diversion¦-¦the¦Router¦Adblocker
	/jffs/scripts/firewall skynet 2 Skynet¦-¦the¦Router¦Firewall
	/jffs/addons/flexqos/flexqos.sh FlexQoS 3 FlexQoS¦-¦Flexible¦QoS¦Enhancement
	/jffs/scripts/YazFi YazFi 4 YazFi¦-¦enhanced¦guest¦WiFi
	spacer
	/jffs/scripts/scribe scribe 5 scribe¦-¦syslog-ng¦and¦logrotate
	/opt/bin/x3mMenu x3mRouting 6 x3mRouting¦-¦Selective¦Routing
	/jffs/addons/unbound/unbound_manager.sh unbound_manager 7 unbound¦Manager¦-¦unbound¦utility
	/jffs/scripts/MerlinAU.sh MerlinAU 8 MerlinAU¦-¦The¦Ultimate¦Firmware¦Auto-Updater
	spacer
	/jffs/scripts/connmon connmon j1 connmon¦-¦Internet¦uptime¦monitor
	/jffs/scripts/dn-vnstat Vnstat vn vnStat¦-¦Data¦use¦monitoring
	/jffs/scripts/rtrmon.sh rtrmon rt RTRMON¦-¦Monitor¦your¦Routers¦Health
	/jffs/scripts/killmon.sh killmon km KILLMON¦-¦VPN¦kill¦switch¦monitor¦&¦configurator
	/jffs/scripts/backupmon.sh backupmon bm BACKUPMON¦-¦Backup¦and¦restore¦your¦Router
	spacer
	/jffs/scripts/ntpmerlin ntpmerlin j2 ntpMerlin¦-¦NTP¦Daemon
	/jffs/scripts/scmerlin scmerlin j3 scMerlin¦-¦Quick¦access¦control
	/jffs/scripts/spdmerlin spdmerlin j4 spdMerlin¦-¦Automatic¦speedtest
	spacer
	/jffs/scripts/uiDivStats uiDivStats j5 uiDivStats¦-¦Diversion¦WebUI¦stats
	/jffs/scripts/uiScribe uiScribe j6 uiScribe¦-¦WebUI¦for¦scribe¦logs
	/jffs/scripts/YazDHCP YazDHCP j7 YazDHCP¦-¦Expansion¦of¦DHCP¦assignments
	spacer
	/opt/etc/AdGuardHome/installer AdGuardHome ag Asuswrt-Merlin-AdGuardHome-Installer
	/jffs/scripts/wicens.sh wicens wi WICENS¦-¦WAN¦IP¦Change¦Email¦Notification¦Script
	/jffs/scripts/wan-failover.sh WAN_Failover wf Dual¦WAN¦Failover¦-¦replaces¦ASUS¦WAN¦Failover
	spacer
	/jffs/scripts/vpnmon-r3.sh vpnmon vp VPNMON-R3¦-¦Monitor¦health¦of¦WAN¦DW¦VPN
	/jffs/scripts/vpnmon-r2.sh vpnmon_r2 vp2 VPNMON-R2¦-¦Monitor¦health¦of¦VPN¦(sunsetted)
	/jffs/scripts/domain_vpn_routing.sh  vpn_routing vr Domain-based¦VPN¦Routing
	/jffs/addons/wireguard/wg_manager.sh wireguard_manager wg WireGuard¦Session¦Manager
	/jffs/dnscrypt/installer dnscrypt di dnscrypt¦installer
	/jffs/scripts/tailmon.sh tailmon tm TAILMON¦-¦Tailscale¦installer¦and¦monitor
	spacer
	/opt/bin/opkg entware ep Entware¦-¦Software¦repository
	tpucheck
	ntps
	/jffs/addons/amtm/games/games.conf games g Router¦Games¦-¦so¦much¦fun!
	/jffs/addons/amtm/mail/email.conf email em email¦settings
	/jffs/addons/amtm/fw_update.mod fw_update fw Firmware¦update¦notification
	/jffs/addons/amtm/sc_update.mod sc_update sc Scripts¦update¦notification
	spacer
	/jffs/addons/amtm/disk_check.mod disk_check dc Disk¦check¦script
	fdisk
	/jffs/addons/amtm/ledcontrol.conf led_control lc LED¦control¦-¦Scheduled¦LED¦control
	/jffs/addons/amtm/reboot_scheduler.mod reboot_scheduler rs Reboot¦scheduler
	spacer
	/jffs/addons/amtm/.ash_history shell_history sh shell¦history¦-¦Keep¦history¦of¦shell¦commands
	/jffs/addons/amtm/routerdate router_date rd Router¦date¦keeper¦-¦Keeps¦router¦date¦when¦rebooting'

	IFS='
	'
	set -f
	for i in $modules; do
		case "$i" in
			spacer) 	[ -z "$updcheck" -a "$atii" ] || [ "$ss" ] && echo
						atii=;;
			ntps) 		if [ "$ss" ]; then
							[ -f /opt/bin/opkg ] && nl= || nl=\\n
							printf "$nl${GN_BG}%-44s ${NC}\\n\\n" "    amtm scripts (non third-party scripts)"
						else
							[ "$atii" ] || [ "$ss" ] && echo
							atii=
						fi;;
			tpucheck) 	if [ "$tpu" ]; then
							[ -f /tmp/amtm-tpu-check ] && [ ! -s /tmp/amtm-tpu-check ] && rm /tmp/amtm-tpu-check
							if [ -f /tmp/amtm-tpu-check ] && [ "$updcheck" ]; then
								sed -i 's:<br>::g' /tmp/amtm-tpu-check
								if [ "$(wc -l < /tmp/amtm-tpu-check)" -eq 1 ]; then
									echo "No script updates available at this time in amtm." >/tmp/amtm-tpu-check
									rm -f "${add}"/availUpd.txt
								fi
								if [ ! -f /tmp/amtm-no-delete ]; then
									cat /tmp/amtm-tpu-check
									rm /tmp/amtm-tpu-check
								fi
							fi
							exit 0
						fi
						[ "$dlok" ] && tps=1 || tps=
						[ -z "$su" -a -s "${add}"/availUpd.txt ] && . "${add}"/availUpd.txt;;
			fdisk) 		if [ -f "${add}"/amtm-format-disk.log ]; then
							if [ -z "$su" -a -z "$ss" ]; then
								atii=1
								printf "${GN_BG} fd${NC} %-9s%s\\n" "run" "Format disk         ${GN_BG}fdl${NC} show log"
							fi
						else
							[ "$ss" ] && [ -z "$su" ] && printf "${E_BG} fd${NC} %-9s%s\\n" "run" "Format disk"
						fi
						case_fd(){
							echo
							g_m format_disk.mod include
							[ -f "${add}"/format_disk.mod ] && format_disk || show_amtm menu
						};;
			*) 			scriptloc=$(echo $i | awk '{print $1}')
						f2=$(echo $i | awk '{print $2}')
						if [ -f "$scriptloc" ]; then
							g_m ${f2}.mod include
							[ -f "${add}/${f2}.mod" ] && ${f2}_installed
						else
							f3="$(echo $i | awk '{print $3}')"
							bsp=' '
							case "$(echo $f3 | wc -m)" in
								2)	ssp=' ';;
								3)	ssp=;;
								4)	unset bsp ssp;;
							esac
							[ "$ss" ] && printf "${E_BG}$bsp${f3}$ssp${NC} %-9s%s\\n" "install" "$(echo $i | awk '{print $4}' | sed 's/¦/ /g')"
							if [ -s "${add}"/availUpd.txt -a -f "${add}/${f2}.mod" ]; then
								sn=$(grep 'scriptname=' "${add}/${f2}.mod" | sed "s/.*scriptname=//;s/ /_/g;s/\//_/g;s/'//g")
								[ "$sn" ] && sed -i "/^$sn.*/d" "${add}"/availUpd.txt
							fi
							r_m ${f2}.mod
							case $f3 in
								1)			case_1(){ c_e Diversion;g_m diversion.mod include;[ "$dlok" = 1 ] && install_diversion || show_amtm menu;};;
								2)			case_2(){ g_m skynet.mod include;[ "$dlok" = 1 ] && install_skynet || show_amtm menu;};;
								3)			case_3(){ g_m FlexQoS.mod include;[ "$dlok" = 1 ] && install_FlexQoS || show_amtm menu;};;
								4)			case_4(){ g_m YazFi.mod include;[ "$dlok" = 1 ] && install_YazFi || show_amtm menu;};;
								5)			case_5(){ c_e scribe;g_m scribe.mod include;[ "$dlok" = 1 ] && install_scribe || show_amtm menu;};;
								6)			case_6(){ c_e x3mRouting;g_m x3mRouting.mod include;[ "$dlok" = 1 ] && install_x3mRouting || show_amtm menu;};;
								7)			case_7(){ c_e 'unbound Manager';g_m unbound_manager.mod include;[ "$dlok" = 1 ] && install_unbound_manager || show_amtm menu;};;
								8)			case_8(){ g_m MerlinAU.mod include;[ "$dlok" = 1 ] && install_MerlinAU || show_amtm menu;};;
								[Jj]1)		case_j1(){ c_e connmon;g_m connmon.mod include;[ "$dlok" = 1 ] && install_connmon || show_amtm menu;};;
								[Jj]2)		case_j2(){ c_e ntpmerlin;g_m ntpmerlin.mod include;[ "$dlok" = 1 ] && install_ntpmerlin || show_amtm menu;};;
								[Jj]3)		case_j3(){ g_m scmerlin.mod include;[ "$dlok" = 1 ] && install_scmerlin || show_amtm menu;};;
								[Ww][Ii])	case_wi(){ g_m wicens.mod include;[ "$dlok" = 1 ] && install_wicens || show_amtm menu;};;
								[Jj]4)		case_j4(){ c_e spdMerlin;g_m spdmerlin.mod include;[ "$dlok" = 1 ] && install_spdmerlin || show_amtm menu;};;
								[Jj]5)		case_j5(){ g_m uiDivStats.mod include;[ "$dlok" = 1 ] && install_uiDivStats || show_amtm menu;};;
								[Jj]6)		case_j6(){ g_m uiScribe.mod include;[ "$dlok" = 1 ] && install_uiScribe || show_amtm menu;};;
								[Jj]7)		case_j7(){ g_m YazDHCP.mod include;[ "$dlok" = 1 ] && install_YazDHCP || show_amtm menu;};;
								[Vv][Nn])	case_vn(){ c_e Vnstat;g_m Vnstat.mod include;[ "$dlok" = 1 ] && install_Vnstat || show_amtm menu;};;
								[Vv][Pp])	case_vp(){ c_e VPNMON-R3;g_m vpnmon.mod include;[ "$dlok" = 1 ] && install_vpnmon || show_amtm menu;};;
								[Vv][Pp]2)	case_vp2(){ c_e VPNMON-R2;g_m vpnmon_r2.mod include;[ "$dlok" = 1 ] && install_vpnmon_r2 || show_amtm menu;};;
								[Kk][Mm])	case_km(){ c_e KILLMON;g_m killmon.mod include;[ "$dlok" = 1 ] && install_killmon || show_amtm menu;};;
								[Rr][Tt])	case_rt(){ c_e RTRMON;g_m rtrmon.mod include;[ "$dlok" = 1 ] && install_rtrmon || show_amtm menu;};;
								[Tt][Mm])	case_tm(){ c_e TAILMON;g_m tailmon.mod include;[ "$dlok" = 1 ] && install_tailmon|| show_amtm menu;};;
								[Bb][Mm])	case_bm(){ g_m backupmon.mod include;[ "$dlok" = 1 ] && install_backupmon || show_amtm menu;};;
								[Dd][Ii])	case_di(){ g_m dnscrypt.mod include;[ "$dlok" = 1 ] && install_dnscrypt || show_amtm menu;};;
								[Ww][Gg])	case_wg(){ c_e 'WireGuard Session Manager';g_m wireguard_manager.mod include;[ "$dlok" = 1 ] && install_wireguard_manager || show_amtm menu;};;
								[Aa][Gg])	case_ag(){ c_e 'Asuswrt-Merlin-AdGuardHome-Installer';g_m AdGuardHome.mod include;[ "$dlok" = 1 ] && install_AdGuardHome || show_amtm menu;};;
								[Ww][Ff])	case_wf(){ g_m WAN_Failover.mod include;[ "$dlok" = 1 ] && install_WAN_Failover || show_amtm menu;};;
								[Vv][Rr])	case_vr(){ g_m vpn_routing.mod include;[ "$dlok" = 1 ] && install_vpn_routing || show_amtm menu;};;
								[Ee][Pp])	case_ep(){ g_m entware_setup.mod include;[ "$dlok" = 1 ] && install_Entware || show_amtm menu;};;
								[Gg])		case_g(){ c_e 'router Games';g_m games.mod include;[ "$dlok" = 1 ] && install_Games || show_amtm menu;};;
								[Dd][Cc])	case_dc(){ g_m disk_check.mod include;[ "$dlok" = 1 ] && install_disk_check || show_amtm menu;};;
								[Ll][Cc])	case_lc(){ g_m led_control.mod include;[ "$dlok" = 1 ] && install_led_control || show_amtm menu;};;
								[Ee][Mm])	case_em(){ g_m email.mod include;[ "$dlok" = 1 ] && install_email || show_amtm menu;};;
								[Ff][Ww])	case_fw(){ g_m fw_update.mod include;[ "$dlok" = 1 ] && install_fw_update || show_amtm menu;};;
								[Ss][Cc])	case_sc(){ g_m sc_update.mod include;[ "$dlok" = 1 ] && install_sc_update || show_amtm menu;};;
								[Rr][Ss])	case_rs(){ g_m reboot_scheduler.mod include;[ "$dlok" = 1 ] && install_reboot_scheduler|| show_amtm menu;};;
								[Ss][Hh])	case_sh(){ g_m shell_history.mod include;[ "$dlok" = 1 ] && install_shell_history || show_amtm menu;};;
								[Rr][Dd])	case_rd(){ g_m router_date.mod include;[ "$dlok" = 1 ] && install_router_date || show_amtm menu;};;
							esac
						fi;;
		esac
	done
	set +f

	unset IFS swl swsize swpsize swtxt mpsw awmUpd cleanup
	gms(){ g_m swap.mod include;[ "$dlok" = 0 ] && show_amtm menu;}
	[ -f /jffs/scripts/post-mount ] && swl="$(grep -E "^swapon " /jffs/scripts/post-mount | awk '{print $2}')"
	if [ "$(wc -l < /proc/swaps)" -eq 2 ]; then
		if [ -f "$swl" ] && [ "$swl" = "$(sed -n '2p' /proc/swaps | awk '{print $1}')" ]; then
			if grep -qE "^swapon $swl" /jffs/scripts/post-mount; then
				swsize=$(du -h "$swl" | awk '{print $1}')
			else
				gms;check_swap
			fi
		else
			gms;check_swap
		fi
	elif [ -f /jffs/configs/fstab ] && grep -qF "swap" /jffs/configs/fstab; then
		gms;check_swap
	elif [ "$swl" ] && [ ! -f "$swl" ]; then
		gms;check_swap
	fi
	if [ "$swtxt" ] && ! grep -q 'do-not-check-swap' /jffs/scripts/post-mount; then
		a_m "$swtxt"
	fi
	if [ -f "$swl" ]; then
		atii=1
		[ -z "$su" -a -z "$ss" ] && printf "${GN_BG} sw${NC} %-9s%s ${GN}%s${NC} $swsize\\n" "manage" "Swap file" "$(echo "${swl#/tmp}" | sed 's|/myswap.swp||')"
		case_swp(){
			gms;manage_swap delete
		}
	elif [ "$swl" ] && [ "$swpsize" ]; then
		atii=1
		[ -z "$su" -a -z "$ss" ] && printf "${GN_BG}   ${NC} %-9s%s ${GN_BG}%s${NC}\\n" "Swap" "Partition" "${GN_BG}$swl${NC} ${swpsize}M"
		case_swp(){
			show_amtm " amtm does not manage swap partitions"
		}
	elif [ "$mpsw" ]; then
		atii=1
		[ -z "$su" -a -z "$ss" ] && printf "${GN_BG} sw${NC} %-9s%s ${GN_BG}%s${NC}\\n" "delete" "Swap files"
		case_swp(){
			gms;manage_swap multidelete
		}
	else
		[ "$ss" ] && printf "${E_BG} sw${NC} %-9s%s\\n" "create" "Swap file"
		case_swp(){
			gms;manage_swap create
		}
	fi

	[ "$atii" -a -z "$ss" -a -z "$su" ] && echo
	atii=

	[ -z "$su" -a -z "$ss" ] && printf "${GN_BG} cj${NC} %-9s%s\\n" "show" "all cron jobs"
	if [ "$ss" ]; then
		[ "$su" ] || printf "${GN_BG} i ${NC} %-9s%s\\n" "hide" "inactive scripts"
	else
		[ "$su" ] || printf "${E_BG} i ${NC} %-9s%s\\n" "show" "available scripts"
	fi

	if [ "$su" = 1 ]; then
		update_firmware
		update_amtm
		unset corr1 corr2
		if [ "$amtmUpd" = 0 ]; then
			vversion="${GN_BG} uu ${NC} force update"
			corr1=-2
		else
			[ "$theme" = solarized ] && corr2=+1
			vversion="        $version"
		fi
		printf "${GN_BG} m ${NC} %-9s%-$((21$corr2))s%$((COR$corr1))s\\n" "menu" "amtm  $vversion" "$thisrem"
	else
		echo
		if [ "$amtmUpate" ]; then
			printf "${GN_BG} uu${NC} %-9s%-$((21$corr2))s%$((COR$corr1))s\\n" "update" "amtm          $version" "${E_BG}$amtmUpate${NC}"
		else
			echo "    amtm options"
			[ "$ss" ] || printf "${GN_BG} u ${NC} update   ${GN_BG} rr${NC} reboot\\n"
		fi
		printf "${GN_BG} e ${NC} exit     ${GN_BG} t ${NC} theme  ${GN_BG} r ${NC} reset  ${GN_BG} a ${NC} about\\n"
	fi

	[ "$ss" ] && ssi=1 || ssi=
	unset ss atii upd
	if [ "$su" = 1 ]; then
		su=
		if [ "$suUpd" = 1 -o "$awmUpd" = 1 ] || [ "$amtmUpd" -gt 0 ]; then
			tpText="${R}Third-party script update(s) available!${NC} Use\\n the scripts own update function to update."
			[ "$awmUpd" = 1 ] && awmText="${R}Asuswrt-Merlin firmware update available!${NC}\\n See https://asuswrt-merlin.net/download"
			if [ "$amtmUpd" -gt 0 ]; then
				p_e_l
				if [ "$suUpd" = 1 ]; then
					printf " $tpText\\n"
					p_e_l
				fi
				if [ "$awmUpd" = 1 ]; then
					printf " $awmText\\n"
					p_e_l
				fi
				amtmUpdText="updated from $version to $amtmRemotever"
				[ "$amtmUpd" = 1 ] && printf " ${R}amtm $amtmRemotever is now available!${NC}\\n See https://diversion.ch for what's new.\\n"
				if [ "$amtmUpd" = 2 ]; then
					printf " ${R}amtm MD5 hash change detected${NC}\\n"
					amtmUpdText="MD5 update applied."
				fi
				echo
				MD5_info
				while true; do
					printf " Update amtm now? [1=Yes e=Exit] ";read -r continue
					case "$continue" in
						1)		break;;
						[Ee])	show_amtm menu;break;;
						*)		printf "\\n input is not an option\\n\\n";;
					esac
				done
				a_m "$amtmUpdText"
				g_i_m "${add}"
				[ -s "${add}"/availUpd.txt ] && . "${add}"/availUpd.txt
				if [ "$amtmUpate" ] && [ "$amtmMD5" != "$(md5sum "${add}"/a_fw/amtm.mod | awk '{print $1}')" ]; then
					[ -s "${add}"/availUpd.txt ] && sed -i '/^amtm.*/d' "${add}"/availUpd.txt
					unset amtmUpate amtmMD5
				fi
				[ "$tpw" = 1 ] && [ "$tps" = 1 ] && a_m "\\n For ${R}third-party script updates${NC}, use their\\n own update function."
				exec "$0" " amtm $am"
			else
				[ "$suUpd" = 1 ] && a_m " $tpText"
				[ "$suUpd" = 1 ] && [ "$awmUpd" = 1 ] && a_m " "
				[ "$awmUpd" = 1 ] && a_m " $awmText"
			fi
		else
			if [ "$updErr" = 1 ]; then
				a_m "\\n Update(s) aborted, could not retrieve version"
			else
				a_m " Everything's up to date ($(date +"%b %d %Y %R"))"
			fi
		fi
	fi
	[ "$sfp" = 1 ] && s_p "${add}"
	unset sfp dfc
	rm -f /tmp/amtm-dl

	if [ "$1" = menu ] && [ -z "$am" ] && [ -z "$MD5Show" ]; then
		p_e_l
	else
		p_e_l
		MD5_info
		if [ "$am" ]; then
			[ "$1" = menu ] && printf "$(echo "$am" | sed 's/^\\n//')\\n" || printf "$1\\n$am\\n"
			am=
		else
			printf "$1\\n"
		fi
		p_e_l
	fi

	while true; do
		printf "${R_BG} Enter amtm option ${NC} ";read -r selection
		s_d_u
		case "$selection" in
			1)					case_1;break;;
			2)					case_2;break;;
			3)					case_3;break;;
			4)					case_4;break;;
			5)					case_5;break;;
			6)					case_6;break;;
			7)					case_7;break;;
			8)					case_8;break;;
			[Jj]1)				case_j1;break;;
			[Jj]2)				case_j2;break;;
			[Jj]3)				case_j3;break;;
			[Jj]3u)				case_j3u;break;;
			[Ww][Ii])			case_wi;break;;
			[Jj]4)				case_j4;break;;
			[Jj]5)				case_j5;break;;
			[Jj]5u)				case_j5u;break;;
			[Jj]6)				case_j6;break;;
			[Jj]7)				case_j7;break;;
			[Vv][Nn])			case_vn;break;;
			[Vv][Pp])			case_vp;break;;
			[Vv][Pp]2)			case_vp2;break;;
			[Kk][Mm])			case_km;break;;
			[Rr][Tt])			case_rt;break;;
			[Tt][Mm])			case_tm;break;;
			[Bb][Mm])			case_bm;break;;
			[Aa][Ww][Mm])		show_amtm " Asuswrt-Merlin link for new firmware:\\n https://asuswrt-merlin.net/download";break;;
			[Ii])				c_ntp;if [ "$ssi" ]; then ss=;more=less;else ss=1;more=more;fi;show_amtm menu;break;;
			[Dd][Ii])			case_di;break;;
			[Ww][Gg])			case_wg;break;;
			[Aa][Gg])			case_ag;break;;
			[Ww][Ff])			case_wf;break;;
			[Vv][Rr])			case_vr;break;;
			[Ee][Pp])			case_ep;break;;
			[Uu])				c_ntp;[ -f "${add}"/availUpd.txt ] && rm "${add}"/availUpd.txt;tpw=1;su=1;suUpd=0;updErr=;show_amtm menu;break;;
			[Dd][Cc])			case_dc;break;;
			dcl|DCL)			s_l_f disk_check.log;break;;
			dce|DCE)			[ -f "${add}"/disk_check_err.log ] && rm "${add}"/disk_check_err.log;show_amtm "disk_check_err.log dismissed";break;;
			[Ff][Dd])			case_fd;break;;
			fdl|FDL)			s_l_f amtm-format-disk.log;break;;
			[Ll][Cc])			c_ntp;case_lc;break;;
			[Rr][Ss])			c_ntp;case_rs;break;;
			[Ss][Ww])			case_swp;break;;
			[Ee][Mm])			case_em;break;;
			[Ff][Ww])			case_fw;break;;
			[Ss][Cc])			case_sc;break;;
			[Gg])				if [ -f "${add}"/games/games.conf ]; then [ "$more" = "more" ] && more=less || more=more;show_amtm menu; else case_g;fi;break;;
			[Gg]r)				case_gr;break;;
			[Gg]1|[Gg]1r)		[ "$sgs" != "hide" ] && o_g_s || case_g1;break;;
			[Gg]2|[Gg]2r)		[ "$sgs" != "hide" ] && o_g_s || case_g2;break;;
			[Gg]3|[Gg]3r)		[ "$sgs" != "hide" ] && o_g_s || case_g3;break;;
			[Gg]4|[Gg]4r)		[ "$sgs" != "hide" ] && o_g_s || case_g4;break;;
			[Gg]5|[Gg]5r)		[ "$sgs" != "hide" ] && o_g_s || case_g5;break;;
			[Gg]6|[Gg]6r)		[ "$sgs" != "hide" ] && o_g_s || case_g6;break;;
			[Gg]7|[Gg]7r)		[ "$sgs" != "hide" ] && o_g_s || case_g7;break;;
			[Gg]8|[Gg]8r)		[ "$sgs" != "hide" ] && o_g_s || case_g8;break;;
			[Gg]9|[Gg]9r)		[ "$sgs" != "hide" ] && o_g_s || case_g9;break;;
			[Gg]10|[Gg]10r)		[ "$sgs" != "hide" ] && o_g_s || case_g10;break;;
			[Ss][Hh])			case_sh;break;;
			[Rr][Dd])			case_rd;break;;
			[Cc][Jj])			c_j;break;;
			[Tt]|[Cc][Tt])		theme_amtm;break;;
			[Mm])				show_amtm menu;break;;
			[Uu][Uu])			c_ntp;tpw=1;update_amtm;break;;
			[Rr])				reset_amtm;break;;
			[Aa])				about_amtm;break;;
			[Ee])				clear
								ascii_logo '  Goodbye'
								echo
								exit 0;break;;
			[Rr][Rr]|reboot)	p_e_l   # hidden, reboot router
								printf " OK then,\\n do you want to reboot this router now?\\n"
								c_d
								clear
								ascii_logo '  Rebooting...'
								printf "   amtm reboots this router now\\n\\n"
								service reboot >/dev/null 2>&1 &
								exit 0
								break;;
			[Rr][Nn])			clear # hidden, reboot router right now
								ascii_logo '  Rebooting...'
								printf "   amtm reboots this router now\\n\\n"
								service reboot >/dev/null 2>&1 &
								exit 0
								break;;
			beta)				# hidden, use BETA or RELEASE server
								if c_url https://diversion.ch/amtm_fw_beta/amtm_fw_beta | grep -q '^# beta'; then
									c_url -Os https://diversion.ch/amtm_fw_beta/amtm_fw_beta
									. amtm_fw_beta
								else
									show_amtm " No BETA version to test at this time."
								fi
								break;;
			local)				# hidden, only use if you ARE thelonelycoder
								c_url -Os http://diversion.test/verify
								if [ -f verify ] && grep -q '01081291' verify; then
									. verify
								else
									rm -f verify
									show_amtm " You are not thelonelycoder!"
								fi
								break;;
			*)					printf "\\n                    input is not an option\\n\\n";;
		esac
	done
}

c_j(){
	p_e_l
	printf "\\n The following cron jobs are active (cru l):\\n"
	p_e_l
	if [ ! "$(ls -A /var/spool/cron/crontabs)" ] || [ ! -s "/var/spool/cron/crontabs/$(nvram get http_username)" ]; then
		echo " (there are no cron jobs set at the moment)"
		p_e_l
	else
		printf " .---------------- minute       (0 - 59)\\n |  .------------- hour         (0 - 23)\\n |  |  .---------- day of month (1 - 31)\\n"
		printf " |  |  |  .------- month        (1 - 12) OR Jan,Feb,mar ...\\n |  |  |  |  .---- day of week  (0 - 6) Sunday = 0 or 7, OR Sun,mon,Tue ...\\n"
		printf " |  |  |  |  |\\n *  *  *  *  *  command to be executed  #job_name#  ( * = every ... )\\n\\n"
		cru l | sed 's/^/ /'
	fi
	p_e_t "return to menu"
	show_amtm menu
}

MD5_info(){
	if [ "$MD5Show" ]; then
		printf " Info: ${E_BG} MD5 upd ${NC} = Script file hash change.\\n\\n"
		MD5Show=
	fi
}

s_l_f(){
	if [ -f "${add}/$1" ]; then
		slfLine=---------------------------------------------------
		p_e_l
		printf " $1 has this content:\\n\\n START FILE\\n"
		p_e_l
		sed -e 's/^/ /' "${add}/$1"
		p_e_l
		printf " END FILE\\n"
		p_e_l
		if [ "$1" = .ash_history ]; then
			p_e_t "return to menu"
		else
			while true; do
				printf " Delete log file now? [1=Yes e=Exit] ";read -r continue
				case "$continue" in
					1)		rm -f "${add}/$1"
							[ "$1" = disk_check.log ] && rm -f "${add}"/disk_check_err.log
							show_amtm " $1 deleted"
							break;;
					[Ee])	show_amtm menu;break;;
					*)		printf "\\n input is not an option\\n\\n";;
				esac
			done
		fi
	else
		show_amtm " No $1 found"
	fi
}

script_check(){
	atii=1
	[ "$localVother" ] && localver=$localVother || localver="$(grep "$scriptgrep" "$scriptloc" | grep -m1 -oE '[0-9]{1,2}([.][0-9]{1,2})([.][0-9]{1,2})')"
	upd="${E_BG}${NC}$localver"
	lvtpu=$localver
	if [ "$su" = 1 ]; then
		if c_url "$remoteurl" | grep -qF -m1 "$grepcheck"; then
			[ "$remoteVother" ] && remotever=$remoteVother || remotever="$(c_url "$remoteurl" | grep -m1 "$scriptgrep" | grep -oE '[0-9]{1,2}([.][0-9]{1,2})([.][0-9]{1,2})')"
			localmd5="$(md5sum "$scriptloc" | awk '{print $1}')"
			upd="${GN_BG}$localver${NC}"
			if [ "$(v_c $localver)" -gt "$(v_c $remotever)" ]; then
				upd="${E_BG}<- $remotever${NC}"
				tpUpd="<- $remotever"
				[ "$tpu" ] && echo "- $scriptname $localver <- $remotever <br>" >>/tmp/amtm-tpu-check
				suUpd=1
			elif [ "$(v_c $localver)" -lt "$(v_c $remotever)" ]; then
				upd="${E_BG}-> $remotever${NC}"
				tpUpd="-> $remotever"
				[ "$tpu" ] && echo "- $scriptname $localver -> $remotever <br>" >>/tmp/amtm-tpu-check
				suUpd=1
			else
				if grep -q '^# amtm NoMD5check' "$scriptloc"; then
					localver="No MD5"
				else
					[ "$remoteurlmd5" ] && remoteurl=$remoteurlmd5
					remotemd5="$(c_url "$remoteurl" | md5sum | awk '{print $1}')"
					if [ "$localmd5" != "$remotemd5" ]; then
						upd="${E_BG}-> MD5 upd${NC}"
						tpUpd="-> MD5 upd"
						[ "$tpu" ] && echo "- $scriptname $localver, MD5 update available <br>" >>/tmp/amtm-tpu-check
						suUpd=1;MD5Show=1
					else
						localver=
					fi
				fi
			fi
			if [ -z "$tpu" -o "$updcheck" ] && [ "$tpUpd" ]; then
				echo "$(echo $scriptname | sed -e 's/ /_/g;s/\//_/g')Upate=\"$tpUpd\"">>"${add}"/availUpd.txt
				echo "$(echo $scriptname | sed -e 's/ /_/g;s/\//_/g')MD5=\"$localmd5\"">>"${add}"/availUpd.txt
			fi
		else
			upd=" ${E_BG}upd err${NC}"
			updErr=1
			a_m " ! $scriptname: ${R}$(echo $remoteurl | awk -F[/:] '{print $4}')${NC} unreachable"
		fi
	else
		localver=
	fi
	unset tpUpd localVother remoteVother remotever localmd5 remotemd5 remoteurlmd5
}

reset_amtm(){
	rm_entware() {
		if [ -f "/jffs/scripts/services-stop" ]; then
			[ -f /opt/etc/init.d/rc.unslung ] && /opt/etc/init.d/rc.unslung stop
			sed -i '/rc.unslung stop/d' /jffs/scripts/services-stop
			r_w_e /jffs/scripts/services-stop
		fi
		rm -rf "$(readlink /tmp/opt)"
		# if readlink above returns nothing we try it the hard way.
		opkgFile=$(/usr/bin/find /mnt/*/entware/bin/opkg 2> /dev/null)
		if [ -f "$opkgFile" ]; then
			rm -rf "${opkgFile%/bin/opkg}"
		else
			opkgUnknown=$(/usr/bin/find /mnt/*/entware*/bin/opkg 2> /dev/null)
			[ "$opkgUnknown" ] && rm -rf "${opkgUnknown%/bin/opkg}"
		fi
		# remove dead /opt if it still exists after all the hard work above
		if [ -L /tmp/opt ]; then
			rm -f /tmp/opt 2> /dev/null
			rm -f /opt 2> /dev/null
		fi
	}

	p_e_l
	printf " amtm reset options\\n\\n Enter option for more info.\\n\\n Use ${E_BG} i ${NC} to see the list of third-party\\n and amtm's own (non third-party) scripts.\\n\\n"
	printf " 1. Reset amtm.\\n    This resets amtm and its own settings.\\n    Third-party scripts are NOT affected.\\n\\n"
	printf " 2. Reset amtm, remove scripts and Entware.\\n    This resets amtm and its own settings\\n    and removes all third-party scripts,\\n    including Entware (if installed).\\n    Third-party scripts WILL be removed.\\n\\n"
	printf " 3. Remove Entware.\\n    This removes the Entware repository.\\n    Third-party scripts depending on Entware\\n    may no longer work after removing.\\n"
	while true; do
		printf "\\n Enter selection [1-3 e=Exit] ";read -r continue
		case "$continue" in
			1)		p_e_l
					printf " This resets all amtm settings.\\n\\n Note that resetting amtm will NOT remove or\\n uninstall any third-party scripts.\\n\\n"
					printf " However, when found it will remove the Disk\\n check script and log, the Format disk log,\\n the Reboot scheduler, the LED control and\\n"
					printf " email settings you may have set.\\n"
					c_d
					if [ -f /jffs/scripts/pre-mount ] && grep -q "disk_check.mod run # Added by amtm" /jffs/scripts/pre-mount; then
						sed -i '\~disk_check.mod run # Added by amtm~d' /jffs/scripts/pre-mount
						r_w_e /jffs/scripts/pre-mount
					fi
					if [ -f /jffs/scripts/init-start ] && grep -q "amtm_RebootScheduler" /jffs/scripts/init-start; then
						sed -i '\~amtm_RebootScheduler~d' /jffs/scripts/init-start
						r_w_e /jffs/scripts/init-start
						cru d amtm_RebootScheduler
					fi
					if [ -f /jffs/scripts/init-start ] && grep -q "routerdate restore" /jffs/scripts/init-start; then
						sed -i '\~routerdate restore~d' /jffs/scripts/init-start
						r_w_e /jffs/scripts/init-start
						cru d amtm_RouterDate
					fi
					if [ -f /jffs/scripts/services-stop ] && grep -q "routerdate save" /jffs/scripts/services-stop; then
						sed -i '\~routerdate save~d' /jffs/scripts/services-stop
						r_w_e /jffs/scripts/services-stop
					fi
					if [ -f "${add}"/led_control.mod ]; then
						sh "${add}"/led_control.mod -on -p >/dev/null 2>&1
						rm "${add}"/led*
						if [ "$auraLED" ] && [ "$(nvram get ledg_scheme)" = 0 -a "$(nvram get ledg_scheme_old)" ]; then
							nvram set ledg_scheme=$(nvram get ledg_scheme_old)
							nvram commit
							service restart_leds
							sleep 1
						fi
						cru d amtm_LEDcontrol_on
						cru d amtm_LEDcontrol_off
						cru d amtm_LEDcontrol_update
						if [ "$(nvram get led_disable)" = 1 ]; then
							nvram set led_disable=0
							nvram commit
							service restart_leds
						fi
					fi
					if [ -f /jffs/scripts/services-start ] && grep -q "${add}/led.*" /jffs/scripts/services-start; then
						sed -i "\~${add}/led.*~d" /jffs/scripts/services-start
						r_w_e /jffs/scripts/services-start
					fi
					if [ -f /jffs/scripts/services-start ] && grep -q "^/bin/sh ${add}/shell_history.mod" /jffs/scripts/services-start; then
						sed -i "\~${add}/shell.*~d" /jffs/scripts/services-start
						r_w_e /jffs/scripts/services-start
						rm -f /home/root/.ash_history /tmp/amtm_sort_s_h
					fi
					if [ -f /jffs/scripts/update-notification ] && grep -q "created by amtm" /jffs/scripts/update-notification; then
						rm -f /jffs/scripts/update-notification
					fi
					[ -f "$shared_amtm_wl" ] && rm -f "$shared_amtm_wl"
					rm -rf "${add}"

					clear
					ascii_logo "  amtm settings reset"
					echo
					echo "   Goodbye!"
					echo
					exit 0
					break;;
			2)		p_e_l
					printf " This resets amtm and removes all\\n third-party scripts including Entware (if\\n installed) from this router.\\n\\n"
					printf " Note that this option will NOT restore the\\n router settings (NVRAM) to default.\\n\\n It empties these directories:\\n"
					printf " - /jffs/addons\\n - /jffs/configs\\n - /jffs/scripts\\n\\n Additionally if found it removes:\\n"
					printf " - directory /jffs/dnscrypt\\n - directory /mnt/*/skynet\\n - Entware repository\\n - the SWAP file\\n\\n The router automatically reboots after this.\\n"
					c_d
					rm_entware
					if [ -f "$swl" ]; then
						sync; echo 3 > /proc/sys/vm/drop_caches
						swapoff "$swl"
						rm -f "$swl"
					fi
					if [ -f /jffs/scripts/services-start ] && grep -q "${add}/led.*" /jffs/scripts/services-start; then
						if [ "$auraLED" ] && [ "$(nvram get ledg_scheme)" = 0 -a "$(nvram get ledg_scheme_old)" ]; then
							nvram set ledg_scheme=$(nvram get ledg_scheme_old)
							nvram commit
						fi
						if [ "$(nvram get led_disable)" = 1 ]; then
							nvram set led_disable=0
							nvram commit
						fi
					fi
					rm -rf /jffs/configs/*
					rm -rf /jffs/scripts/*
					rm -rf /jffs/addons/*
					rm -rf /jffs/dnscrypt
					skynetcfg=$(/usr/bin/find /mnt/*/skynet/skynet.cfg 2> /dev/null)
					[ -f "$skynetcfg" ] && rm -rf "${skynetcfg%/skynet.cfg}"

					trap '' 2
					clear
					ascii_logo '  Everything reset and removed. Goodbye!'
					printf "\\n   amtm reboots this router now\\n\\n"
					service reboot >/dev/null 2>&1 &
					exit 0
					break;;
			3)		p_e_l
					printf " This removes Entware from this router.\\n\\n Beware that if you have scripts installed\\n that depend on Entware that they no longer\\n"
					printf " work after removing.\\n\\n You have been warned.\\n\\n The router automatically reboots after this.\\n"
					c_d
					if [ -f /jffs/scripts/post-mount ]; then
						sed -i '/mount-entware./d' /jffs/scripts/post-mount
						r_w_e /jffs/scripts/post-mount
					fi
					if [ -d /jffs/addons/diversion ]; then
						rm -f /jffs/addons/diversion/mount-entware.div
						[ "$(ls -A /jffs/addons/diversion)" ] || rm -rf /jffs/addons/diversion
					fi
					r_m mount-entware.mod
					[ -L /tmp/opt ] && rmText="Removed all traces of Entware" || rmText="Entware not found but removed all traces if found"
					rm_entware

					trap '' 2
					clear
					printf "\\n $rmText.\\n amtm reboots this router now\\n\\n"
					service reboot >/dev/null 2>&1 &
					exit 0
					break;;
			[Ee])	show_amtm menu;break;;
			*)		printf "\\n input is not an option\\n";;
		esac
	done
}

update_amtm(){
	urlNOK=
	if ! c_url "$amtmURL/amtm.mod" | grep -q "^version="; then
		urlNOK=1
		f_b_url
	fi
	if [ "$urlNOK" ] && ! c_url "$amtmURL/amtm.mod" | grep -q "^version="; then
		if [ "$su" = 1 ]; then
			updErr=1
			thisrem=" ${E_BG}upd err${NC}"
			amtmUpd=0
			a_m " ! amtm: ${R}$(echo $amtmURL | awk -F[/:] '{print $4}')${NC} unreachable"
		else
			show_amtm " ! amtm: ${R}$(echo $amtmURL | awk -F[/:] '{print $4}')${NC} unreachable"
		fi
	else
		urlNOK=
	fi
	dfc=
	if [ -z "$urlNOK" ]; then
		amtmRemotever="$(c_url "$amtmURL/amtm.mod" | grep "^version=" | sed -e 's/version=//')"
		localmd5="$(md5sum "${add}"/a_fw/amtm.mod | awk '{print $1}')"
		remotemd5="$(c_url "$amtmURL/amtm.mod" | md5sum | awk '{print $1}')"

		if [ "$su" = 1 ]; then
			if [ "$version" != "$amtmRemotever" ]; then
				thisrem="${E_BG}-> $amtmRemotever${NC}"
				thisUpd="-> $amtmRemotever"
				[ "$updcheck" ] && echo "- amtm $version $thisUpd" >>/tmp/amtm-tpu-check
				amtmUpd=1
			elif [ "$localmd5" != "$remotemd5" ]; then
				thisrem="${E_BG}-> MD5 upd${NC}"
				thisUpd="-> MD5 upd"
				[ "$updcheck" ] && echo "- amtm $version, MD5 hash change detected" >>/tmp/amtm-tpu-check
				amtmUpd=2;MD5Show=1
			else
				thisrem="${GN_BG}$version${NC}"
				amtmUpd=0
			fi
			if [ "$amtmUpd" -gt 0 ]; then
				echo "amtmUpate=\"$thisUpd\"">>"${add}"/availUpd.txt
				echo "amtmMD5=\"$localmd5\"">>"${add}"/availUpd.txt
			fi
		else
			if [ "$version" != "$amtmRemotever" ]; then
				a_m "updated from $version to $amtmRemotever"
			elif [ "$localmd5" != "$remotemd5" ]; then
				a_m "MD5 update applied"
			else
				a_m "force updated to $amtmRemotever"
			fi
			g_i_m "${add}"
			[ -s "${add}"/availUpd.txt ] && . "${add}"/availUpd.txt
			if [ "$amtmUpate" ] && [ "$amtmMD5" != "$(md5sum "${add}"/a_fw/amtm.mod | awk '{print $1}')" ]; then
				[ -s "${add}"/availUpd.txt ] && sed -i '/^amtm.*/d' "${add}"/availUpd.txt
				unset amtmUpate amtmMD5
			fi
			[ "$tpw" = 1 ] && [ "$tps" = 1 ] && a_m "\\n For ${R}third-party script updates${NC}, use their\\n own update function."
			tpw=
			exec "$0" " amtm $am"
		fi
	fi
}

update_firmware(){
	[ "$updcheck" ] && rm -f "${add}"/availUpd.txt
	awmBuildno=$(nvram get buildno)
	if [ "$(/bin/uname -o | grep -iw Merlin$)" -a "$(v_c $awmBuildno)" -ge "$(v_c 382)" ]; then
		awmWSI=$(nvram get webs_state_info)
		awmInstalled="$awmBuildno.$(nvram get extendno)"
		if [ "$awmWSI" ]; then
			awmStable=$(echo $awmWSI | sed 's/3004_//' | sed 's/_/./g')
			awmBaseVer=$(echo $awmStable | cut -d'.' -f1-2)
			if [ "$(v_c $awmBaseVer)" -gt "$(v_c $awmBuildno)" ]; then
				availRel="release avail.";stcol=${E_BG};awmUpd=1
			elif [ "$awmBaseVer" = "$awmBuildno" ]; then
				if echo "$(nvram get extendno)" | grep -q 'alpha\|beta'; then
					availRel="release avail.";stcol=${E_BG};awmUpd=1
				elif [ "$(v_c $awmStable)" -gt "$(v_c $awmInstalled)" ]; then
					availRel="release avail.";stcol=${E_BG};awmUpd=1
				else
					availRel=firmware;stcol=${GN_BG}
				fi
			else
				availRel=firmware;stcol=${GN_BG}
				[ "$(echo "$awmInstalled" | grep 'alpha\|beta')" ] && availRel="no release yet"
				awmStable=$awmInstalled
			fi
			[ "$awmUpd" = 1 ] && [ "$updcheck" ] && echo "- Asuswrt-Merlin $availRel $awmStable" >>/tmp/amtm-tpu-check
		else
			availRel=firmware;stcol=${GN_BG}
			[ "$(echo "$awmInstalled" | grep 'alpha\|beta')" ] && availRel="no release yet"
			awmStable=$awmInstalled
		fi
		[ -z "$updcheck" ] && printf "${GN_BG}awm${NC} %-15s%-15s%${COR}s\\n\\n" "Asuswrt-Merlin" "$availRel" " ${stcol}$awmStable${NC}"
	fi
}
#eof
