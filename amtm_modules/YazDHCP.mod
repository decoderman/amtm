#!/bin/sh
#bof
YazDHCP_installed(){
	scriptname=YazDHCP
	scriptgrep=' SCRIPT_VERSION='
	if [ "$su" = 1 ]; then
		remoteurl="https://raw.githubusercontent.com/jackyaz/YazDHCP/master/YazDHCP.sh"
		grepcheck=jackyaz
	fi
	script_check
	if [ -z "$su" -a -z "$tpu" ] && [ "$YazDHCPUpate" ]; then
		localver="$lvtpu"
		upd="${E_BG}$YazDHCPUpate${NC}"
		if [ "$YazDHCPMD5" != "$(md5sum "$scriptloc" | awk '{print $1}')" ]; then
			sed -i '/^YazDHCP.*/d' "${add}"/availUpd.txt
			upd="${E_BG}${NC}$lvtpu"
			unset localver YazDHCPUpate YazDHCPMD5
		fi
	fi
	printf "${GN_BG} j7${NC} %-9s%-21s%${COR}s\\n" "open" "YazDHCP     $localver" " $upd"
	case_j7(){
		/jffs/scripts/YazDHCP
		sleep 2
		show_amtm menu
	}
}
install_YazDHCP(){
	p_e_l
	echo " This installs YazDHCP - Feature expansion of DHCP assignments"
	echo " on your router."
	echo
	echo " Author: Jack Yaz"
	echo " https://www.snbforums.com/forums/asuswrt-merlin-addons.60/"
	c_d
	
	c_url "https://raw.githubusercontent.com/jackyaz/YazDHCP/master/YazDHCP.sh" -o "/jffs/scripts/YazDHCP" && chmod 0755 /jffs/scripts/YazDHCP && /jffs/scripts/YazDHCP install

	sleep 2
	if [ -f /jffs/scripts/YazDHCP ]; then
		show_amtm " YazDHCP installed"
	else
		am=;show_amtm " YazDHCP installation failed"
	fi
}
#eof
