#!/bin/sh
#bof
unbound_stats_installed(){
	scriptgrep=' SCRIPT_VERSION='
	if [ "$su" = 1 ]; then
		remoteurl=https://raw.githubusercontent.com/juched78/Unbound-Asuswrt-Merlin/master/unbound_stats.sh
		grepcheck=juched
	fi
	script_check
	if [ -z "$su" -a -z "$tpu" ] && [ "$Unbound_StatsUpdate" ]; then
		localver="$lvtpu"
		upd="${E_BG}$Unbound_StatsUpdate${NC}"
		if [ "$Unbound_StatsMD5" != "$(md5sum "$scriptloc" | awk '{print $1}')" ]; then
			[ -f "${add}"/availUpd.txt ] && sed -i '/^Unbound_Stats.*/d' "${add}"/availUpd.txt
			upd="${E_BG}${NC}$lvtpu"
			unset localver Unbound_StatsUpdate Unbound_StatsMD5
		fi
	fi
	[ -z "$updcheck" -a -z "$ss" ] && printf "${GN_BG} us${NC} %-9s%-21s%${COR}s\\n" "open" "Unbound Stats  $localver" " $upd"
	case_us(){
		trap trap_ctrl 2
		trap_ctrl(){
			sleep 2
			exec "$0"
		}
		/jffs/addons/unbound/unbound_stats.sh
		trap - 2
		sleep 2
		show_amtm menu
	}
}
install_unbound_stats(){
	p_e_l
	printf " This installs Unbound Stats - Generate Stats for Unbound on your router.\\n\\n"
	printf " Author: juched78\\n"
	printf " Regular contributor: Martinski\\n snbforums.com/threads/unbound-stats-for-asuswrt-merlin-v1-4-6-2026-mar-28-generate-stats-for-unbound.95533//\\n"
	c_d
	if [ -f /jffs/addons/unbound/unbound_manager.sh ]; then
		c_url https://raw.githubusercontent.com/juched78/Unbound-Asuswrt-Merlin/master/unbound_stats.sh -o /jffs/addons/unbound/unbound_stats.sh && chmod 755 /jffs/addons/unbound/unbound_stats.sh && /jffs/addons/unbound/unbound_stats.sh install
	else
		am=;show_amtm " Unbound Stats requires unbound Manager installed."
	fi
	sleep 2
	if [ -f /jffs/addons/unbound/unbound_stats.sh ]; then
		show_amtm " Unbound Stats installed"
	else
		am=;show_amtm " Unbound Stats installation failed"
	fi
}
#eof
