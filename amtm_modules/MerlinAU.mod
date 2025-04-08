#!/bin/sh
#bof
MerlinAU_installed(){
	scriptname=MerlinAU
	scriptgrep=' SCRIPT_VERSION='
	if [ "$su" = 1 ]; then
		remoteurl=https://raw.githubusercontent.com/ExtremeFiretop/MerlinAutoUpdate-Router/main/MerlinAU.sh
		grepcheck=ExtremeFiretop
	fi
	script_check
	if [ -z "$su" -a -z "$tpu" ] && [ "$MerlinAUUpate" ]; then
		localver="$lvtpu"
		upd="${E_BG}$MerlinAUUpate${NC}"
		if [ "$MerlinAUMD5" != "$(md5sum "$scriptloc" | awk '{print $1}')" ]; then
			[ -f "${add}"/availUpd.txt ] && sed -i '/^MerlinAU.*/d' "${add}"/availUpd.txt
			upd="${E_BG}${NC}$lvtpu"
			unset localver MerlinAUUpate MerlinAUMD5
		fi
	fi
	[ -z "$updcheck" -a -z "$ss" ] && printf "${GN_BG} 8 ${NC} %-9s%-21s%${COR}s\\n" "open" "MerlinAU      $localver" " $upd"
	case_8(){
		trap trap_ctrl 2
		trap_ctrl(){
			sleep 2
			exec "$0"
		}
		/jffs/scripts/MerlinAU.sh
		trap - 2
		sleep 2
		show_amtm menu
	}
}
install_MerlinAU(){
	p_e_l
	printf " This installs MerlinAU - The Ultimate\\n Firmware Auto-Updater on your router.\\n\\n"
	printf " Author: ExtremeFiretop\\n snbforums.com/threads/introducing-merlinau-the-ultimate-firmware-auto-updater-addon.88577/\\n"
	printf " Major contributor: Martinski\\n"
	c_d
	clear
	c_url https://raw.githubusercontent.com/ExtremeFiretop/MerlinAutoUpdate-Router/main/MerlinAU.sh -o /jffs/scripts/MerlinAU.sh && chmod 0755 /jffs/scripts/MerlinAU.sh && /jffs/scripts/MerlinAU.sh install
	sleep 2
	if [ -f /jffs/scripts/MerlinAU.sh ]; then
		show_amtm " MerlinAU installed"
	else
		am=;show_amtm " MerlinAU installation failed"
	fi
}
#eof
