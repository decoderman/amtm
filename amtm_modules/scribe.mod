#!/bin/sh
#bof
scribe_installed(){
	scriptname=scribe
	scriptgrep='^scribe_ver='
	if [ "$su" = 1 ]; then
		remoteurl=https://raw.githubusercontent.com/cynicastic/scribe/master/scribe
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
	[ -z "$updcheck" -a -z "$ss" ] && printf "${GN_BG} 5 ${NC} %-9s%-21s%${COR}s\\n" "open" "scribe        $localver" " $upd"
	case_5(){
		/jffs/scripts/scribe
		sleep 2
		show_amtm menu
	}
}
install_scribe(){
	p_e_l
	printf " This installs scribe - syslog-ng and logrotate\\n installer on your router.\\n\\n"
	printf " Author: cmkelley\\n snbforums.com/forums/asuswrt-merlin-addons.60/?prefix_id=7\\n"
	c_d
	c_url https://raw.githubusercontent.com/cynicastic/scribe/master/scribe -o /jffs/scripts/scribe && chmod 0755 /jffs/scripts/scribe && /jffs/scripts/scribe install
	sleep 2
	if [ -f /jffs/scripts/scribe ]; then
		show_amtm " scribe installed"
	else
		am=;show_amtm " scribe installation failed"
	fi
}
#eof
