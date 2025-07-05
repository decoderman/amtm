#!/bin/sh
#bof
wxmon_installed(){
	scriptname=wxmon
	localVother="$(grep ^version "$scriptloc" | sed -e 's/version=//;s/"//g')"
	if [ "$su" = 1 ]; then
		remoteurl=https://raw.githubusercontent.com/ViktorJp/WXMON/master/wxmon.sh
		remoteVother="$(c_url "$remoteurl" | grep ^version | sed -e 's/version=//;s/"//g')"
		grepcheck=ViktorJp
	fi
	script_check
	if [ -z "$su" -a -z "$tpu" ] && [ "$wxmonUpate" ]; then
		localver="$lvtpu"
		upd="${E_BG}$wxmonUpate${NC}"
		if [ "$wxmonMD5" != "$(md5sum "$scriptloc" | awk '{print $1}')" ]; then
			[ -f "${add}"/availUpd.txt ] && sed -i '/^wxmon.*/d' "${add}"/availUpd.txt
			upd="${E_BG}${NC}$lvtpu"
			unset localver wxmonUpate wxmonMD5
		fi
	fi
	[ -z "$updcheck" -a -z "$ss" ] && printf "${GN_BG} wx${NC} %-9s%-21s%${COR}s\\n" "open" "WXMON     $localver" " $upd"
	case_wx(){
		trap trap_ctrl 2
		trap_ctrl(){
			sleep 2
			echo "${NC}"
			exec "$0"
		}
		/jffs/scripts/wxmon.sh
		trap - 2
		sleep 2
		show_amtm menu
	}
}
install_wxmon(){
	p_e_l
	printf " This installs WXMON - Localized Weather Monitoring, extended forecasts, including aviation METARs and TAFs! (US/Global!)\\n on your router.\\n\\n"
	printf " Author: Viktor Jaep\\n snbforums.com/threads/release-wxmon-v2-1-1-jul-3-2025-localized-weather-monitoring-extended-forecasts-including-aviation-metars-and-tafs-us-global.83479/\\n"
	c_d
	c_url https://raw.githubusercontent.com/ViktorJp/WXMON/master/wxmon.sh -o /jffs/scripts/wxmon.sh && chmod a+rx /jffs/scripts/wxmon.sh && /jffs/scripts/wxmon.sh -setup

	sleep 2
	if [ -f /jffs/scripts/wxmon.sh ]; then
		show_amtm " WXMON  installed"
	else
		am=;show_amtm " WXMON  installation failed"
	fi
}
#eof
