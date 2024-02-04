#!/bin/sh
#bof
ntpmerlin_installed(){
	scriptname=ntpMerlin
	scriptgrep=' SCRIPT_VERSION='
	if [ "$su" = 1 ]; then
		remoteurl=https://jackyaz.io/ntpMerlin/master/amtm-version/ntpmerlin.sh
		remoteurlmd5=https://jackyaz.io/ntpMerlin/master/amtm-md5/ntpmerlin.sh
		grepcheck=jackyaz
	fi
	script_check
	if [ -z "$su" -a -z "$tpu" ] && [ "$ntpMerlinUpate" ]; then
		localver="$lvtpu"
		upd="${E_BG}$ntpMerlinUpate${NC}"
		if [ "$ntpMerlinMD5" != "$(md5sum "$scriptloc" | awk '{print $1}')" ]; then
			sed -i '/^ntpMerlin.*/d' "${add}"/availUpd.txt
			upd="${E_BG}${NC}$lvtpu"
			unset localver ntpMerlinUpate ntpMerlinMD5
		fi
	fi
	[ -z "$updcheck" -a -z "$ss" ] && printf "${GN_BG} j2${NC} %-9s%-21s%${COR}s\\n" "open" "ntpMerlin     $localver" " $upd"
	case_j2(){
		/jffs/scripts/ntpmerlin
		sleep 2
		show_amtm menu
	}
}
install_ntpmerlin(){
	p_e_l
	printf " This installs ntpMerlin - Installer for kvic\\n NTP Daemon on your router.\\n\\n"
	printf " Author: Jack Yaz\\n snbforums.com/forums/asuswrt-merlin-addons.60/?prefix_id=22&starter_id=53009\\n"
	c_d
	c_url https://jackyaz.io/ntpMerlin/master/amtm-install/ntpmerlin.sh -o "/jffs/scripts/ntpmerlin" && chmod 0755 /jffs/scripts/ntpmerlin && /jffs/scripts/ntpmerlin install
	sleep 2
	if [ -f /jffs/scripts/ntpmerlin ]; then
		show_amtm " ntpMerlin installed"
	else
		am=;show_amtm " ntpMerlin installation failed"
	fi
}
#eof
