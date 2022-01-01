#!/bin/sh
#bof
uiDivStats_installed(){
	scriptname=uiDivStats
	scriptgrep=' SCRIPT_VERSION='
	if [ "$su" = 1 ]; then
		remoteurl=https://jackyaz.io/uiDivStats/master/amtm-version/uiDivStats.sh
		remoteurlmd5=https://jackyaz.io/uiDivStats/master/amtm-md5/uiDivStats.sh
		grepcheck=jackyaz
	fi
	script_check
	if [ -z "$su" -a -z "$tpu" ] && [ "$uiDivStatsUpate" ]; then
		localver="$lvtpu"
		upd="${E_BG}$uiDivStatsUpate${NC}"
		if [ "$uiDivStatsMD5" != "$(md5sum "$scriptloc" | awk '{print $1}')" ]; then
			sed -i '/^uiDivStats.*/d' "${add}"/availUpd.txt
			upd="${E_BG}${NC}$lvtpu"
			unset localver uiDivStatsUpate uiDivStatsMD5
		fi
	fi
	[ -z "$updcheck" ] && printf "${GN_BG} j5${NC} %-9s%-21s%${COR}s\\n" "open" "uiDivStats    $localver" " $upd"
	case_j5(){
		/jffs/scripts/uiDivStats
		sleep 2
		show_amtm menu
	}
}
install_uiDivStats(){
	p_e_l
	echo " This installs uiDivStats - WebUI for Diversion statistics"
	echo " on your router."
	echo
	echo " Author: Jack Yaz"
	echo " https://www.snbforums.com/forums/asuswrt-merlin-addons.60/?prefix_id=15&starter_id=53009"
	c_d

	if [ -f /opt/bin/diversion ]; then
		c_url https://jackyaz.io/uiDivStats/master/amtm-install/uiDivStats.sh -o "/jffs/scripts/uiDivStats" && chmod 0755 /jffs/scripts/uiDivStats && /jffs/scripts/uiDivStats install
		sleep 2
	else
		am=;show_amtm " uiDivStats installation failed,\\n Diversion is not installed"
	fi
	if [ -f /jffs/scripts/uiDivStats ]; then
		show_amtm " uiDivStats installed"
	else
		am=;show_amtm " uiDivStats installation failed"
	fi
}
#eof
