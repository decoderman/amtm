#!/bin/sh
#bof
scribe_installed(){
	scriptname=scribe
	scriptgrep='^scribe_ver='
	if [ "$su" = 1 ]; then
		remoteurl="https://raw.githubusercontent.com/cynicastic/scribe/master/scribe"
		grepcheck=cynicastic
	fi
	script_check
	if [ -z "$su" -a -z "$tpu" ] && [ "$scribeUpate" ]; then
		localver="$lvtpu"
		upd="${E_BG}$scribeUpate${NC}"
		if [ "$scribeMD5" != "$(md5sum "$scriptloc" | awk '{print $1}')" ]; then
			sed -i '/^scribe.*/d' "${add}"/availUpd.txt
			upd="${E_BG}${NC}$lvtpu"
			unset localver scribeUpate scribeMD5
		fi
	fi
	printf "${GN_BG} 5 ${NC} %-9s%-21s%${COR}s\\n" "open" "scribe        $localver" " $upd"
	case_5(){
		/jffs/scripts/scribe
		sleep 2
		show_amtm menu
	}
}
install_scribe(){
	p_e_l
	echo " This installs scribe - syslog-ng and logrotate installer"
	echo " on your router."
	echo
	echo " Author: cmkelley"
	echo " https://www.snbforums.com/threads/scribe-syslog-ng-and-logrotate-installer.55853/"
	c_d
	c_url "https://raw.githubusercontent.com/cynicastic/scribe/master/scribe" -o "/jffs/scripts/scribe" && chmod 0755 /jffs/scripts/scribe && /jffs/scripts/scribe install
	sleep 2
	if [ -f /jffs/scripts/scribe ] && grep -qE "^cru a logrotate .* # added by scribe" /jffs/scripts/post-mount 2> /dev/null; then
		show_amtm " scribe installed"
	else
		am=;show_amtm " scribe installation failed"
	fi
}
#eof
