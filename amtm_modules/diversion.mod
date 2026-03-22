#!/bin/sh
#bof
diversion_installed(){
	scriptname=Diversion
	localVother="$(grep ^VERSION "$scriptloc" | sed -e 's/VERSION=//')"

	if [ "$su" = 1 ]; then
		case "$amtmBranch" in
			LOCAL) 	remoteurl="http://diversion.test/diversion_adblocking/diversion";;
			*) 		remoteurl="https://diversion.ch/diversion_adblocking/diversion";;
		esac
		remoteVother="$(c_url "$remoteurl" | grep ^VERSION | sed -e 's/VERSION=//')"
		grepcheck=thelonelycoder
	fi
	script_check
	if [ -z "$su" -a -z "$tpu" ] && [ "$DiversionUpate" ]; then
		localver="$lvtpu"
		upd="${E_BG}$DiversionUpate${NC}"
		if [ "$DiversionMD5" != "$(md5sum "$scriptloc" | awk '{print $1}')" ]; then
			[ -f "${add}"/availUpd.txt ] && sed -i '/^Diversion.*/d' "${add}"/availUpd.txt
			upd="${E_BG}${NC}$lvtpu"
			unset localver DiversionUpate DiversionMD5
		fi
	fi

	[ -z "$updcheck" -a -z "$ss" ] && printf "${GN_BG} 1 ${NC} %-9s%-21s%${COR}s\\n" "open" "Diversion     $localver" " $upd"
	case_1(){
		trap trap_ctrl 2
		trap_ctrl(){
			sleep 2
			exec "$0"
		}
		/opt/bin/diversion
		trap - 2
		sleep 2
		show_amtm menu
	}
}
install_diversion(){
	p_e_l
	printf " This installs Diversion - the Router Adblocker\\n on your router.\\n\\n"
	printf " Author: thelonelycoder\\n snbforums.com/forums/asuswrt-merlin-addons.60/?prefix_id=10&starter_id=25480\\n"
	c_d
	case "$amtmBranch" in
		LOCAL) 	remoteurl="http://diversion.test/install";;
		*) 		remoteurl="https://diversion.ch/install";;
	esac
	c_url -Os "$remoteurl" && sh install
	sleep 2
	if [ -f /opt/bin/diversion ]; then
		show_amtm " Diversion installed"
	else
		am=;show_amtm " Diversion installation failed"
	fi
}
#eof
