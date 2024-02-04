#!/bin/sh
#bof
scmerlin_installed(){
	scriptname=scMerlin
	scriptgrep=' SCRIPT_VERSION=\| SCM_VERSION='
	if [ "$su" = 1 ]; then
		remoteurl=https://jackyaz.io/scMerlin/master/amtm-version/scmerlin.sh
		remoteurlmd5=https://jackyaz.io/scMerlin/master/amtm-md5/scmerlin.sh
		grepcheck=jackyaz
	fi
	script_check
	if [ -z "$su" -a -z "$tpu" ] && [ "$scMerlinUpate" ]; then
		localver="$lvtpu"
		upd="${E_BG}$scMerlinUpate${NC}"
		if [ "$scMerlinMD5" != "$(md5sum "$scriptloc" | awk '{print $1}')" ]; then
			sed -i '/^scMerlin.*/d' "${add}"/availUpd.txt
			upd="${E_BG}${NC}$lvtpu"
			unset localver scMerlinUpate scMerlinMD5
		fi
	fi
	[ -z "$updcheck" -a -z "$ss" ] && printf "${GN_BG} j3${NC} %-9s%-21s%${COR}s\\n" "open" "scMerlin      $localver" " $upd"
	case_j3(){
		trap trap_ctrl 2
		trap_ctrl(){
			sleep 2
			exec "$0"
		}
		/jffs/scripts/scmerlin
		trap - 2
		sleep 2
		show_amtm menu
	}
}
install_scmerlin(){
	p_e_l
	printf " This installs scMerlin - service and script\\n control menu for Asuswrt-Merlin\\n on your router.\\n\\n"
	printf " Author: Jack Yaz\\n snbforums.com/forums/asuswrt-merlin-addons.60/?prefix_id=23&starter_id=53009\\n"
	c_d
	c_url https://jackyaz.io/scMerlin/master/amtm-install/scmerlin.sh -o "/jffs/scripts/scmerlin" && chmod 0755 /jffs/scripts/scmerlin && /jffs/scripts/scmerlin install
	sleep 2
	if [ -f /jffs/scripts/scmerlin ]; then
		show_amtm " scMerlin installed"
	else
		am=;show_amtm " scMerlin installation failed"
	fi
}
#eof
