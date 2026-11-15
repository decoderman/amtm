#!/bin/sh
#bof
Arteria_installed(){
	localVother="$(grep ^VERSION= "$scriptloc" | cut -d'"' -f2)"
	if [ "$su" = 1 ]; then
		remoteurl=https://github.com/IfSugar/arteria/releases/latest/download/arteria.sh
		remoteVother="$(c_url "$remoteurl" | grep ^VERSION= | cut -d'"' -f2)"
		grepcheck=IfSugar
	fi
	script_check
	if [ -z "$su" -a -z "$tpu" ] && [ "$ArteriaUpdate" ]; then
		localver="$lvtpu"
		upd="${E_BG}$ArteriaUpdate${NC}"
		if [ "$ArteriaMD5" != "$(md5sum "$scriptloc" | awk '{print $1}')" ]; then
			[ -f "${add}"/availUpd.txt ] && sed -i '/^Arteria.*/d' "${add}"/availUpd.txt
			upd="${E_BG}${NC}$lvtpu"
			unset localver ArteriaUpdate ArteriaMD5
		fi
	fi
	[ -z "$updcheck" -a -z "$ss" ] && printf "${GN_BG} ar${NC} %-9s%-21s%${COR}s\\n" "open" "Arteria       $localver" " $upd"
	case_ar(){
		/jffs/addons/arteria/arteria.sh
		sleep 2
		show_amtm menu
	}
}
install_Arteria(){
	p_e_l
	printf " This installs Arteria - A live, animated map\\n of your network’s traffic (AiMesh aware)\\n on your router.\\n\\n"
	printf " Author: Scoty\\n snbforums.com/threads/98274/\\n"
	c_d
	c_url https://github.com/IfSugar/arteria/releases/latest/download/arteria.sh -o /tmp/arteria.sh && sh /tmp/arteria.sh install
	p_e_t "return to amtm"
	sleep 2
	if [ -f /jffs/addons/arteria/arteria.sh ]; then
		show_amtm " Arteria installed"
	else
		am=;show_amtm " Arteria installation failed"
	fi
}
#eof
