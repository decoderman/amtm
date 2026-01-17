#!/bin/sh
#bof
uiScribe_installed(){
	scriptname=uiScribe
	scriptgrep=' SCRIPT_VERSION='
	if [ "$su" = 1 ]; then
		remoteurl=https://raw.githubusercontent.com/AMTM-OSR/uiScribe/master/uiScribe.sh
		grepcheck=jackyaz
	fi
	script_check
	if [ -z "$su" -a -z "$tpu" ]; then
		if [ "$uiScribeUpate" ]; then
			localver="$lvtpu"
			upd="${E_BG}$uiScribeUpate${NC}"
			if [ "$uiScribeMD5" != "$(md5sum "$scriptloc" | awk '{print $1}')" ]; then
				[ -f "${add}"/availUpd.txt ] && sed -i '/^uiScribe.*/d' "${add}"/availUpd.txt
				upd="${E_BG}${NC}$lvtpu"
				unset localver uiScribeUpate uiScribeMD5
			fi
		fi
		if ! grep -q -m1 'AMTM-OSR' "$scriptloc"; then
			sed -i '/^SCRIPT_BRANCH=/c\SCRIPT_BRANCH="master"' "$scriptloc"
			sed -i '/SCRIPT_REPO=/c\SCRIPT_REPO="https://raw.githubusercontent.com/AMTM-OSR/$SCRIPT_NAME/$SCRIPT_BRANCH"' "$scriptloc"
			sed -i '/^readonly SHARED_REPO=/c\readonly SHARED_REPO="https://raw.githubusercontent.com/AMTM-OSR/shared-jy/master"' "$scriptloc"
			printf "\\n   ${R_BG} $scriptname modified to use AMTM-OSR repository ${NC}\\n    Update now using the $scriptname function.\\n"
		fi
	fi
	[ -z "$updcheck" -a -z "$ss" ] && printf "${GN_BG} j6${NC} %-9s%-21s%${COR}s\\n" "open" "uiScribe      $localver" " $upd"
	case_j6(){
		/jffs/scripts/uiScribe
		sleep 2
		show_amtm menu
	}
}
install_uiScribe(){
	p_e_l
	printf " This installs uiScribe - Custom System\\n Log page for Scribe on your router.\\n\\n"
	printf " Original Author: Jack Yaz\\n snbforums.com/forums/asuswrt-merlin-addons.60/?prefix_id=24&starter_id=53009\\n\\n"
	printf " This script is now maintained by the AMTM-OSR team,\\n the AMTM Orphaned Script Revival repository.\\n"
	printf " Visit and learn more about their mission here:\\n https://github.com/AMTM-OSR\\n"
	c_d
	if [ -s /jffs/scripts/scribe ] && [ -s /jffs/addons/scribe.d/config ] && [ -x /opt/bin/scribe ]; then
		c_url https://raw.githubusercontent.com/AMTM-OSR/uiScribe/master/uiScribe.sh -o /jffs/scripts/uiScribe && chmod 0755 /jffs/scripts/uiScribe && /jffs/scripts/uiScribe install
		sleep 2
		if [ -f /jffs/scripts/uiScribe ]; then
			show_amtm " uiScribe installed"
		else
			am=;show_amtm " uiScribe installation failed"
		fi
	else
		am=;show_amtm " uiScribe installation failed,\\n scribe is not installed"
	fi
}
#eof
