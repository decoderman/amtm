#!/bin/sh
#bof
Vnstat_installed(){
	scriptname=Vnstat
	scriptgrep=' SCRIPT_VERSION='
	if [ "$su" = 1 ]; then
		remoteurl=https://raw.githubusercontent.com/AMTM-OSR/vnstat-on-merlin/main/dn-vnstat.sh
		grepcheck=dev_null
	fi
	script_check
	if [ -z "$su" -a -z "$tpu" ]; then
		if [ "$VnstatUpate" ]; then
			localver="$lvtpu"
			upd="${E_BG}$VnstatUpate${NC}"
			if [ "$VnstatMD5" != "$(md5sum "$scriptloc" | awk '{print $1}')" ]; then
				[ -f "${add}"/availUpd.txt ] && sed -i '/^Vnstat.*/d' "${add}"/availUpd.txt
				upd="${E_BG}${NC}$lvtpu"
				unset localver VnstatUpate VnstatMD5
			fi
		fi
		if ! grep -q -m1 'AMTM-OSR' "$scriptloc"; then
			sed -i '/^SCRIPT_BRANCH=/c\SCRIPT_BRANCH="main"' "$scriptloc"
			sed -i 's|"jackyaz-dev"|"develop"|' "$scriptloc"
			sed -i '/SCRIPT_REPO=/c\SCRIPT_REPO="https://raw.githubusercontent.com/AMTM-OSR/vnstat-on-merlin/$SCRIPT_BRANCH"' "$scriptloc"
			sed -i '/^readonly SHARED_REPO=/c\readonly SHARED_REPO="https://raw.githubusercontent.com/AMTM-OSR/shared-jy/master"' "$scriptloc"
			printf "\\n   ${R_BG} $scriptname modified to use AMTM-OSR repository ${NC}\\n    Update now using the $scriptname function.\\n"
		fi
	fi
	[ -z "$updcheck" -a -z "$ss" ] && printf "${GN_BG} vn${NC} %-9s%-21s%${COR}s\\n" "open" "vnStat        $localver" " $upd"
	case_vn(){
		/jffs/scripts/dn-vnstat
		sleep 2
		show_amtm menu
	}
}
install_Vnstat(){
	p_e_l
	printf " This installs vnStat - data use monitoring with\\n email function on your router.\\n\\n"
	printf " Original Author: dev_null\\n snbforums.com/forums/asuswrt-merlin-addons.60/?prefix_id=34\\n\\n"
	printf " This script is now maintained by the AMTM-OSR team,\\n the AMTM Orphaned Script Revival repository.\\n"
	printf " Visit and learn more about their mission here:\\n https://github.com/AMTM-OSR\\n"
	c_d
	c_url https://raw.githubusercontent.com/AMTM-OSR/vnstat-on-merlin/main/dn-vnstat.sh -o /jffs/scripts/dn-vnstat && chmod 0755 /jffs/scripts/dn-vnstat && /jffs/scripts/dn-vnstat install
	sleep 2
	if [ -f /jffs/scripts/dn-vnstat ]; then
		show_amtm " vnStat installed"
	else
		am=;show_amtm " vnStat installation failed"
	fi
}
#eof
