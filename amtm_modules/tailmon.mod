#!/bin/sh
#bof
tailmon_installed(){
	scriptname=tailmon
	localVother="$(grep ^version "$scriptloc" | sed -e 's/version=//;s/"//g')"
	if [ "$su" = 1 ]; then
		remoteurl=https://raw.githubusercontent.com/ViktorJp/TAILMON/master/tailmon.sh
		remoteVother="$(c_url "$remoteurl" | grep ^version | sed -e 's/version=//;s/"//g')"
		grepcheck=ViktorJp
	fi
	script_check
	if [ -z "$su" -a -z "$tpu" ] && [ "$tailmonUpate" ]; then
		localver="$lvtpu"
		upd="${E_BG}$tailmonUpate${NC}"
		if [ "$tailmonMD5" != "$(md5sum "$scriptloc" | awk '{print $1}')" ]; then
			[ -f "${add}"/availUpd.txt ] && sed -i '/^tailmon.*/d' "${add}"/availUpd.txt
			upd="${E_BG}${NC}$lvtpu"
			unset localver tailmonUpate tailmonMD5
		fi
	fi
	[ -z "$updcheck" -a -z "$ss" ] && printf "${GN_BG} tm${NC} %-9s%-21s%${COR}s\\n" "open" "TAILMON     $localver" " $upd"
	case_tm(){
		trap trap_ctrl 2
		trap_ctrl(){
			sleep 2
			echo "${NC}"
			exec "$0"
		}
		/jffs/scripts/tailmon.sh
		trap - 2
		sleep 2
		show_amtm menu
	}
}
install_tailmon(){
	p_e_l
	printf " This installs TAILMON - WireGuard-based Tailscale\\n installer, configurator and monitor\\n\\n"
	printf " Author: Viktor Jaep\\n snbforums.com/threads/release-tailmon-v1-0-8-may-3-2024-wireguard-based-tailscale-installer-configurator-and-monitor.89860/\\n"
	c_d
	c_url https://raw.githubusercontent.com/ViktorJp/TAILMON/master/tailmon.sh -o /jffs/scripts/tailmon.sh && chmod a+rx /jffs/scripts/tailmon.sh && /jffs/scripts/tailmon.sh -setup

	sleep 2
	if [ -f /jffs/scripts/tailmon.sh ]; then
		show_amtm " TAILMON  installed"
	else
		am=;show_amtm " TAILMON  installation failed"
	fi
}
#eof
