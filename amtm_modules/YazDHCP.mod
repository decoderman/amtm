#!/bin/sh
#bof
YazDHCP_installed(){
	scriptname=YazDHCP
	scriptgrep=' SCRIPT_VERSION='
	if [ "$su" = 1 ]; then
		remoteurl=https://jackyaz.io/YazDHCP/master/amtm-version/YazDHCP.sh
		remoteurlmd5=https://jackyaz.io/YazDHCP/master/amtm-md5/YazDHCP.sh
		grepcheck=jackyaz
	fi
	script_check
	if [ -z "$su" -a -z "$tpu" ] && [ "$YazDHCPUpate" ]; then
		localver="$lvtpu"
		upd="${E_BG}$YazDHCPUpate${NC}"
		if [ "$YazDHCPMD5" != "$(md5sum "$scriptloc" | awk '{print $1}')" ]; then
			[ -f "${add}"/availUpd.txt ] && sed -i '/^YazDHCP.*/d' "${add}"/availUpd.txt
			upd="${E_BG}${NC}$lvtpu"
			unset localver YazDHCPUpate YazDHCPMD5
		fi
	fi
	[ -z "$updcheck" -a -z "$ss" ] && printf "${GN_BG} j7${NC} %-9s%-21s%${COR}s\\n" "open" "YazDHCP     $localver" " $upd"
	case_j7(){
		/jffs/scripts/YazDHCP
		sleep 2
		show_amtm menu
	}
}
install_YazDHCP(){
	p_e_l
	printf " This installs YazDHCP - Feature expansion of\\n DHCP assignments on your router.\\n\\n"
	printf " Author: Jack Yaz\\n snbforums.com/forums/asuswrt-merlin-addons.60/?prefix_id=31&starter_id=53009\\n"
	c_d
	c_url https://jackyaz.io/YazDHCP/master/amtm-install/YazDHCP.sh -o /jffs/scripts/YazDHCP && chmod 0755 /jffs/scripts/YazDHCP && /jffs/scripts/YazDHCP install
	sleep 2
	if [ -f /jffs/scripts/YazDHCP ]; then
		show_amtm " YazDHCP installed"
	else
		am=;show_amtm " YazDHCP installation failed"
	fi
}
#eof
