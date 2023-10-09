#!/bin/sh
#bof
vpnmon_installed(){
	scriptname=vpnmon
	localVother="$(grep ^Version "$scriptloc" | awk '{print $1}' | sed -e 's/Version=//;s/"//g')"
	if [ "$su" = 1 ]; then
		remoteurl=https://raw.githubusercontent.com/ViktorJp/VPNMON-R2/main/vpnmon-r2.sh
		remoteVother="$(c_url "$remoteurl" | grep ^Version | awk '{print $1}' | sed -e 's/Version=//;s/"//g')"
		grepcheck=ViktorJp
	fi
	script_check
	if [ -z "$su" -a -z "$tpu" ] && [ "$vpnmonUpate" ]; then
		localver="$lvtpu"
		upd="${E_BG}$vpnmonUpate${NC}"
		if [ "$vpnmonMD5" != "$(md5sum "$scriptloc" | awk '{print $1}')" ]; then
			sed -i '/^vpnmon.*/d' "${add}"/availUpd.txt
			upd="${E_BG}${NC}$lvtpu"
			unset localver vpnmonUpate vpnmonMD5
		fi
	fi
	[ -z "$updcheck" ] && printf "${GN_BG} vp${NC} %-9s%-21s%${COR}s\\n" "open" "VPNMON-R2      $localver" " $upd"
	case_vp(){
		trap trap_ctrl 2
		trap_ctrl(){
			sleep 2
			echo "${NC}"
			exec "$0"
		}
		/jffs/scripts/vpnmon-r2.sh -setup
		trap - 2
		sleep 2
		show_amtm menu
	}
}
install_vpnmon(){
	p_e_l
	echo " This installs VPNMON-R2 - Monitor the health of your VPN connection"
	echo " on your router."
	echo
	echo " Author: Viktor Jaep"
	echo " https://www.snbforums.com/forums/asuswrt-merlin-addons.60/?prefix_id=36"
	c_d

	c_url https://raw.githubusercontent.com/ViktorJp/VPNMON-R2/main/vpnmon-r2.sh -o /jffs/scripts/vpnmon-r2.sh && chmod a+rx /jffs/scripts/vpnmon-r2.sh && /jffs/scripts/vpnmon-r2.sh -setup
	sleep 2
	if [ -f /jffs/scripts/vpnmon-r2.sh ]; then
		show_amtm " VPNMON-R2 installed"
	else
		am=;show_amtm " VPNMON-R2 installation failed"
	fi
}
#eof
