#!/bin/sh
#bof
WAN_Failover_installed(){
	scriptname='Dual WAN Failover'
	scriptgrep='^VERSION='
	dwftext=$scriptname

	devmode=
	branch=wan-failover.sh
	if [ -f /jffs/configs/wan-failover.conf ] && grep -q 'DEVMODE=1' /jffs/configs/wan-failover.conf; then
		devmode=D
		branch=wan-failover-beta.sh
	fi

	if [ "$su" = 1 ]; then
		remoteurl=https://raw.githubusercontent.com/Ranger802004/asusmerlin/main/$branch
		grepcheck=Ranger802004
	fi
	script_check
	if [ -z "$su" -a -z "$tpu" ] && [ "$Dual_WAN_FailoverUpate" ]; then
		dwftext='WAN Failover'
		localver="$lvtpu"
		upd="${E_BG}$Dual_WAN_FailoverUpate${NC}"
		if [ "$Dual_WAN_FailoverMD5" != "$(md5sum "$scriptloc" | awk '{print $1}')" ]; then
			[ -f "${add}"/availUpd.txt ] && sed -i '/^Dual_WAN_Failover.*/d' "${add}"/availUpd.txt
			upd="${E_BG}${NC}$lvtpu"
			unset localver Dual_WAN_FailoverUpate Dual_WAN_FailoverMD5
			dwftext=$scriptname
		fi
	fi
	[ "$suUpd" = 1 ] && dwftext='WAN Failover'
	[ -z "$updcheck" -a -z "$ss" ] && printf "${GN_BG} wf${NC} %-9s%-21s%${COR}s\\n" "open" "$dwftext $devmode $localver" " $upd"
	case_wf(){
		trap trap_ctrl 2
		trap_ctrl(){
			sleep 2
			exec "$0"
		}
		/jffs/scripts/wan-failover.sh
		trap - 2
		sleep 2
		show_amtm menu
	}
}
install_WAN_Failover(){
	p_e_l
	printf " This installs Dual WAN Failover - replace the\\n factory ASUS WAN Failover functionality\\n on your router.\\n\\n"
	printf " Author: Ranger802004\\n snbforums.com/threads/dual-wan-failover-v2-0-1-release.83674/\\n"
	c_d
	c_url https://raw.githubusercontent.com/Ranger802004/asusmerlin/main/wan-failover.sh -o "/jffs/scripts/wan-failover.sh" && chmod 755 /jffs/scripts/wan-failover.sh && sh /jffs/scripts/wan-failover.sh install
	sleep 2
	if [ -f /jffs/scripts/wan-failover.sh ]; then
		show_amtm " Dual WAN Failover installed"
	else
		am=;show_amtm " Dual WAN Failover installation failed"
	fi
}
#eof
