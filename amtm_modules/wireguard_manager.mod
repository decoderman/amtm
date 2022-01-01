#!/bin/sh
#bof
wireguard_manager_installed(){
	scriptname='WireGuard Session Manager'
	localVother="$(grep '^VERSION="v' "$scriptloc" | sed -e 's/VERSION=//;s/"//g')"
	scriptgrep='^VERSION="v'
	umtext='WireGuard Mgr'
	if [ "$su" = 1 ]; then
		remoteurl="https://raw.githubusercontent.com/MartineauUK/wireguard/main/wg_manager.sh"
		remoteVother="$(c_url "$remoteurl" | grep '^VERSION="v' | sed -e 's/VERSION=//;s/"//g')"
		grepcheck=Martineau
	fi
	script_check
	if [ -z "$su" -a -z "$tpu" ] && [ "$WireGuard_Session_ManagerUpate" ]; then
		localver="$lvtpu"
		upd="${E_BG}$WireGuard_Session_ManagerUpate${NC}"
		if [ "$WireGuard_Session_ManagerMD5" != "$(md5sum "$scriptloc" | awk '{print $1}')" ]; then
			sed -i '/^WireGuard_Session_Manager.*/d' "${add}"/availUpd.txt
			upd="${E_BG}${NC}$lvtpu"
			unset localver WireGuard_Session_ManagerUpate WireGuard_Session_ManagerMD5
		fi
	fi
	[ "$suUpd" = 1 ] && umtext='WireGuard SM'
	[ -z "$updcheck" ] && printf "${GN_BG} wg${NC} %-9s%-21s%${COR}s\\n" "open" "$umtext    $localver" " $upd"
	case_wg(){
		/jffs/addons/wireguard/wg_manager.sh
		sleep 2
		show_amtm menu
	}
}
install_wireguard_manager(){
	p_e_l
	echo " This installs WireGuard Session Manager"
	echo " on your router."
	echo
	echo " Author: Martineau"
	echo " https://www.snbforums.com/forums/asuswrt-merlin-addons.60/?prefix_id=32&starter_id=13215"
	echo
	echo " Contributors: odkrys, Torson, ZebMcKayhan, jobhax, elorimer"
	echo " Sh0cker54, here1310, defung, The Chief"
	c_d

	c_url "https://raw.githubusercontent.com/MartineauUK/wireguard/main/wg_manager.sh" --create-dirs -o "/jffs/addons/wireguard/wg_manager.sh" && chmod 755 "/jffs/addons/wireguard/wg_manager.sh" && /jffs/addons/wireguard/wg_manager.sh install
	sleep 2
	if [ -f /jffs/addons/wireguard/wg_manager.sh ]; then
		show_amtm " WireGuard Session Manager installed"
	else
		am=;show_amtm " WireGuard Session Manager installation failed"
	fi
}
#eof
