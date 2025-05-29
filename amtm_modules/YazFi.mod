#!/bin/sh
#bof
YazFi_installed(){
	scriptname=YazFi
	scriptgrep=' YAZFI_VERSION'
	if [ "$su" = 1 ]; then
		remoteurl=https://raw.githubusercontent.com/AMTM-OSR/YazFi/master/YazFi.sh
		grepcheck=jackyaz
	fi
	script_check
	if [ -z "$su" -a -z "$tpu" ]; then
		if [ "$YazFiUpate" ]; then
			localver="$lvtpu"
			upd="${E_BG}$YazFiUpate${NC}"
			if [ "$YazFiMD5" != "$(md5sum "$scriptloc" | awk '{print $1}')" ]; then
				[ -f "${add}"/availUpd.txt ] && sed -i '/^YazFi.*/d' "${add}"/availUpd.txt
				upd="${E_BG}${NC}$lvtpu"
				unset localver YazFiUpate YazFiMD5
			fi
		fi
		if ! grep -q -m1 'AMTM-OSR' "$scriptloc"; then
			sed -i '/^SCRIPT_BRANCH=/c\SCRIPT_BRANCH="master"' "$scriptloc"
			sed -i 's|/jackyaz.io/|/raw.githubusercontent.com/AMTM-OSR/|g' "$scriptloc"
			sed -i 's|/version/|/|g;s|/files/|/|g;s|/md5/|/|g;s|/update/|/|g;s|/install-success/|/|g;s|/md5/|/|g;s|/404/|/|g' "$scriptloc"
			printf "\\n   ${R_BG} $scriptname modified to use AMTM-OSR repository ${NC}\\n    Update now using the $scriptname function.\\n"
		fi
	fi
	[ -z "$updcheck" -a -z "$ss" ] && printf "${GN_BG} 4 ${NC} %-9s%-21s%${COR}s\\n" "open" "YazFi         $localver" " $upd"
	case_4(){
		/jffs/scripts/YazFi
		sleep 2
		show_amtm menu
	}
}
install_YazFi(){
	p_e_l
	printf " This installs YazFi - enhanced Asuswrt-Merlin\\n Guest WiFi Networks on your router.\\n\\n"
	printf " Original Author: Jack Yaz\\n snbforums.com/forums/asuswrt-merlin-addons.60/?prefix_id=13&starter_id=53009\\n\\n"
	printf " This script is now maintained by the AMTM-OSR team,\\n the AMTM Orphaned Script Revival repository.\\n"
	printf " Visit and learn more about their mission here:\\n https://github.com/AMTM-OSR\\n"
	c_d
	c_url https://raw.githubusercontent.com/AMTM-OSR/YazFi/master/YazFi.sh -o /jffs/scripts/YazFi && chmod 0755 /jffs/scripts/YazFi && /jffs/scripts/YazFi install
	sleep 2
	if [ -f /jffs/scripts/YazFi ]; then
		show_amtm " YazFi installed"
	else
		am=;show_amtm " YazFi installation failed"
	fi
}
#eof
