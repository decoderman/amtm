#!/bin/sh
#bof
uiDivStats_installed(){
	scriptname=uiDivStats
	scriptgrep=' SCRIPT_VERSION='
	if [ "$su" = 1 ]; then
		remoteurl=https://jackyaz.io/uiDivStats/master/amtm-version/uiDivStats.sh
		remoteurlmd5=https://jackyaz.io/uiDivStats/master/amtm-md5/uiDivStats.sh
		grepcheck=jackyaz
	fi
	script_check
	if [ -z "$su" -a -z "$tpu" ] && [ "$uiDivStatsUpate" ]; then
		localver="$lvtpu"
		upd="${E_BG}$uiDivStatsUpate${NC}"
		if [ "$uiDivStatsMD5" != "$(md5sum "$scriptloc" | awk '{print $1}')" ]; then
			sed -i '/^uiDivStats.*/d' "${add}"/availUpd.txt
			upd="${E_BG}${NC}$lvtpu"
			unset localver uiDivStatsUpate uiDivStatsMD5
		fi
	fi

	if [ -f /opt/bin/diversion ]; then
		divV=$(grep '^VERSION' /opt/bin/diversion | sed 's/VERSION=//')
		if [ "$(v_c $divV)" -ge "$(v_c "5.0")" ]; then
			if [ "$(v_c $lvtpu)" -gt "$(v_c "3.0.2")" ]; then
				[ -z "$updcheck" -a -z "$ss" ] && printf "${GN_BG} j5${NC} %-9s%-21s%${COR}s\\n" "open" "uiDivStats    $localver" " $upd"
				case_j5(){
					/jffs/scripts/uiDivStats
					sleep 2
					show_amtm menu
				}
			elif [ -z "$updcheck" -a -z "$ss" ]; then
				if [ -z "$localver" ]; then
					divStatsV=$upd
					printf "${GN_BG} j5${NC} %-9s%-21s%${COR}s\\n" "show" "uiDivStats, incompatible" ""
					case_j5(){
						am=;show_amtm " The current release of uiDivStats ($divStatsV) is\\n no longer compatible with Diversion $divV.\\n\\n Watch out for an update with ${GN_BG} u ${NC} in amtm,\\n it will show when a new version is available."
					}
				else
					printf "${GN_BG} j5${NC} %-9s%-21s%${COR}s\\n" "open" "uiDivStats    $localver" " $upd"
					case_j5(){
						/jffs/scripts/uiDivStats
						sleep 2
						show_amtm menu
					}
				fi
			fi
		else
			[ -z "$updcheck" -a -z "$ss" ] && printf "${GN_BG} j5${NC} %-9s%-21s%${COR}s\\n" "open" "uiDivStats    $localver" " $upd"
			case_j5(){
				/jffs/scripts/uiDivStats
				sleep 2
				show_amtm menu
			}
		fi
	else
		[ -z "$updcheck" -a -z "$ss" ] && printf "${GN_BG} j5${NC} %-9s%-21s%${COR}s\\n" "open" "uiDivStats    $localver" " $upd"
		case_j5(){
			/jffs/scripts/uiDivStats
			sleep 2
			show_amtm menu
		}
	fi
}
install_uiDivStats(){
	p_e_l
	printf " This installs uiDivStats - WebUI for Diversion\\n statistics on your router.\\n\\n"
	printf " Author: Jack Yaz\\n snbforums.com/forums/asuswrt-merlin-addons.60/?prefix_id=15&starter_id=53009\\n"
	c_d
	installOK(){
		c_url https://jackyaz.io/uiDivStats/master/amtm-install/uiDivStats.sh -o "/jffs/scripts/uiDivStats" && chmod 0755 /jffs/scripts/uiDivStats && /jffs/scripts/uiDivStats install
		sleep 2
	}

	if [ -f /opt/bin/diversion ]; then
		divV=$(grep '^VERSION' /opt/bin/diversion | sed 's/VERSION=//')
		if [ "$(v_c $divV)" -ge "$(v_c "5.0")" ]; then
			remoteurl=https://jackyaz.io/uiDivStats/master/amtm-version/uiDivStats.sh
			divStatsV=$(c_url "$remoteurl" | grep -m1 " SCRIPT_VERSION=" | grep -oE '[0-9]{1,2}([.][0-9]{1,2})([.][0-9]{1,2})')
			if [ "$(v_c $divStatsV)" -gt "$(v_c "3.0.2")" ]; then
				installOK
			else
				am=;show_amtm " The current release of uiDivStats ($divStatsV) is\\n no longer compatible with Diversion $divV.\\n\\n Watch out for a compatibility update of uiDivStats."
			fi
		else
			installOK
		fi
	else
		am=;show_amtm " uiDivStats installation not possible,\\n Diversion is not installed"
	fi
	if [ -f /jffs/scripts/uiDivStats ]; then
		show_amtm " uiDivStats installed"
	else
		am=;show_amtm " uiDivStats installation failed"
	fi
}
#eof
