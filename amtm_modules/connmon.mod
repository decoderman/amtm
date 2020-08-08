#!/bin/sh
#bof
connmon_installed(){
	scriptname=connmon
	scriptgrep=' SCRIPT_VERSION='
	if [ "$su" = 1 ]; then
		remoteurl="https://raw.githubusercontent.com/jackyaz/connmon/master/connmon.sh"
		grepcheck=jackyaz
	fi
	script_check
	if [ -z "$su" -a -z "$tpu" ] && [ "$connmonUpate" ]; then
		localver="$lvtpu"
		upd="${E_BG}$connmonUpate${NC}"
		if [ "$connmonMD5" != "$(md5sum "$scriptloc" | awk '{print $1}')" ]; then
			sed -i '/^connmon.*/d' "${add}"/availUpd.txt
			upd="${E_BG}${NC}$lvtpu"
			unset localver connmonUpate connmonMD5
		fi
	fi
	printf "${GN_BG} j1${NC} %-9s%-21s%${COR}s\\n" "open" "connmon       $localver" " $upd"
	case_j1(){
		/jffs/scripts/connmon
		sleep 2
		show_amtm menu
	}
}
install_connmon(){
	p_e_l
	echo " This installs connmon - Internet connection monitoring"
	echo " on your router."
	echo
	echo " Author: Jack Yaz"
	echo " https://www.snbforums.com/threads/56163"
	c_d

	c_url "https://raw.githubusercontent.com/jackyaz/connmon/master/connmon.sh" -o "/jffs/scripts/connmon" && chmod 0755 /jffs/scripts/connmon && /jffs/scripts/connmon install
	sleep 2
	if [ -f /jffs/scripts/connmon ]; then
		show_amtm " connmon installed"
	else
		am=;show_amtm " connmon installation failed"
	fi
}
#eof
