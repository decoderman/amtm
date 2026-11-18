#!/bin/sh
#bof
WiFiInsight_installed(){
	localVother="$(grep ^VERSION= "$scriptloc" | cut -d'"' -f2)"
	if [ "$su" = 1 ]; then
		remoteurl=https://github.com/IfSugar/wifiinsight/releases/latest/download/wifiinsight.sh
		remoteVother="$(c_url "$remoteurl" | grep ^VERSION= | cut -d'"' -f2)"
		grepcheck=IfSugar
	fi
	script_check
	if [ -z "$su" -a -z "$tpu" ] && [ "$WiFiInsightUpdate" ]; then
		localver="$lvtpu"
		upd="${E_BG}$WiFiInsightUpdate${NC}"
		if [ "$WiFiInsightMD5" != "$(md5sum "$scriptloc" | awk '{print $1}')" ]; then
			[ -f "${add}"/availUpd.txt ] && sed -i '/^WiFiInsight.*/d' "${add}"/availUpd.txt
			upd="${E_BG}${NC}$lvtpu"
			unset localver WiFiInsightUpdate WiFiInsightMD5
		fi
	fi
	[ -z "$updcheck" -a -z "$ss" ] && printf "${GN_BG} in${NC} %-9s%-21s%${COR}s\\n" "open" "WiFi Insight  $localver" " $upd"
	case_in(){
		/jffs/addons/wifiinsight/wifiinsight.sh
		sleep 2
		show_amtm menu
	}
}
install_WiFiInsight(){
	p_e_l
	printf " This installs WiFi Insight - Asuswrt-Merlin\\n WiFI Channel monitor on your router.\\n\\n"
	printf " Author: Scoty\\n snbforums.com/threads/98228/\\n"
	c_d
	c_url https://github.com/IfSugar/wifiinsight/releases/latest/download/wifiinsight.sh -o /tmp/wifiinsight.sh && sh /tmp/wifiinsight.sh install
	p_e_t "return to amtm"
	if [ -f /jffs/addons/wifiinsight/wifiinsight.sh ]; then
		show_amtm " WiFi Insight installed"
	else
		am=;show_amtm " WiFi Insight installation failed"
	fi
}
#eof
