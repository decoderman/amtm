#!/bin/sh
#bof
AutoSSH_Key_installed(){
	scriptgrep='^SCRIPT_VERSION='
	if [ "$su" = 1 ]; then
		remoteurl=https://raw.githubusercontent.com/JB1366/AutoSSHKey/main/autosshkey.sh
		grepcheck=JB_1366
	fi
	script_check
	if [ -z "$su" -a -z "$tpu" ] && [ "$AutoSSH_KeyUpdate" ]; then
		localver="$lvtpu"
		upd="${E_BG}$AutoSSH_KeyUpdate${NC}"
		if [ "$AutoSSH_KeyMD5" != "$(md5sum "$scriptloc" | awk '{print $1}')" ]; then
			[ -f "${add}"/availUpd.txt ] && sed -i '/^AutoSSH_Key.*/d' "${add}"/availUpd.txt
			upd="${E_BG}${NC}$lvtpu"
			unset localver AutoSSH_KeyUpdate AutoSSH_KeyMD5
		fi
	fi
	[ -z "$updcheck" -a -z "$ss" ] && printf "${GN_BG} as${NC} %-9s%-21s%${COR}s\\n" "open" "Auto SSH-Key  $localver" " $upd"
	case_as(){
		/jffs/addons/AutoSSHKey/autosshkey.sh
		sleep 2
		show_amtm menu
	}
}
install_AutoSSH_Key(){
	p_e_l
	printf " This installs Auto SSH-Key - SSH Keygen for AiMesh devices\\n on your router.\\n\\n"
	printf " Author: JB_1366\\n snbforums.com/threads/97834/\\n"
	c_d
	c_url https://raw.githubusercontent.com/JB1366/AutoSSHKey/main/autosshkey.sh -o /tmp/autosshkey.sh && sh /tmp/autosshkey.sh install
	sleep 2
	if [ -f /jffs/addons/AutoSSHKey/autosshkey.sh ]; then
		show_amtm " Auto SSH-Key installed"
	else
		am=;show_amtm " Auto SSH-Key installation failed"
	fi
}
#eof
