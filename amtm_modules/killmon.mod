#!/bin/sh
#bof
killmon_installed(){
	scriptname=killmon
	localVother="v$(grep ^Version "$scriptloc" | awk '{print $1}' | sed -e 's/Version=//;s/"//g')"
	if [ "$su" = 1 ]; then
		remoteurl=https://raw.githubusercontent.com/ViktorJp/KILLMON/main/killmon.sh
		remoteVother="v$(c_url "$remoteurl" | grep ^Version | awk '{print $1}' | sed -e 's/Version=//;s/"//g')"
		grepcheck=ViktorJp
	fi
	script_check
	if [ -z "$su" -a -z "$tpu" ] && [ "$killmonUpate" ]; then
		localver="$lvtpu"
		upd="${E_BG}$killmonUpate${NC}"
		if [ "$killmonMD5" != "$(md5sum "$scriptloc" | awk '{print $1}')" ]; then
			sed -i '/^killmon.*/d' "${add}"/availUpd.txt
			upd="${E_BG}${NC}$lvtpu"
			unset localver killmonUpate killmonMD5
		fi
	fi
	[ -z "$updcheck" ] && printf "${GN_BG} km${NC} %-9s%-21s%${COR}s\\n" "open" "KILLMON     $localver" " $upd"
	case_km(){
		trap trap_ctrl 2
		trap_ctrl(){
			sleep 2
			echo "${NC}"
			exec "$0"
		}
		/jffs/scripts/killmon.sh -setup
		trap - 2
		sleep 2
		show_amtm menu
	}
}
install_killmon(){
	p_e_l
	echo " This installs KILLMON - IP4/IP6 VPN Kill Switch Monitor & Configurator"
	echo " on your router."
	echo
	echo " Author: Viktor Jaep"
	echo " https://www.snbforums.com/threads/killmon-v1-01-dec-9-2022-ip4-ip6-vpn-kill-switch-monitor-configurator.81758/"
	c_d

	c_url https://raw.githubusercontent.com/ViktorJp/KILLMON/master/killmon-1.01.sh -o /jffs/scripts/killmon.sh && chmod a+rx /jffs/scripts/killmon.sh && /jffs/scripts/killmon.sh -setup

	sleep 2
	if [ -f /jffs/scripts/killmon.sh ]; then
		show_amtm " KILLMON installed"
	else
		am=;show_amtm " KILLMON installation failed"
	fi
}
#eof
