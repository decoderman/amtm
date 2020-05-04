#!/bin/sh
#bof
x3mRouting_installed(){
	scriptname='x3mRouting Selective Routing'
	localVother="v$(grep "^VERSION=" "$scriptloc" | sed -e 's/VERSION=//;s/"//g')"
	if [ "$su" = 1 ]; then
		remoteurl="https://raw.githubusercontent.com/Xentrk/x3mRouting/master/x3mRouting"
		remoteVother="v$(c_url "$remoteurl" | grep "^VERSION=" | sed -e 's/VERSION=//;s/"//g')"
		grepcheck=Xentrk
	fi
	script_check
	if [ -z "$su" -a -z "$tpu" ] && [ "$x3mRouting_Selective_RoutingUpate" ]; then
		localver="$lvtpu"
		upd="${E_BG}$x3mRouting_Selective_RoutingUpate${NC}"
		if [ "$x3mRouting_Selective_RoutingMD5" != "$(md5sum "$scriptloc" | awk '{print $1}')" ]; then
			sed -i '/^x3mRouting_Selective_Routing.*/d' "${add}"/availUpd.txt
			upd="${E_BG}${NC}$lvtpu"
			unset localver x3mRouting_Selective_RoutingUpate x3mRouting_Selective_RoutingMD5
		fi
	fi
	printf "${GN_BG} 6 ${NC} %-9s%-21s%${COR}s\\n" "open" "x3mRouting    $localver" " $upd"
	case_6(){
		/opt/bin/x3mRouting
		sleep 2
		show_amtm menu
	}
}
install_x3mRouting(){
	p_e_l
	echo " This installs x3mRouting - Selective Routing for Asuswrt-Merlin"
	echo " on your router."
	echo
	echo " Author: Xentrk"
	echo " https://www.snbforums.com/threads/x3mrouting-selective-routing-for-asuswrt-merlin-firmware.57793/"
	c_d

	c_url "https://raw.githubusercontent.com/Xentrk/x3mRouting/master/x3mRouting" -o "/opt/bin/x3mRouting" && chmod 755 /opt/bin/x3mRouting && x3mRouting
	sleep 2
	if [ -f /opt/bin/x3mRouting ]; then
		show_amtm " x3mRouting Selective Routing installed"
	else
		am=;show_amtm " x3mRouting Selective Routing installation failed"
	fi
}
#eof
