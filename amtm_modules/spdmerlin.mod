#!/bin/sh
#bof
spdMerlin_installed(){
	[ -f "${add}"/spdmerlin.mod ] && rm -rf "${add}"/spdmerlin.mod
	scriptgrep=' SCRIPT_VERSION='
	if [ "$su" = 1 ]; then
		remoteurl=https://raw.githubusercontent.com/AMTM-OSR/spdMerlin/master/spdmerlin.sh
		grepcheck=jackyaz
	fi
	script_check
	if [ -z "$su" -a -z "$tpu" ] && [ "$spdMerlinUpdate" ]; then
		localver="$lvtpu"
		upd="${E_BG}$spdMerlinUpdate${NC}"
		if [ "$spdMerlinMD5" != "$(md5sum "$scriptloc" | awk '{print $1}')" ]; then
			[ -f "${add}"/availUpd.txt ] && sed -i '/^spdMerlin.*/d' "${add}"/availUpd.txt
			upd="${E_BG}${NC}$lvtpu"
			unset localver spdMerlinUpdate spdMerlinMD5
		fi
	fi
	[ -z "$updcheck" -a -z "$ss" ] && printf "${GN_BG} j4${NC} %-9s%-21s%${COR}s\\n" "open" "spdMerlin     $localver" " $upd"
	case_j4(){
		/jffs/scripts/spdmerlin
		sleep 2
		show_amtm menu
	}
}
install_spdMerlin(){
	p_e_l
	printf " This installs spdMerlin - Automatic speedtest\\n for Asuswrt-Merlin - with graphs\\n on your router.\\n\\n"
	printf " Original Author: Jack Yaz\\n snbforums.com/forums/asuswrt-merlin-addons.60/?prefix_id=19&starter_id=53009\\n\\n"
	printf " This script is now maintained by the AMTM-OSR team,\\n the AMTM Orphaned Script Revival repository.\\n"
	printf " Visit and learn more about their mission here:\\n https://github.com/AMTM-OSR\\n"
	c_d
	c_url https://raw.githubusercontent.com/AMTM-OSR/spdMerlin/master/spdmerlin.sh -o "/jffs/scripts/spdmerlin" && chmod 0755 /jffs/scripts/spdmerlin && /jffs/scripts/spdmerlin install
	sleep 2
	if [ -f /jffs/scripts/spdmerlin ]; then
		show_amtm " spdMerlin installed"
	else
		am=;show_amtm " spdMerlin installation failed"
	fi
}
#eof
