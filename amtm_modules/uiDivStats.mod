#!/bin/sh
#bof
uiDivStats_installed(){
	scriptgrep=' SCRIPT_VERSION='
	if [ "$su" = 1 ]; then
		remoteurl=https://raw.githubusercontent.com/AMTM-OSR/uiDivStats/master/uiDivStats.sh
		grepcheck=jackyaz
	fi
	script_check
	if [ -z "$su" -a -z "$tpu" ] && [ "$uiDivStatsUpdate" ]; then
		localver="$lvtpu"
		upd="${E_BG}$uiDivStatsUpdate${NC}"
		if [ "$uiDivStatsMD5" != "$(md5sum "$scriptloc" | awk '{print $1}')" ]; then
			sed -i '/^uiDivStats.*/d' "${add}"/availUpd.txt
			upd="${E_BG}${NC}$lvtpu"
			unset localver uiDivStatsUpdate uiDivStatsMD5
		fi
	fi
	[ -z "$updcheck" -a -z "$ss" ] && printf "${GN_BG} j5${NC} %-9s%-21s%${COR}s\\n" "open" "uiDivStats    $localver" " $upd"
	case_j5(){
		/jffs/scripts/uiDivStats
		sleep 2
		show_amtm menu
	}
}
install_uiDivStats(){
	p_e_l
	printf " This installs uiDivStats - WebUI for Diversion statistics\\n on your router.\\n\\n"
	printf " Original Author: Jack Yaz\\n snbforums.com/forums/asuswrt-merlin-addons.60/?prefix_id=15&starter_id=53009\\n\\n"
	printf " This script is now maintained by the AMTM-OSR team,\\n the AMTM Orphaned Script Revival repository.\\n"
	printf " Visit and learn more about their mission here:\\n https://github.com/AMTM-OSR\\n"
	c_d

	if [ -f /opt/bin/diversion ]; then
		c_url https://raw.githubusercontent.com/AMTM-OSR/uiDivStats/master/uiDivStats.sh -o "/jffs/scripts/uiDivStats" && chmod 0755 /jffs/scripts/uiDivStats && /jffs/scripts/uiDivStats install
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
