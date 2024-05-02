#!/bin/sh
#bof
unbound_manager_installed(){
	scriptname='unbound Manager'
	localVother="$(grep "^VERSION=" "$scriptloc" | sed -e 's/VERSION=//;s/"//g')"
	scriptgrep='^VERSION='
	umtext=$scriptname
	if [ "$su" = 1 ]; then
		remoteurl=https://raw.githubusercontent.com/MartineauUK/Unbound-Asuswrt-Merlin/master/unbound_manager.sh
		remoteVother="$(c_url "$remoteurl" | grep "^VERSION=" | sed -e 's/VERSION=//;s/"//g')"
		grepcheck=Martineau
	fi
	script_check
	if [ -z "$su" -a -z "$tpu" ] && [ "$unbound_ManagerUpate" ]; then
		umtext='unbound Mgr'
		localver="$lvtpu"
		upd="${E_BG}$unbound_ManagerUpate${NC}"
		if [ "$unbound_ManagerMD5" != "$(md5sum "$scriptloc" | awk '{print $1}')" ]; then
			[ -f "${add}"/availUpd.txt ] && sed -i '/^unbound_Manager.*/d' "${add}"/availUpd.txt
			upd="${E_BG}${NC}$lvtpu"
			unset localver unbound_ManagerUpate unbound_ManagerMD5
			umtext=$scriptname
		fi
	fi
	[ "$suUpd" = 1 ] && umtext='unbound Mgr'
	[ -z "$updcheck" -a -z "$ss" ] && printf "${GN_BG} 7 ${NC} %-9s%-21s%${COR}s\\n" "open" "$umtext    $localver" " $upd"
	case_7(){
		trap trap_ctrl 2
		trap_ctrl(){
			sleep 2
			exec "$0"
		}
		/jffs/addons/unbound/unbound_manager.sh easy
		trap - 2
		sleep 2
		show_amtm menu
	}
}
install_unbound_manager(){
	p_e_l
	printf " This installs unbound Manager - Manager/Installer\\n utility for unbound on your router.\\n\\n"
	printf " Author: Martineau\\n snbforums.com/forums/asuswrt-merlin-addons.60/?prefix_id=5\\n\\n"
	printf " Contributors: rgnldo, dave14305, SomeWhereOverTheRainbow,\\n Cam, Xentrk, thelonelycoder\\n"
	c_d
	mkdir -p /jffs/addons/unbound
	c_url https://raw.githubusercontent.com/MartineauUK/Unbound-Asuswrt-Merlin/master/unbound_manager.sh -o /jffs/addons/unbound/unbound_manager.sh && chmod 755 /jffs/addons/unbound/unbound_manager.sh && /jffs/addons/unbound/unbound_manager.sh
	sleep 2
	if [ -f /jffs/addons/unbound/unbound_manager.sh ]; then
		show_amtm " unbound Manager installed"
	else
		am=;show_amtm " unbound Manager installation failed"
	fi
}
#eof
