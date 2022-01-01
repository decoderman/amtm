#!/bin/sh
#bof
uiScribe_installed(){
	scriptname=uiScribe
	scriptgrep=' SCRIPT_VERSION='
	if [ "$su" = 1 ]; then
		remoteurl=https://jackyaz.io/uiScribe/master/amtm-version/uiScribe.sh
		remoteurlmd5=https://jackyaz.io/uiScribe/master/amtm-md5/uiScribe.sh
		grepcheck=jackyaz
	fi
	script_check
	if [ -z "$su" -a -z "$tpu" ] && [ "$uiScribeUpate" ]; then
		localver="$lvtpu"
		upd="${E_BG}$uiScribeUpate${NC}"
		if [ "$uiScribeMD5" != "$(md5sum "$scriptloc" | awk '{print $1}')" ]; then
			sed -i '/^uiScribe.*/d' "${add}"/availUpd.txt
			upd="${E_BG}${NC}$lvtpu"
			unset localver uiScribeUpate uiScribeMD5
		fi
	fi
	[ -z "$updcheck" ] && printf "${GN_BG} j6${NC} %-9s%-21s%${COR}s\\n" "open" "uiScribe      $localver" " $upd"
	case_j6(){
		/jffs/scripts/uiScribe
		sleep 2
		show_amtm menu
	}
}
install_uiScribe(){
	p_e_l
	echo " This installs uiScribe - Custom System Log page for Scribe"
	echo " on your router."
	echo
	echo " Author: Jack Yaz"
	echo " https://www.snbforums.com/forums/asuswrt-merlin-addons.60/?prefix_id=24&starter_id=53009"
	c_d

	if [ -f /jffs/scripts/scribe ] && grep -qE "^cru a logrotate .* # added by scribe" /jffs/scripts/post-mount 2> /dev/null; then
		c_url https://jackyaz.io/uiScribe/master/amtm-install/uiScribe.sh -o "/jffs/scripts/uiScribe" && chmod 0755 /jffs/scripts/uiScribe && /jffs/scripts/uiScribe install
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
