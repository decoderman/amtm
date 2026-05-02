#!/bin/sh
#bof
Knock_installed(){
	localVother="$(grep ^version= "$scriptloc" | sed -e 's/version=//')"
	nonamtm=
	if [ -z "$localVother" ]; then
		localVother="$(grep ^REV= "$scriptloc" | sed -e 's/REV=//;s/"//g')"
		nonamtm=1
	fi
	if [ "$su" = 1 ]; then
		remoteurl=https://raw.githubusercontent.com/Rung-Asus/Knock/main/knock.sh
		remoteVother="$(c_url "$remoteurl" | grep ^version= | sed -e 's/version=//')"
		[ -z "$remoteVother" ] && remoteVother="$(c_url "$remoteurl" | grep ^REV= | sed -e 's/REV=//;s/"//g')"
		grepcheck=Rung
	fi
	script_check
	if [ -z "$su" -a -z "$tpu" ] && [ "$KnockUpdate" ]; then
		localver="$lvtpu"
		upd="${E_BG}$KnockUpdate${NC}"
		if [ "$KnockMD5" != "$(md5sum "$scriptloc" | awk '{print $1}')" ]; then
			[ -f "${add}"/availUpd.txt ] && sed -i '/^Knock.*/d' "${add}"/availUpd.txt
			upd="${E_BG}${NC}$lvtpu"
			unset localver KnockUpdate KnockMD5
		fi
	fi
	[ -z "$updcheck" -a -z "$ss" ] && printf "${GN_BG} kn${NC} %-9s%-21s%${COR}s\\n" "open" "Knock      $localver" " $upd"
	case_kn(){
		trap trap_ctrl 2
		trap_ctrl(){
			sleep 2
			echo "${NC}"
			exec "$0"
		}
		if [ -z "$nonamtm" ]; then
			/jffs/scripts/knock.sh
		else
			p_e_l
			printf " Your Knock version v$localver is not compatible\\n with amtm.\\n\\n"
			printf " Do you want to update Knock to the latest\\n amtm compatible version now?\\n"
			c_d
			c_url https://raw.githubusercontent.com/Rung-Asus/Knock/main/knock.sh -o /jffs/scripts/knock.sh && chmod 755 /jffs/scripts/knock.sh && sh /jffs/scripts/knock.sh -install
		fi
		trap - 2
		sleep 2
		show_amtm menu
	}
}
install_Knock(){
	p_e_l
	printf " This installs Knock - Router Commands for non-admin users\\n on your router.\\n\\n"
	printf " Author: rung\\n snbforums.com/threads/knock-v1-4-updated-23apr2026-router-commands-for-non-admin-users.96390/\\n"
	c_d
	c_url https://raw.githubusercontent.com/Rung-Asus/Knock/main/knock.sh -o /jffs/scripts/knock.sh && chmod 755 /jffs/scripts/knock.sh && sh /jffs/scripts/knock.sh -install
	sleep 2
	if [ -f /jffs/scripts/knock.sh ]; then
		show_amtm " Knock installed"
	else
		am=;show_amtm " Knock installation failed"
	fi
}
#eof
