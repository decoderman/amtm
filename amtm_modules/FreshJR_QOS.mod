#!/bin/sh
#bof
FreshJR_QOS_installed(){
	scriptname='FreshJR QOS'
	localVother="v$(grep "^version=" /jffs/scripts/FreshJR_QOS | sed -e 's/version=//')"
	if [ "$su" = 1 ]; then
		remoteurl="https://raw.githubusercontent.com/dave14305/FreshJR_QOS/master/FreshJR_QOS.sh"
		remoteVother="v$(c_url "$remoteurl" | grep "^version=" | sed -e 's/version=//')"
		grepcheck=FreshJR
	fi
	script_check
	printf "${GN_BG} 3 ${NC} %-9s%-21s%${COR}s\\n" "open" "FreshJR QOS   $localver" " $upd"
	case_3(){
		/jffs/scripts/FreshJR_QOS -menu
		sleep 1
		show_amtm menu
	}
}
install_FreshJR_QOS(){
	p_e_l
	echo " This installs FreshJR Adaptive QOS - Improvements, Custom Rules and Inner workings"
	echo " on your router."
	echo
	echo " Author: FreshJR"
	echo " https://www.snbforums.com/threads/release-freshjr-adaptive-qos-improvements-custom-rules-and-inner-workings.36836/"
	c_d

	c_url "https://raw.githubusercontent.com/FreshJR07/FreshJR_QOS/master/FreshJR_QOS.sh" -o /jffs/scripts/FreshJR_QOS --create-dirs
	c_url "https://raw.githubusercontent.com/FreshJR07/FreshJR_QOS/master/FreshJR_QoS_Stats.asp" -o /jffs/scripts/www_FreshJR_QoS_Stats.asp
	sh /jffs/scripts/FreshJR_QOS -install

	p_e_t "return to amtm menu"

	if [ -f "/jffs/scripts/FreshJR_QOS" ] && grep -q -x '/jffs/scripts/FreshJR_QOS -start $1 & ' /jffs/scripts/firewall-start; then
		show_amtm " FreshJR Adaptive QOS installed"
	else
		am=;show_amtm " FreshJR Adaptive QOS installation failed"
	fi
}
#eof
