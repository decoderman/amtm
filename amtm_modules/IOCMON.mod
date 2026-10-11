#!/bin/sh
#bof
IOCMON_installed(){
	localVother="$(grep ^version= "$scriptloc" | cut -d'"' -f2)"
	if [ "$su" = 1 ]; then
		remoteurl=https://raw.githubusercontent.com/ViktorJp/IOCMON/main/iocmon.sh
		remoteVother="$(c_url "$remoteurl" | grep ^version= | cut -d'"' -f2)"
		grepcheck=ViktorJp
	fi
	script_check
	if [ -z "$su" -a -z "$tpu" ] && [ "$IOCMONUpdate" ]; then
		localver="$lvtpu"
		upd="${E_BG}$IOCMONUpdate${NC}"
		if [ "$IOCMONMD5" != "$(md5sum "$scriptloc" | awk '{print $1}')" ]; then
			[ -f "${add}"/availUpd.txt ] && sed -i '/^IOCMON.*/d' "${add}"/availUpd.txt
			upd="${E_BG}${NC}$lvtpu"
			unset localver IOCMONUpdate IOCMONMD5
		fi
	fi
	[ -z "$updcheck" -a -z "$ss" ] && printf "${GN_BG} 9 ${NC} %-9s%-21s%${COR}s\\n" "open" "IOCMON        $localver" " $upd"
	case_9(){
		trap trap_ctrl 2
		trap_ctrl(){
			sleep 2
			echo "${NC}"
			exec "$0"
		}
		[ "$(which screen)" ] && iocOption='-screen -now' || iocOption=
		/jffs/scripts/iocmon.sh $iocOption
		trap - 2
		sleep 2
		show_amtm menu
	}
}
install_IOCMON(){
	p_e_l
	printf " This installs IOCMON - Asuswrt-Merlin Security\\n Intelligence Monitor on your router.\\n\\n"
	printf " Author: Viktor Jaep\\n snbforums.com/threads/97925/\\n"
	c_d
	c_url https://github.com/ViktorJp/IOCMON/releases/latest/download/iocmon.sh -o /jffs/scripts/iocmon.sh && chmod 755 /jffs/scripts/iocmon.sh && /jffs/scripts/iocmon.sh -setup

	sleep 2
	if [ -f /jffs/scripts/iocmon.sh ]; then
		show_amtm " IOCMON installed"
	else
		am=;show_amtm " IOCMON installation failed"
	fi
}
#eof
