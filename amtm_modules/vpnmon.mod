#!/bin/sh
#bof
vpnmon_installed(){
	scriptname=vpnmon
	localVother="$(grep ^version "$scriptloc" | awk '{print $1}' | sed -e 's/version=//;s/"//g')"
	if [ "$su" = 1 ]; then
		remoteurl=https://raw.githubusercontent.com/ViktorJp/VPNMON-R3/main/vpnmon-r3.sh
		remoteVother="$(c_url "$remoteurl" | grep ^version | awk '{print $1}' | sed -e 's/version=//;s/"//g')"
		grepcheck=VPNMON-R3
	fi
	script_check
	if [ -z "$su" -a -z "$tpu" ] && [ "$vpnmon_r3Upate" ]; then
		localver="$lvtpu"
		upd="${E_BG}$vpnmon_r3Upate${NC}"
		if [ "$vpnmon_r3MD5" != "$(md5sum "$scriptloc" | awk '{print $1}')" ]; then
			sed -i '/^vpnmon_r3.*/d' "${add}"/availUpd.txt
			upd="${E_BG}${NC}$lvtpu"
			unset localver vpnmon_r3Upate vpnmon_r3MD5
		fi
	fi
	[ -z "$updcheck" -a -z "$ss" ] && printf "${GN_BG} vp${NC} %-9s%-21s%${COR}s\\n" "open" "VPNMON-R3      $localver" " $upd"
	case_vp(){
		trap trap_ctrl 2
		trap_ctrl(){
			sleep 2
			echo "${NC}"
			exec "$0"
		}
		[ ! -x /jffs/scripts/vpnmon-r3.sh ] && chmod 0755 /jffs/scripts/vpnmon-r3.sh
		/jffs/scripts/vpnmon-r3.sh
		trap - 2
		sleep 2
		show_amtm menu
	}
}
install_vpnmon(){
	p_e_l
	printf " This installs VPNMON-R3 - Monitor WAN,\\n Dual WAN or VPN Health & Reset Multiple VPN\\n Connections on your router.\\n\\n"
	printf " Author: Viktor Jaep\\n snbforums.com/forums/asuswrt-merlin-addons.60/?prefix_id=36\\n"
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
