#!/bin/sh
#bof
AdGuardHome_sh(){
	local AGH_script tmpfile
	tmpfile="/tmp/home/root/installer"
	AGH_script="$(c_url https://raw.githubusercontent.com/jumpsmm7/Asuswrt-Merlin-AdGuardHome-Installer/master/installer)" || return 1
	[ -n "$AGH_script" ] || return 1

	printf "%s\n" "$AGH_script" > "$tmpfile"
	chmod 0755 "$tmpfile"
	$tmpfile
	[ -f "$AGH_script" ] && rm -rf "$tmpfile"
	return 0
}
AdGuardHome_installed(){
	scriptname=AdGuardHome
	scriptgrep='^AI_VERSION'
	[ -f /opt/etc/AdGuardHome/.config ] && . /opt/etc/AdGuardHome/.config
	if [ "$su" = 1 ]; then
		remoteurl=https://raw.githubusercontent.com/jumpsmm7/Asuswrt-Merlin-AdGuardHome-Installer/master/installer
		latestverurl=https://api.github.com/repos/AdguardTeam/AdGuardHome/releases/latest
		grepcheck=SomeWhereOverTheRainBow
		if [ "$ADGUARD_BRANCH" -a "$ADGUARD_BRANCH" = release ]; then
			localAGHver="$(/opt/etc/AdGuardHome/AdGuardHome --version | cut -d" "  -f4-)"
			remoteAGHver="$(c_url "${latestverurl}?per_page=3" | awk '/"tag_name":/ {t=$2} /"prerelease": false/ {gsub(/[",]/,"",t); print t; exit}')"
			AGHext="AGH binary"
			updAGH="${GN_BG}$localAGHver${NC}"
		elif [ "$ADGUARD_BRANCH" -a "$ADGUARD_BRANCH" = beta ]; then
			localAGHver="$(/opt/etc/AdGuardHome/AdGuardHome --version | cut -d" "  -f4-)"
			remoteAGHver="$(c_url "${latestverurl}?per_page=3" | awk '/"tag_name":/ {t=$2} /"prerelease": true/ {gsub(/[",]/,"",t); print t; exit}')"
			AGHext="AGH Beta bin"
			updAGH="${GN_BG}$localAGHver${NC}"
		fi
		if [ "$localAGHver" ] && [ "$remoteAGHver" ]; then
			if [ "$localAGHver" != "$remoteAGHver" ]; then
				updAGH="${E_BG}-> $remoteAGHver${NC}"
				[ "$tpu" ] && echo "- $scriptname binary $localAGHver -> $remoteAGHver <br>" >>/tmp/amtm-tpu-check
				suUpd=1
				AGHext="AGH bin"
				echo "AGHbinUpate=\"-> $remoteAGHver\"">>"${add}"/availUpd.txt
				echo "AGHbinVer=\"$localAGHver\"">>"${add}"/availUpd.txt
			else
				localAGHver=
			fi
		elif [ "$ADGUARD_BRANCH" -a "$ADGUARD_BRANCH" = edge ]; then
			localAGHver=Edge
			updAGH=
			AGHext="AGH binary branch:"
		else
			updAGH=" ${E_BG}upd err${NC}"
		fi
	fi
	script_check
	if [ "$ADGUARD_BRANCH" -a "$ADGUARD_BRANCH" = edge ]; then
		[ -f "${add}/availUpd.txt" ] && sed -i '/^AGHbin.*/d' "${add}"/availUpd.txt
		unset AGHbinUpate AGHbinVer updAGH
		localAGHver=Edge
		AGHext="AGH binary branch:"
	fi
	if [ -z "$su" -a -z "$tpu" ] && [ "$AdGuardHomeUpate" -o "$AGHbinUpate" ]; then
		localver="$lvtpu"
		upd="${E_BG}$AdGuardHomeUpate${NC}"
		if [ "$AdGuardHomeMD5" != "$(md5sum "$scriptloc" | awk '{print $1}')" ]; then
			[ -f "${add}"/availUpd.txt ] && sed -i '/^AdGuardHome.*/d' "${add}"/availUpd.txt
			upd="${E_BG}${NC}$lvtpu"
			unset localver AdGuardHomeUpate AdGuardHomeMD5
		fi
		if [ "$AGHbinUpate" ]; then
			localAGHver="$(/opt/etc/AdGuardHome/AdGuardHome --version | cut -d" "  -f4-)"
			if [ "$AGHbinVer" != "$localAGHver" ]; then
				[ -f "${add}"/availUpd.txt ] && sed -i '/^AGHbin.*/d' "${add}"/availUpd.txt
				unset AGHbinUpate AGHbinVer
			else
				AGHext="AGH bin"
				updAGH="${E_BG}$AGHbinUpate${NC}"
			fi
		fi
	fi
	[ -z "$updcheck" -a -z "$ss" ] && printf "${GN_BG} ag${NC} %-9s%-21s%${COR}s\\n" "open" "AdGuardHome    $localver" " $upd"
	[ "$su" = 1 -a -z "$updcheck" ] || [ "$AGHbinUpate" ] && printf "${GN_BG}   ${NC} %-9s%-21s%${COR}s\\n" "" "$AGHext $localAGHver" " $updAGH"
	case_ag(){
		if ! AdGuardHome_sh && [ -s "/opt/etc/AdGuardHome/installer" ]; then
			if [ ! -x "/opt/etc/AdGuardHome/installer" ]; then chmod 0755 /opt/etc/AdGuardHome/installer; fi
			/opt/etc/AdGuardHome/installer
		fi
		sleep 2
		show_amtm menu
	}
}
install_AdGuardHome(){
	if [ -f /jffs/dnscrypt/manager ]; then
		am=;show_amtm " ! AdGuardHome is not available to install.\\n dnscrypt installer is installed which is incompatible\\n with AdGuardHome."
	fi
	p_e_l
	printf " This installs AdGuardHome - Asuswrt-Merlin-AdGuardHome-Installer\\n on your router.\\n\\n"
	printf " Author: SomeWhereOverTheRainBow\\n snbforums.com/threads/new-release-asuswrt-merlin-adguardhome-installer.76506/#post-733310\\n"
	c_d
	AdGuardHome_sh
	sleep 2
	if [ -f /opt/etc/AdGuardHome/installer ]; then
		show_amtm " AdGuardHome installed"
	else
		am=;show_amtm " AdGuardHome installation failed"
	fi
}
#eof
