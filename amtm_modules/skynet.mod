#!/bin/sh
#bof
skynet_installed(){
	scriptname=Skynet
	localVother=$(grep -m1 -oE 'v[0-9]{1,2}([.][0-9]{1,2})([.][0-9]{1,2})' "$scriptloc")
	if [ "$su" = 1 ]; then
		remoteurl="https://raw.githubusercontent.com/Adamm00/IPSet_ASUS/master/firewall.sh"
		remoteVother="$(c_url "$remoteurl" | grep -m1 -oE 'v[0-9]{1,2}([.][0-9]{1,2})([.][0-9]{1,2})')"
		grepcheck=Adamm
	fi
	script_check
	printf "${GN_BG} 2 ${NC} %-9s%-21s%${COR}s\\n" "open" "Skynet        $localver" " $upd"
	case_2(){
		/jffs/scripts/firewall
		sleep 2
		show_amtm menu
	}
}
install_skynet(){
	p_e_l
	echo " This installs Skynet - Router Firewall & Security Enhancements"
	echo " on your router."
	echo
	echo " Author: Adamm"
	echo " https://www.snbforums.com/threads/release-skynet-router-firewall-security-enhancements.16798/"
	c_d

	if ! ipset -v | grep -qF "v6"; then
		am=;show_amtm " Skynet install failed,\\n IPSet version on router not supported:\\n\\n$(ipset -v | sed -e 's/^/ /')"
	fi

	c_url "https://raw.githubusercontent.com/Adamm00/IPSet_ASUS/master/firewall.sh" -o "/jffs/scripts/firewall" && chmod +x /jffs/scripts/firewall && sh /jffs/scripts/firewall install
	sleep 2
	if [ -f /jffs/scripts/firewall ] && grep -qE "sh /jffs/scripts/firewall .* # Skynet" /jffs/scripts/firewall-start 2> /dev/null; then
		show_amtm " Skynet installed"
	else
		rm -f /jffs/scripts/firewall
		am=;show_amtm " Skynet installation failed"
	fi
}
#eof
