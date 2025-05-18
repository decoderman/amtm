#!/bin/sh
#bof
FlexQoS_installed(){
	scriptname='FlexQoS'
	localVother="$(grep "^version=" /jffs/addons/flexqos/flexqos.sh | sed -e 's/version=//')"
	if [ "$su" = 1 ]; then
		remoteurl=https://raw.githubusercontent.com/AMTM-OSR/FlexQoS/master/flexqos.sh
		remoteVother="$(c_url "$remoteurl" | grep "^version=" | sed -e 's/version=//')"
		grepcheck=FlexQoS
	fi
	script_check
	if [ -z "$su" -a -z "$tpu" ] && [ "$FlexQoSUpate" ]; then
		localver="$lvtpu"
		upd="${E_BG}$FlexQoSUpate${NC}"
		if [ "$FlexQoSMD5" != "$(md5sum "$scriptloc" | awk '{print $1}')" ]; then
			[ -f "${add}"/availUpd.txt ] && sed -i '/^FlexQoS.*/d' "${add}"/availUpd.txt
			upd="${E_BG}${NC}$lvtpu"
			unset localver FlexQoSUpate FlexQoSMD5
		fi
	fi
	[ -z "$updcheck" -a -z "$ss" ] && printf "${GN_BG} 3 ${NC} %-9s%-21s%${COR}s\\n" "open" "FlexQoS       $localver" " $upd"
	case_3(){
		/jffs/addons/flexqos/flexqos.sh menu
		sleep 1
		show_amtm menu
	}
}
install_FlexQoS(){
	p_e_l
	printf " This installs FlexQoS - Flexible QoS\\n Enhancement Script for Adaptive QoS\\n on your router.\\n\\n"
	printf " Original Author: dave14305\\n snbforums.com/forums/asuswrt-merlin-addons.60/?prefix_id=8&starter_id=58901\\n"
	printf " With contributions from the AMTM-OSR team.\\n\\n This script is hosted by AMTM-OSR,\\n"
	printf " the AMTM Orphaned Script Revival repository:\\n https://github.com/AMTM-OSR/FlexQoS\\n"
	c_d
	c_url https://raw.githubusercontent.com/AMTM-OSR/FlexQoS/master/flexqos.sh -o /jffs/addons/flexqos/flexqos.sh --create-dirs && chmod +x /jffs/addons/flexqos/flexqos.sh && sh /jffs/addons/flexqos/flexqos.sh -install
	if [ -f /jffs/addons/flexqos/flexqos.sh ]; then
		sleep 4
		show_amtm " FlexQoS installed"
	else
		am=;show_amtm " FlexQoS installation failed"
	fi
}
#eof
