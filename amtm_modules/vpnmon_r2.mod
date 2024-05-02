#!/bin/sh
#bof
vpnmon_r2_installed(){
	scriptname=vpnmon_r2
	localVother="$(grep ^Version "$scriptloc" | awk '{print $1}' | sed -e 's/Version=//;s/"//g')"
	sunset=', sunsetted'
	if [ "$su" = 1 ]; then
		sunset=
		remoteurl=https://raw.githubusercontent.com/ViktorJp/VPNMON-R2/main/vpnmon-r2.sh
		remoteVother="$(c_url "$remoteurl" | grep ^Version | awk '{print $1}' | sed -e 's/Version=//;s/"//g')"
		grepcheck=VPNMON-R2
	fi
	script_check
	if [ -z "$su" -a -z "$tpu" ]; then
		if [ "$vpnmonUpate" ]; then
			[ -f "${add}"/availUpd.txt ] && sed -i '/^vpnmonU.*/d;/^vpnmonM.*/d' "${add}"/availUpd.txt
			unset localver vpnmonUpate vpnmonMD5
		fi
		if [ "$vpnmon_r2Upate" ]; then
			sunset=
			localver="$lvtpu"
			upd="${E_BG}$vpnmon_r2Upate${NC}"
			if [ "$vpnmon_r2MD5" != "$(md5sum "$scriptloc" | awk '{print $1}')" ]; then
				sed -i '/^vpnmon_r2.*/d' "${add}"/availUpd.txt
				upd="${E_BG}${NC}$lvtpu"
				unset localver vpnmon_r2Upate vpnmon_r2MD5
				sunset=', sunsetted'
			fi
		fi
	fi
	[ -z "$updcheck" -a -z "$ss" ] && printf "${GN_BG}vp2${NC} %-9s%-21s%${COR}s\\n" "open" "VPNMON-R2$sunset $localver" " $upd"
	case_vp2(){
		trap trap_ctrl 2
		trap_ctrl(){
			sleep 2
			echo "${NC}"
			exec "$0"
		}
		/jffs/scripts/vpnmon-r2.sh -setup
		trap - 2
		sleep 2
		show_amtm menu
	}
}
install_vpnmon_r2(){
	am=;show_amtm " ! VPNMON-R2 is sunsetted, install\\n VPNMON-R3 instead with ${GN_BG} vp ${NC}"
}
#eof
