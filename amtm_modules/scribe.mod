#!/bin/sh
#bof
scribe_installed(){
	scriptname=scribe
	scriptgrep='^scribe_ver=\| scribe_ver='
	if [ "$su" = 1 ]; then
		remoteurl=https://raw.githubusercontent.com/AMTM-OSR/scribe/master/scribe.sh
		grepcheck=cmkelley
	fi
	script_check
	if [ -z "$su" -a -z "$tpu" ]; then
		if [ "$scribeUpate" ]; then
			localver="$lvtpu"
			upd="${E_BG}$scribeUpate${NC}"
			if [ "$scribeMD5" != "$(md5sum "$scriptloc" | awk '{print $1}')" ]; then
				[ -f "${add}"/availUpd.txt ] && sed -i '/^scribe.*/d' "${add}"/availUpd.txt
				upd="${E_BG}${NC}$lvtpu"
				unset localver scribeUpate scribeMD5
			fi
		fi
		if ! grep -q -m1 'AMTM-OSR' "$scriptloc"; then
			sed -i '/^scribe_branch/c\scribe_branch="master"' "$scriptloc"
			sed -i '/readonly script_repo=/c\readonly script_repo="$raw_git/$script_author/$script_name/$script_branch/${script_name}.sh"' "$scriptloc"
			sed -i 's|"cynicastic"|"AMTM-OSR"|' "$scriptloc"
			sed -i 's|"$unzip_dir/$script_name"|"$unzip_dir/${script_name}.sh"|' "$scriptloc"
			printf "\\n   ${R_BG} $scriptname modified to use AMTM-OSR repository ${NC}\\n    Update now using the $scriptname function.\\n"
		fi
	fi
	[ -z "$updcheck" -a -z "$ss" ] && printf "${GN_BG} 5 ${NC} %-9s%-21s%${COR}s\\n" "open" "scribe        $localver" " $upd"
	case_5(){
		/jffs/scripts/scribe
		sleep 2
		show_amtm menu
	}
}
install_scribe(){
	p_e_l
	printf " This installs scribe - syslog-ng and logrotate\\n installer on your router.\\n\\n"
	printf " Original Author: cmkelley\\n snbforums.com/forums/asuswrt-merlin-addons.60/?prefix_id=7\\n\\n"
	printf " This script is now maintained by the AMTM-OSR team,\\n the AMTM Orphaned Script Revival repository.\\n"
	printf " Visit and learn more about their mission here:\\n https://github.com/AMTM-OSR\\n"
	c_d
	c_url https://raw.githubusercontent.com/AMTM-OSR/scribe/master/scribe.sh -o /jffs/scripts/scribe && chmod 0755 /jffs/scripts/scribe && /jffs/scripts/scribe install
	sleep 2
	if [ -f /jffs/scripts/scribe ]; then
		show_amtm " scribe installed"
	else
		am=;show_amtm " scribe installation failed"
	fi
}
#eof
