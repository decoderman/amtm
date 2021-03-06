#!/bin/sh
#bof
ntpmerlin_installed(){
	scriptname=ntpMerlin
	scriptgrep=' SCRIPT_VERSION='
	if [ "$su" = 1 ]; then
		remoteurl="https://raw.githubusercontent.com/jackyaz/ntpMerlin/master/ntpmerlin.sh"
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
	printf "${GN_BG} j2${NC} %-9s%-21s%${COR}s\\n" "open" "ntpMerlin     $localver" " $upd"
	case_j2(){
		/jffs/scripts/ntpmerlin
		sleep 2
		show_amtm menu
	}
}
install_ntpmerlin(){
	p_e_l
	echo " This installs ntpMerlin - Installer for kvic NTP Daemon"
	echo " on your router."
	echo
	echo " Author: Jack Yaz"
	echo " https://www.snbforums.com/forums/asuswrt-merlin-addons.60/"
	c_d

	c_url "https://raw.githubusercontent.com/jackyaz/ntpMerlin/master/ntpmerlin.sh" -o "/jffs/scripts/ntpmerlin" && chmod 0755 /jffs/scripts/ntpmerlin && /jffs/scripts/ntpmerlin install
	sleep 2
	if [ -f /jffs/scripts/ntpmerlin ]; then
		show_amtm " ntpMerlin installed"
	else
		am=;show_amtm " ntpMerlin installation failed"
	fi
}
#eof
