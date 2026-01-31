#!/bin/sh
#bof
ModSyslogUI_installed(){
	scriptname=ModSyslogUI
	scriptgrep=' SCRIPT_VERSION='
	if [ "$su" = 1 ]; then
		remoteurl=https://raw.githubusercontent.com/kstamand/modsyslogui/master/modsyslogui
		grepcheck=kstamand
	fi
	script_check
	if [ -z "$su" -a -z "$tpu" ]; then
		if [ "$ModSyslogUIUpate" ]; then
			localver="$lvtpu"
			upd="${E_BG}$ModSyslogUIUpate${NC}"
			if [ "$ModSyslogUIMD5" != "$(md5sum "$scriptloc" | awk '{print $1}')" ]; then
				[ -f "${add}"/availUpd.txt ] && sed -i '/^ModSyslogUI.*/d' "${add}"/availUpd.txt
				upd="${E_BG}${NC}$lvtpu"
				unset localver ModSyslogUIUpate ModSyslogUIMD5
			fi
		fi
	fi
	[ -z "$updcheck" -a -z "$ss" ] && printf "${GN_BG} ms${NC} %-9s%-21s%${COR}s\\n" "open" "ModSyslogUI       $localver" " $upd"
	case_ms(){
		/jffs/addons/modsyslogui/modsyslogui
		sleep 2
		show_amtm menu
	}
}
install_ModSyslogUI(){
	p_e_l
	printf " This installs ModSyslogUI - Adding System Log page UI filtering capabilities\\n on your router.\\n\\n"
	printf " Author: kstamand\\n snbforums.com/threads/modsyslogui-v1-0-1-update-add-on-providing-system-log-page-ui-filtering-capabilities.96496/\\n"
	c_d
	c_url https://raw.githubusercontent.com/kstamand/modsyslogui/master/modsyslogui -o /tmp/modsyslogui && chmod 0755 /tmp/modsyslogui && /tmp/modsyslogui install
	sleep 2
	if [ -f /jffs/addons/modsyslogui/modsyslogui ]; then
		show_amtm " ModSyslogUI installed"
	else
		am=;show_amtm " ModSyslogUI installation failed"
	fi
}
#eof
