#!/bin/sh
#bof
unbound_manager_installed(){
	scriptname='unbound Manager'
	localVother="v$(grep "^VERSION=" "$scriptloc" | sed -e 's/VERSION=//;s/"//g')"
	scriptgrep='^VERSION='
	umtext=$scriptname
	if [ "$su" = 1 ]; then
		remoteurl="https://raw.githubusercontent.com/MartineauUK/Unbound-Asuswrt-Merlin/master/unbound_manager.sh"
		remoteVother="v$(c_url "$remoteurl" | grep "^VERSION=" | sed -e 's/VERSION=//;s/"//g')"
		grepcheck=Martineau
	fi
	script_check
	[ "$suUpd" = 1 ] && umtext='unbound Mgr'
	printf "${GN_BG} 7 ${NC} %-9s%-21s%${COR}s\\n" "open" "$umtext    $localver" " $upd"
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
	echo " This installs unbound Manager - Manager/Installer utility for unbound"
	echo " on your router."
	echo
	echo " Author: Martineau"
	echo " https://www.snbforums.com/threads/release-unbound_manager-management-installer-utility-for-unbound-recursive-dns-server.61669/"
	echo
	echo " Contributors: rgnldo, dave14305, SomeWhereOverTheRainbow, Cam, Xentrk, thelonelycoder"
	c_d

	mkdir -p /jffs/addons/unbound
	c_url "https://raw.githubusercontent.com/MartineauUK/Unbound-Asuswrt-Merlin/master/unbound_manager.sh" -o "/jffs/addons/unbound/unbound_manager.sh" && chmod 755 "/jffs/addons/unbound/unbound_manager.sh" && /jffs/addons/unbound/unbound_manager.sh
	sleep 2
	if [ -f /jffs/addons/unbound/unbound_manager.sh ]; then
		show_amtm " unbound Manager installed"
	else
		am=;show_amtm " unbound Manager installation failed"
	fi
}
#eof
