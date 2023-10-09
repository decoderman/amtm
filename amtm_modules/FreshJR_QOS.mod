#!/bin/sh
#bof
FreshJR_QOS_installed(){
	scriptname='FreshJR QOS'
	localVother="$(grep "^version=" /jffs/scripts/FreshJR_QOS | sed -e 's/version=//')"
	if [ "$su" = 1 ]; then
		remoteurl=https://raw.githubusercontent.com/FreshJR07/FreshJR_QOS/master/FreshJR_QOS.sh
		remoteVother="$(c_url "$remoteurl" | grep "^version=" | sed -e 's/version=//')"
		grepcheck=FreshJR
	fi
	script_check
	if [ -z "$su" -a -z "$tpu" ] && [ "$FreshJR_QOSUpate" ]; then
		localver="$lvtpu"
		upd="${E_BG}$FreshJR_QOSUpate${NC}"
		if [ "$FreshJR_QOSMD5" != "$(md5sum "$scriptloc" | awk '{print $1}')" ]; then
			sed -i '/^FreshJR_QOS.*/d' "${add}"/availUpd.txt
			upd="${E_BG}${NC}$lvtpu"
			unset localver FreshJR_QOSUpate FreshJR_QOSMD5
		fi
	fi
	[ -z "$updcheck" ] && printf "${GN_BG} 3d${NC} %-9s%-21s%${COR}s\\n" "open" "FreshJR QOS   $localver" " $upd"
	case_3d(){
		/jffs/scripts/FreshJR_QOS -menu
		sleep 1
		show_amtm menu
	}
}
install_FreshJR_QOS(){
	if [ -f /jffs/addons/flexqos/flexqos.sh ]; then
		am=;show_amtm " ! FreshJR QOS is not available to install.\\n Its successor FlexQoS is already installed."
	fi
	p_e_l
	echo " This installs FreshJR Adaptive QOS - Improvements, Custom Rules and Inner workings"
	echo " on your router."
	echo
	echo " Author: FreshJR"
	echo " https://www.snbforums.com/forums/asuswrt-merlin-addons.60/"
	echo
	echo " Note that FreshJR QOS is no longer actively developed."
	echo " Use its successor by dave14305 instead:"
	echo " FlexQoS - Flexible QoS Enhancement Script for Adaptive QoS instead."
	c_d

	c_url https://raw.githubusercontent.com/FreshJR07/FreshJR_QOS/master/FreshJR_QOS.sh -o /jffs/scripts/FreshJR_QOS --create-dirs
	c_url https://raw.githubusercontent.com/FreshJR07/FreshJR_QOS/master/FreshJR_QoS_Stats.asp -o /jffs/scripts/www_FreshJR_QoS_Stats.asp
	sh /jffs/scripts/FreshJR_QOS -install

	p_e_t "return to amtm menu"

	if [ -f /jffs/scripts/FreshJR_QOS ]; then
		show_amtm " FreshJR Adaptive QOS installed"
	else
		am=;show_amtm " FreshJR Adaptive QOS installation failed"
	fi
}
#eof
