#!/bin/sh
#bof
vpn_routing_installed(){
	scriptname='VPN Routing'
	scriptgrep='^VERSION='
	devmode=
	branch=domain_vpn_routing.sh
	if [ -f /jffs/configs/domain_vpn_routing/global.conf ] && grep -q 'DEVMODE=1' /jffs/configs/domain_vpn_routing/global.conf; then
		devmode=D
		branch=domain_vpn_routing-beta.sh
	fi

	if [ "$su" = 1 ]; then
		remoteurl=https://raw.githubusercontent.com/Ranger802004/asusmerlin/main/domain_vpn_routing/$branch
		grepcheck=Ranger802004
	fi
	script_check
	if [ -z "$su" -a -z "$tpu" ] && [ "$VPN_RoutingUpate" ]; then
		localver="$lvtpu"
		upd="${E_BG}$VPN_RoutingUpate${NC}"
		if [ "$VPN_RoutingMD5" != "$(md5sum "$scriptloc" | awk '{print $1}')" ]; then
			[ -f "${add}"/availUpd.txt ] && sed -i '/^VPN_Routing.*/d' "${add}"/availUpd.txt
			upd="${E_BG}${NC}$lvtpu"
			unset localver VPN_RoutingUpate VPN_RoutingMD5
		fi
	fi
	[ -z "$updcheck" -a -z "$ss" ] && printf "${GN_BG} vr${NC} %-9s%-21s%${COR}s\\n" "open" "VPN Routing $devmode $localver" " $upd"
	case_vr(){
		trap trap_ctrl 2
		trap_ctrl(){
			sleep 2
			exec "$0"
		}
		/jffs/scripts/domain_vpn_routing.sh
		trap - 2
		sleep 2
		show_amtm menu
	}
}
install_vpn_routing(){
	p_e_l
	printf " This installs Domain-based VPN Routing - route\\n specific website domains to specific VPN\\n tunnels on your router.\\n\\n"
	printf " Author: Ranger802004\\n snbforums.com/threads/domain-based-vpn-routing-script.79264/\\n"
	c_d
	c_url https://raw.githubusercontent.com/Ranger802004/asusmerlin/main/domain_vpn_routing/domain_vpn_routing.sh -o /jffs/scripts/domain_vpn_routing.sh && chmod 755 /jffs/scripts/domain_vpn_routing.sh && sh /jffs/scripts/domain_vpn_routing.sh install
	sleep 2
	if [ -f /jffs/scripts/domain_vpn_routing.sh ]; then
		show_amtm " Domain-based VPN Routing installed"
	else
		am=;show_amtm " Domain-based VPN Routing installation failed"
	fi
}
#eof
