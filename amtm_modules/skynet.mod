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
	if [ -z "$su" -a -z "$tpu" ] && [ "$SkynetUpate" ]; then
		localver="$lvtpu"
		upd="${E_BG}$SkynetUpate${NC}"
		if [ "$SkynetMD5" != "$(md5sum "$scriptloc" | awk '{print $1}')" ]; then
			sed -i '/^Skynet.*/d' "${add}"/availUpd.txt
			upd="${E_BG}${NC}$lvtpu"
			unset localver SkynetUpate SkynetMD5
		fi
	fi
	[ -z "$updcheck" ] && printf "${GN_BG} 2 ${NC} %-9s%-21s%${COR}s\\n" "open" "Skynet        $localver" " $upd"
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
	echo " https://www.snbforums.com/forums/asuswrt-merlin-addons.60/?prefix_id=14"
	echo
	echo " Regular contributor: SomeWhereOverTheRainBow"
	echo " https://www.snbforums.com/members/somewhereovertherainbow.64179/"
	c_d

	if ! ipset -v 2>/dev/null | grep -qE 'v6|v7'; then
		am=;show_amtm " Skynet install aborted,\\n IPSet version on router not supported:\\n$(ipset -v 2>/dev/null | sed -e 's/^/ /')"
	elif [ ! -f /lib/modules/"$(uname -r)"/kernel/net/netfilter/ipset/ip_set_hash_ipmac.ko ]; then
		am=;show_amtm " Skynet install aborted,\\n IPSet extension not supported, please\\n update router to latest Firmware version."
	else
		c_url "https://raw.githubusercontent.com/Adamm00/IPSet_ASUS/master/firewall.sh" -o "/jffs/scripts/firewall" && chmod +x /jffs/scripts/firewall && sh /jffs/scripts/firewall install
		sleep 2
		if [ -f /jffs/scripts/firewall ]; then
			show_amtm " Skynet installed"
		else
			am=;show_amtm " Skynet installation failed"
		fi
	fi
}
#eof
