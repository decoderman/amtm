#!/bin/sh
#bof
connmon_installed(){
	scriptname=connmon
	scriptgrep=' SCRIPT_VERSION='
	if [ "$su" = 1 ]; then
		remoteurl=https://raw.githubusercontent.com/AMTM-OSR/connmon/master/connmon.sh
		grepcheck=jackyaz
	fi
	script_check
	if [ -z "$su" -a -z "$tpu" ]; then
		if [ "$connmonUpate" ]; then
			localver="$lvtpu"
			upd="${E_BG}$connmonUpate${NC}"
			if [ "$connmonMD5" != "$(md5sum "$scriptloc" | awk '{print $1}')" ]; then
				[ -f "${add}"/availUpd.txt ] && sed -i '/^connmon.*/d' "${add}"/availUpd.txt
				upd="${E_BG}${NC}$lvtpu"
				unset localver connmonUpate connmonMD5
			fi
		fi
		if ! grep -q -m1 'AMTM-OSR' "$scriptloc"; then
			sed -i '/^SCRIPT_BRANCH=/c\SCRIPT_BRANCH="master"' "$scriptloc"
			sed -i '/SCRIPT_REPO=/c\SCRIPT_REPO="https://raw.githubusercontent.com/AMTM-OSR/$SCRIPT_NAME/$SCRIPT_BRANCH"' "$scriptloc"
			sed -i '/^readonly SHARED_REPO=/c\readonly SHARED_REPO="https://raw.githubusercontent.com/AMTM-OSR/shared-jy/master"' "$scriptloc"
			sed -i 's|/version/|/|g;s|/files/|/|g;s|/md5/|/|g;s|/update/|/|g;s|/install-success/|/|g;s|/md5/|/|g;s|/404/|/|g' "$scriptloc"
			printf "\\n   ${R_BG} $scriptname modified to use AMTM-OSR repository ${NC}\\n    Update now using the $scriptname function.\\n"
		fi
	fi
	[ -z "$updcheck" -a -z "$ss" ] && printf "${GN_BG} j1${NC} %-9s%-21s%${COR}s\\n" "open" "connmon       $localver" " $upd"
	case_j1(){
		/jffs/scripts/connmon
		sleep 2
		show_amtm menu
	}
}
install_connmon(){
	p_e_l
	printf " This installs connmon - Internet connection\\n monitoring on your router.\\n\\n"
	printf " Original Author: Jack Yaz\\n snbforums.com/forums/asuswrt-merlin-addons.60/?prefix_id=18&starter_id=53009\\n\\n"
	printf " This script is now maintained by the AMTM-OSR team,\\n the AMTM Orphaned Script Revival repository.\\n"
	printf " Visit and learn more about their mission here:\\n https://github.com/AMTM-OSR\\n"
	c_d
	c_url https://raw.githubusercontent.com/AMTM-OSR/connmon/master/connmon.sh -o /jffs/scripts/connmon && chmod 0755 /jffs/scripts/connmon && /jffs/scripts/connmon install
	sleep 2
	if [ -f /jffs/scripts/connmon ]; then
		show_amtm " connmon installed"
	else
		am=;show_amtm " connmon installation failed"
	fi
}
#eof
