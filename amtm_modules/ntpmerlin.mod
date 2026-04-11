#!/bin/sh
#bof
ntpMerlin_installed(){
	[ -f "${add}"/ntpmerlin.mod ] && rm -rf "${add}"/ntpmerlin.mod
	scriptgrep=' SCRIPT_VERSION='
	if [ "$su" = 1 ]; then
		remoteurl=https://raw.githubusercontent.com/AMTM-OSR/ntpMerlin/master/ntpmerlin.sh
		grepcheck=jackyaz
	fi
	script_check
	if [ -z "$su" -a -z "$tpu" ] && [ "$ntpMerlinUpdate" ]; then
		localver="$lvtpu"
		upd="${E_BG}$ntpMerlinUpdate${NC}"
		if [ "$ntpMerlinMD5" != "$(md5sum "$scriptloc" | awk '{print $1}')" ]; then
			[ -f "${add}"/availUpd.txt ] && sed -i '/^ntpMerlin.*/d' "${add}"/availUpd.txt
			upd="${E_BG}${NC}$lvtpu"
			unset localver ntpMerlinUpdate ntpMerlinMD5
		fi
	fi
	[ -z "$updcheck" -a -z "$ss" ] && printf "${GN_BG} j2${NC} %-9s%-21s%${COR}s\\n" "open" "ntpMerlin     $localver" " $upd"
	case_j2(){
		/jffs/scripts/ntpmerlin
		sleep 2
		show_amtm menu
	}
}
install_ntpMerlin(){
	p_e_l
	printf " This installs ntpMerlin - Installer for kvic\\n NTP Daemon on your router.\\n\\n"
	printf " Original Author: Jack Yaz\\n snbforums.com/forums/asuswrt-merlin-addons.60/?prefix_id=22&starter_id=53009\\n\\n"
	printf " This script is now maintained by the AMTM-OSR team,\\n the AMTM Orphaned Script Revival repository.\\n"
	printf " Visit and learn more about their mission here:\\n https://github.com/AMTM-OSR\\n"
	c_d
	c_url https://raw.githubusercontent.com/AMTM-OSR/ntpMerlin/master/ntpmerlin.sh -o "/jffs/scripts/ntpmerlin" && chmod 0755 /jffs/scripts/ntpmerlin && /jffs/scripts/ntpmerlin install
	sleep 2
	if [ -f /jffs/scripts/ntpmerlin ]; then
		show_amtm " ntpMerlin installed"
	else
		am=;show_amtm " ntpMerlin installation failed"
	fi
}
#eof
