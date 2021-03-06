#!/bin/sh
#bof
Vnstat_installed(){
	scriptname=Vnstat
	scriptgrep=' SCRIPT_VERSION='
	if [ "$su" = 1 ]; then
		remoteurl="https://raw.githubusercontent.com/de-vnull/vnstat-on-merlin/main/dn-vnstat.sh"
		grepcheck=dev_null
	fi
	script_check
	if [ -z "$su" -a -z "$tpu" ] && [ "$VnstatUpate" ]; then
		localver="$lvtpu"
		upd="${E_BG}$VnstatUpate${NC}"
		if [ "$VnstatMD5" != "$(md5sum "$scriptloc" | awk '{print $1}')" ]; then
			sed -i '/^Vnstat.*/d' "${add}"/availUpd.txt
			upd="${E_BG}${NC}$lvtpu"
			unset localver VnstatUpate VnstatMD5
		fi
	fi
	printf "${GN_BG} vn${NC} %-9s%-21s%${COR}s\\n" "open" "Vnstat        $localver" " $upd"
	case_vn(){
		/jffs/scripts/dn-vnstat
		sleep 2
		show_amtm menu
	}
}
install_Vnstat(){
	p_e_l
	echo " This installs Vnstat - data use monitoring with email function"
	echo " on your router."
	echo
	echo " Author: dev_null"
	echo " https://www.snbforums.com/forums/asuswrt-merlin-addons.60/"
	c_d

	c_url "https://raw.githubusercontent.com/de-vnull/vnstat-on-merlin/main/dn-vnstat.sh" -o "/jffs/scripts/dn-vnstat" && chmod 0755 /jffs/scripts/dn-vnstat && /jffs/scripts/dn-vnstat install

	sleep 2
	if [ -f /jffs/scripts/dn-vnstat ]; then
		show_amtm " Vnstat installed"
	else
		am=;show_amtm " Vnstat installation failed"
	fi
}
#eof
