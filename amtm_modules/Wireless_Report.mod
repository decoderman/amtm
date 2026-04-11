#!/bin/sh
#bof
Wireless_Report_installed(){
	scriptgrep='^SCRIPT_VERSION='
	if [ "$su" = 1 ]; then
		remoteurl=https://raw.githubusercontent.com/JB1366/Wireless_Report/main/wirelessreport.sh
		grepcheck=JB_1366
	fi
	script_check
	if [ -z "$su" -a -z "$tpu" ] && [ "$Wireless_ReportUpdate" ]; then
		localver="$lvtpu"
		upd="${E_BG}$Wireless_ReportUpdate${NC}"
		if [ "$Wireless_ReportMD5" != "$(md5sum "$scriptloc" | awk '{print $1}')" ]; then
			[ -f "${add}"/availUpd.txt ] && sed -i '/^Wireless_Report.*/d' "${add}"/availUpd.txt
			upd="${E_BG}${NC}$lvtpu"
			unset localver Wireless_ReportUpdate Wireless_ReportMD5
		fi
	fi
	[ -z "$updcheck" -a -z "$ss" ] && printf "${GN_BG} wr${NC} %-9s%-21s%${COR}s\\n" "open" "Wireless Report $localver" " $upd"
	case_wr(){
		/jffs/addons/wireless_report/wirelessreport.sh install
		sleep 2
		show_amtm menu
	}
}
install_Wireless_Report(){
	p_e_l
	printf " This installs Wireless Report - Wireless Report for AiMesh\\n on your router.\\n\\n"
	printf " Author: JB_1366\\n snbforums.com/threads/wireless-report-for-aimesh-v1-3-5-apr-9-2026.96861\\n"
	c_d
	c_url https://raw.githubusercontent.com/JB1366/Wireless_Report/main/wirelessreport.sh -o /tmp/wirelessreport.sh && sh /tmp/wirelessreport.sh install
	sleep 2
	if [ -f /jffs/addons/wireless_report/wirelessreport.sh ]; then
		show_amtm " Wireless Report installed"
	else
		am=;show_amtm " Wireless Report installation failed"
	fi
}
#eof
