#!/bin/sh
#bof
uiDivStats_installed(){
	scriptname=uiDivStats
	scriptgrep=' SCRIPT_VERSION='
	if [ "$su" = 1 ]; then
		remoteurl=https://raw.githubusercontent.com/decoderman/uiDivStats/master/uiDivStats.sh
		remoteurlmd5=https://raw.githubusercontent.com/decoderman/uiDivStats/master/uiDivStats.sh
		grepcheck=jackyaz
	fi
	script_check
	if [ -z "$su" -a -z "$tpu" ] && [ "$uiDivStatsUpate" ]; then
		localver="$lvtpu"
		upd="${E_BG}$uiDivStatsUpate${NC}"
		if [ "$uiDivStatsMD5" != "$(md5sum "$scriptloc" | awk '{print $1}')" ]; then
			[ -f "${add}"/availUpd.txt ] && sed -i '/^uiDivStats.*/d' "${add}"/availUpd.txt
			upd="${E_BG}${NC}$lvtpu"
			unset localver uiDivStatsUpate uiDivStatsMD5
		fi
	fi

	show_tlc_update(){
		if [ -z "$su" -a -z "$tpu" ] && ! grep -q -m1 'decoderman' /jffs/scripts/uiDivStats; then
			printf "${GN_BG}j5u${NC} %-9s%-21s%${COR}s\\n" "use" "uiDivStats by thelonelycoder" ""
			case_j5u(){
				sed -i '/SCRIPT_REPO=/c\SCRIPT_REPO="https://raw.githubusercontent.com/decoderman/$SCRIPT_NAME/$SCRIPT_BRANCH"' /jffs/scripts/uiDivStats
				sed -i '/^SCRIPT_BRANCH=/c\SCRIPT_BRANCH="master"' /jffs/scripts/uiDivStats
				sed -i '/^readonly SHARED_REPO=/c\readonly SHARED_REPO="https://raw.githubusercontent.com/decoderman/shared-jy/master"' /jffs/scripts/uiDivStats
				if grep -q -m1 'v3.0.2' /jffs/scripts/uiDivStats; then
					sed -i '/^readonly SCRIPT_VERSION=/c\readonly SCRIPT_VERSION="v3.0.3"' /jffs/scripts/uiDivStats
				fi
				show_amtm " Now you can use the update function in\\n uiDivStats to update to the latest version."
			}
		else
			case_j5u(){
				show_amtm " You already set to use the uiDivStats\\n version by thelonelycoder."
			}
		fi
	}

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
					show_tlc_update
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
			show_tlc_update
			case_j5(){
				/jffs/scripts/uiDivStats
				sleep 2
				show_amtm menu
			}
		fi
	else
		[ -z "$updcheck" -a -z "$ss" ] && printf "${GN_BG} j5${NC} %-9s%-21s%${COR}s\\n" "open" "uiDivStats    $localver" " $upd"
		show_tlc_update
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
	printf " With contributions from: 314eter, thelonelycoder\\n\\n This script is hosted by thelonelycoder\\n"
	printf " aka decoderman at https://github.com/decoderman/uiDivStats\\n"
	c_d

	if [ -f /opt/bin/diversion ]; then
		divV=$(grep '^VERSION' /opt/bin/diversion | sed 's/VERSION=//')
		if [ "$(v_c $divV)" -ge "$(v_c "5.0")" ]; then
			c_url https://raw.githubusercontent.com/decoderman/uiDivStats/master/uiDivStats.sh -o "/jffs/scripts/uiDivStats" && chmod 0755 /jffs/scripts/uiDivStats && /jffs/scripts/uiDivStats install
			sleep 2
		else
			am=;show_amtm " The current release of uiDivStats is\\n no longer compatible with Diversion $divV.\\n\\n Please update Diversion first."
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
