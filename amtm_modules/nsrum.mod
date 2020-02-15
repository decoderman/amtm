#!/bin/sh
#bof
nsrum_installed(){
	scriptname='NVRAM Save/Restore Utility'
	localVother="v$(grep "^VERSION=" "$scriptloc" | sed -e 's/VERSION=//;s/"//g')"
	if [ "$su" = 1 ]; then
		remoteurl="https://raw.githubusercontent.com/Xentrk/nvram-save-restore-utility/master/nsrum"
		remoteVother="v$(c_url "$remoteurl" | grep "^VERSION=" | sed -e 's/VERSION=//;s/"//g')"
		grepcheck=Xentrk
	fi
	script_check
	printf "${GN_BG} 8 ${NC} %-9s%-21s%${COR}s\\n" "open" "nsrum         $localver" " $upd"
	case_8(){
		/jffs/scripts/nsrum
		sleep 2
		show_amtm menu
	}
}
install_nsrum(){
	p_e_l
	echo " This installs nsrum - NVRAM Save/Restore Utility"
	echo " on your router."
	echo
	echo " Author: Xentrk"
	echo " https://www.snbforums.com/threads/release-nvram-save-restore-utility.61722/"
	c_d

	c_url "https://raw.githubusercontent.com/Xentrk/nvram-save-restore-utility/master/nsrum" -o "/jffs/scripts/nsrum" && sleep 5 && chmod 755 /jffs/scripts/nsrum && sh /jffs/scripts/nsrum
	sleep 2
	if [ -f /jffs/scripts/nsrum ]; then
		show_amtm " nsrum NVRAM Save/Restore Utility installed"
	else
		am=;show_amtm " nsrum NVRAM Save/Restore Utility installation failed"
	fi
}
#eof
