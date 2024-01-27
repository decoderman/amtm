#!/bin/sh
#bof
vpnmon_r3_installed(){
	scriptname='VPNMON-R3'
	localVother="$(grep ^version "$scriptloc" | awk '{print $1}' | sed -e 's/version=//;s/"//g')"
	if [ "$su" = 1 ]; then
		remoteurl=https://raw.githubusercontent.com/ViktorJp/VPNMON-R3/main/vpnmon-r3.sh
		remoteVother="$(c_url "$remoteurl" | grep ^version | awk '{print $1}' | sed -e 's/version=//;s/"//g')"
		grepcheck=ViktorJp
	fi
	script_check
	if [ -z "$su" -a -z "$tpu" ] && [ "$vpnmon_r3Upate" ]; then
		localver="$lvtpu"
		upd="${E_BG}$vpnmon_r3Upate{NC}"
		if [ "$vpnmon_r3MD5" != "$(md5sum "$scriptloc" | awk '{print $1}')" ]; then
			sed -i '/^vpnmon_r3.*/d' "${add}"/availUpd.txt
			upd="${E_BG}${NC}$lvtpu"
			unset localver $vpnmon_r3Upate vpnmon_r3MD5
		fi
	fi
	[ -z "$updcheck" ] && printf "${GN_BG} v3${NC} %-9s%-21s%${COR}s\\n" "open" "VPNMON-R3 $localver" " $upd"
	case_v3(){
		trap trap_ctrl 2
		trap_ctrl(){
			sleep 2
			echo "${NC}"
			exec "$0"
		}
		/jffs/scripts/vpnmon-r3.sh -setup
		trap - 2
		sleep 2
		show_amtm menu
	}
}
install_vpnmon_r3(){
	p_e_l
	echo " This installs VPNMON-R3 - Monitor the health of your VPN connection"
	echo " on your router."
	echo
	echo " Author: Viktor Jaep"
	echo " https://www.snbforums.com/forums/asuswrt-merlin-addons.60/?prefix_id=36"
	c_d

	c_url https://raw.githubusercontent.com/ViktorJp/VPNMON-R3/main/vpnmon-r3.sh -o /jffs/scripts/vpnmon-r3.sh && chmod 755 /jffs/scripts/vpnmon-r3.sh && /jffs/scripts/vpnmon-r3.sh -setup
	sleep 2
	if [ -f /jffs/scripts/vpnmon-r3.sh ]; then
		show_amtm " VPNMON-R3 installed"
	else
		am=;show_amtm " VPNMON-R3 installation failed"
	fi
}
#eof
