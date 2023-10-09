#!/bin/sh
#bof
backupmon_installed(){
	scriptname=backupmon
	localVother="$(grep ^Version "$scriptloc" | awk '{print $1}' | sed -e 's/Version=//;s/"//g')"
	if [ "$su" = 1 ]; then
		remoteurl=https://raw.githubusercontent.com/ViktorJp/BACKUPMON/main/backupmon.sh
		remoteVother="$(c_url "$remoteurl" | grep ^Version | awk '{print $1}' | sed -e 's/Version=//;s/"//g')"
		grepcheck=ViktorJp
	fi
	script_check
	if [ -z "$su" -a -z "$tpu" ] && [ "$backupmonUpate" ]; then
		localver="$lvtpu"
		upd="${E_BG}$backupmonUpate${NC}"
		if [ "$backupmonMD5" != "$(md5sum "$scriptloc" | awk '{print $1}')" ]; then
			sed -i '/^backupmon.*/d' "${add}"/availUpd.txt
			upd="${E_BG}${NC}$lvtpu"
			unset localver backupmonUpate backupmonMD5
		fi
	fi
	[ -z "$updcheck" ] && printf "${GN_BG} bm${NC} %-9s%-21s%${COR}s\\n" "open" "BACKUPMON      $localver" " $upd"
	case_bm(){
		trap trap_ctrl 2
		trap_ctrl(){
			sleep 2
			echo "${NC}"
			exec "$0"
		}
		/jffs/scripts/backupmon.sh -setup
		trap - 2
		sleep 2
		show_amtm menu
	}
}
install_backupmon(){
	p_e_l
	echo " This installs BACKUPMON - Backup/Restore your Routers JFFS, NVRAM and External USB Drive"
	echo " on your router."
	echo
	echo " Author: Viktor Jaep"
	echo " https://www.snbforums.com/threads/release-backupmon-v1-18-sep-20-2023-backup-restore-your-router-jffs-nvram-external-usb-drive.86645/"
	c_d

	c_url https://raw.githubusercontent.com/ViktorJp/BACKUPMON/main/backupmon.sh -o /jffs/scripts/backupmon.sh && chmod 755 /jffs/scripts/backupmon.sh && /jffs/scripts/backupmon.sh -setup
	sleep 2
	if [ -f /jffs/scripts/backupmon.sh ]; then
		show_amtm " BACKUPMON installed"
	else
		am=;show_amtm " BACKUPMON installation failed"
	fi
}
#eof
