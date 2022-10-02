#!/bin/sh
#bof
rtrmon_installed(){
	scriptname=rtrmon
	localVother="v$(grep ^Version "$scriptloc" | awk '{print $1}' | sed -e 's/Version=//;s/"//g')"
	if [ "$su" = 1 ]; then
		remoteurl=https://raw.githubusercontent.com/ViktorJp/RTRMON/main/rtrmon.sh
		remoteVother="v$(c_url "$remoteurl" | grep ^Version | awk '{print $1}' | sed -e 's/Version=//;s/"//g')"
		grepcheck=ViktorJp
	fi
	script_check
	if [ -z "$su" -a -z "$tpu" ] && [ "$rtrmonUpate" ]; then
		localver="$lvtpu"
		upd="${E_BG}$rtrmonUpate${NC}"
		if [ "$rtrmonMD5" != "$(md5sum "$scriptloc" | awk '{print $1}')" ]; then
			sed -i '/^rtrmon.*/d' "${add}"/availUpd.txt
			upd="${E_BG}${NC}$lvtpu"
			unset localver rtrmonUpate rtrmonMD5
		fi
	fi
	[ -z "$updcheck" ] && printf "${GN_BG} rt${NC} %-9s%-21s%${COR}s\\n" "open" "RTRMON      $localver" " $upd"
	case_rt(){
		trap trap_ctrl 2
		trap_ctrl(){
			sleep 2
			echo "${NC}"
			exec "$0"
		}
		/jffs/scripts/rtrmon.sh -setup
		trap - 2
		sleep 2
		show_amtm menu
	}
}
install_rtrmon(){
	p_e_l
	echo " This installs RTRMON - Monitor your Router's Health"
	echo " on your router."
	echo
	echo " Author: Viktor Jaep"
	echo " https://www.snbforums.com/forums/asuswrt-merlin-addons.60/"
	c_d

	c_url https://raw.githubusercontent.com/ViktorJp/RTRMON/master/rtrmon.sh -o /jffs/scripts/rtrmon.sh && chmod a+rx /jffs/scripts/rtrmon.sh && /jffs/scripts/rtrmon.sh -setup

	sleep 2
	if [ -f /jffs/scripts/rtrmon.sh ]; then
		show_amtm " RTRMON installed"
	else
		am=;show_amtm " RTRMON installation failed"
	fi
}
#eof
