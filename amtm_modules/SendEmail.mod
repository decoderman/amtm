#!/bin/sh
#bof
SendEmail_installed(){
	scriptgrep=' SCRIPT_VERSION='
	if [ "$su" = 1 ]; then
		remoteurl=https://raw.githubusercontent.com/Martinski4GitHub/SendEmail/master/SendEmail.sh
		grepcheck=Martinski
	fi
	script_check
	if [ -z "$su" -a -z "$tpu" ] && [ "$SendEmailUpdate" ]; then
		localver="$lvtpu"
		upd="${E_BG}$SendEmailUpdate${NC}"
		if [ "$SendEmailMD5" != "$(md5sum "$scriptloc" | awk '{print $1}')" ]; then
			[ -f "${add}"/availUpd.txt ] && sed -i '/^SendEmail.*/d' "${add}"/availUpd.txt
			upd="${E_BG}${NC}$lvtpu"
			unset localver SendEmailUpdate SendEmailMD5
		fi
	fi
	[ -z "$updcheck" -a -z "$ss" ] && printf "${GN_BG} se${NC} %-9s%-21s%${COR}s\\n" "open" "SendEmail     $localver" " $upd"
	case_se(){
		/jffs/addons/SendEmail.d/SendEmail.sh
		sleep 2
		show_amtm menu
	}
}
install_SendEmail(){
	p_e_l
	printf " This installs SendEmail - Script Tool to Send\\n Email Notifications on your router.\\n\\n"
	printf " Author: Martinski\\n snbforums.com/threads/97946/\\n"
	c_d
	c_url https://raw.githubusercontent.com/Martinski4GitHub/SendEmail/master/SendEmail.sh -o /jffs/scripts/SendEmail.sh && chmod a+x /jffs/scripts/SendEmail.sh && /jffs/scripts/SendEmail.sh -install

	sleep 2
	if [ -f /jffs/addons/SendEmail.d/SendEmail.sh ]; then
		show_amtm " SendEmail installed"
	else
		am=;show_amtm " SendEmail installation failed"
	fi
}
#eof
