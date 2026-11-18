#!/bin/sh
#bof
ASNmanager_installed(){
	scriptgrep='^version='
	if [ "$su" = 1 ]; then
		remoteurl=https://raw.githubusercontent.com/Outlooieu/ASNmanager/main/ASNmanager.sh
		grepcheck=Outlooieu
	fi
	script_check
	if [ -z "$su" -a -z "$tpu" ] && [ "$ASNmanagerUpdate" ]; then
		localver="$lvtpu"
		upd="${E_BG}$ASNmanagerUpdate${NC}"
		if [ "$ASNmanagerMD5" != "$(md5sum "$scriptloc" | awk '{print $1}')" ]; then
			[ -f "${add}"/availUpd.txt ] && sed -i '/^ASNmanager.*/d' "${add}"/availUpd.txt
			upd="${E_BG}${NC}$lvtpu"
			unset localver ASNmanagerUpdate ASNmanagerMD5
		fi
	fi
	[ -z "$updcheck" -a -z "$ss" ] && printf "${GN_BG} 6 ${NC} %-9s%-21s%${COR}s\\n" "open" "ASN Manager   $localver" " $upd"
	case_6(){
		/jffs/scripts/ASNmanager.sh
		sleep 2
		show_amtm menu
	}
}
install_ASNmanager(){
	p_e_l
	printf " This installs ASN Manager - Advanced Policy-Based\\n Routing for Asuswrt-Merlin on your router.\\n\\n"
	printf " Author: NoName79\\n snbforums.com/threads/97832/\\n"
	c_d
	if c_url https://raw.githubusercontent.com/Outlooieu/ASNmanager/main/ASNmanager.sh -o /jffs/scripts/ASNmanager.sh &&
		chmod 755 /jffs/scripts/ASNmanager.sh &&
		/jffs/scripts/ASNmanager.sh install &&
		[ -f /jffs/scripts/ASNmanager.sh ]; then
		show_amtm " ASN Manager installed"
	else
		am=;show_amtm " ASN Manager installation failed"
	fi
}
#eof
