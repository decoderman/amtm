#!/bin/sh
#bof
wicens_installed(){
	scriptname='WAN IP Notification'
	localVother="$(grep "^script_version=" "$scriptloc" | sed -e "s/script_version=//;s/'//g")"
	witext=$scriptname
	if [ "$su" = 1 ]; then
		remoteurl=https://raw.githubusercontent.com/maverickcdn/wicens/master/wicens.sh
		remoteVother="$(c_url "$remoteurl" | grep "^script_version=" | sed -e "s/script_version=//;s/'//g")"
		grepcheck=maverickcdn
	fi
	script_check
	if [ -z "$su" -a -z "$tpu" ] && [ "$wicensUpate" ]; then
		witext='WICENS'
		localver="$lvtpu"
		upd="${E_BG}$wicensUpate${NC}"
		if [ "$wicensMD5" != "$(md5sum "$scriptloc" | awk '{print $1}')" ]; then
			sed -i '/^wicens.*/d' "${add}"/availUpd.txt
			upd="${E_BG}${NC}$lvtpu"
			unset localver wicensUpate wicensMD5
			witext=$scriptname
		fi
	fi
	[ "$suUpd" = 1 ] && witext='WICENS'
	[ -z "$updcheck" ] && printf "${GN_BG} wi${NC} %-9s%-21s%${COR}s\\n" "open" "$witext  $localver" " $upd"
	case_wi(){
		trap trap_ctrl 2
		trap_ctrl(){
			sleep 2
			exec "$0"
		}
		/jffs/scripts/wicens.sh
		trap - 2
		sleep 2
		show_amtm menu
	}
}
install_wicens(){
	p_e_l
	echo " This installs WICENS - WAN IP Change Email Notification Script"
	echo " on your router."
	echo
	echo " Author: Maverickcdn"
	echo " https://www.snbforums.com/threads/wicens-wan-ip-change-email-notification-script.69294/"
	c_d

	c_url https://raw.githubusercontent.com/maverickcdn/wicens/master/wicens.sh -o /jffs/scripts/wicens.sh && chmod 755 /jffs/scripts/wicens.sh && /jffs/scripts/wicens.sh

	sleep 2
	if [ -f /jffs/scripts/wicens.sh ]; then
		show_amtm " WICENS installed"
	else
		am=;show_amtm " WICENS installation failed"
	fi
}
#eof
