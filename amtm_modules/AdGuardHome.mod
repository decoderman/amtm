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
	[ -f "$tmpfile" ] && rm -rf "$tmpfile"
	return 0
}
AdGuardHome_installed(){
	scriptgrep='^AI_VERSION'
	[ -f /opt/etc/AdGuardHome/.config ] && . /opt/etc/AdGuardHome/.config
	if [ "$su" = 1 ]; then
		remoteurl=https://raw.githubusercontent.com/jumpsmm7/Asuswrt-Merlin-AdGuardHome-Installer/master/installer
		# Change from using github api to using AdGuard Metadata directly.
		latestverurl=https://static.adguard.com/adguardhome
		grepcheck=SomeWhereOverTheRainBow
		case "${ADGUARD_BRANCH}" in
			release)
				_AGHchannel=stable
				AGHext="AGH Stable bin"
				;;
			beta)
				_AGHchannel=beta
				AGHext="AGH Beta bin"
				;;
			edge)
				_AGHchannel=edge
				AGHext="AGH Edge bin"
				;;
		esac
		if [ "${_AGHchannel}" ]; then
			localAGHver="$(/opt/etc/AdGuardHome/AdGuardHome --version | cut -d" "  -f4-)"
			remoteAGHver="$(c_url "${latestverurl}/${_AGHchannel}/version.txt" | awk 'NF {VERSION = $1; sub(/^version=/, "", VERSION); print VERSION; exit}')"
			# Add fallback to local metadata cache for version checks
			[ -z "${remoteAGHver}" ] && remoteAGHver="$(c_url "https://raw.githubusercontent.com/jumpsmm7/Asuswrt-Merlin-AdGuardHome-Installer/refs/heads/master/armv8/checksum.txt" | awk -v VAR="${_AGHchannel}" '$1 !~ /^#/ && $2 == VAR {VERSION = $3; sub(/^version=/, "", VERSION); print VERSION; exit}')"
			updAGH="${GN_BG}$localAGHver${NC}"
		fi
		if [ "$localAGHver" ] && [ "$remoteAGHver" ]; then
			if [ "$localAGHver" != "$remoteAGHver" ]; then
				forceScriptUpdate="binary $localAGHver -> $remoteAGHver"
				updAGH="${E_BG}-> $remoteAGHver${NC}"
				[ "$tpu" ] && echo "- $scriptname binary $localAGHver -> $remoteAGHver <br>" >>/tmp/amtm-tpu-check
				suUpd=1
				AGHext="AGH bin"
				echo "AGHbinUpdate=\"-> $remoteAGHver\"">>"${add}"/availUpd.txt
				echo "AGHbinVer=\"$localAGHver\"">>"${add}"/availUpd.txt
			else
				localAGHver=
			fi
		else
			updAGH=" ${E_BG}upd err${NC}"
		fi
	fi
	script_check
	if [ -z "$su" -a -z "$tpu" ] && [ "$AdGuardHomeUpdate" -o "$AGHbinUpdate" ]; then
		localver="$lvtpu"
		upd="${E_BG}$AdGuardHomeUpdate${NC}"
		if [ "$AdGuardHomeMD5" != "$(md5sum "$scriptloc" | awk '{print $1}')" ]; then
			[ -f "${add}"/availUpd.txt ] && sed -i '/^AdGuardHome.*/d' "${add}"/availUpd.txt
			upd="${E_BG}${NC}$lvtpu"
			unset localver AdGuardHomeUpdate AdGuardHomeMD5
		fi
		if [ "$AGHbinUpdate" ]; then
			localAGHver="$(/opt/etc/AdGuardHome/AdGuardHome --version | cut -d" "  -f4-)"
			if [ "$AGHbinVer" != "$localAGHver" ]; then
				[ -f "${add}"/availUpd.txt ] && sed -i '/^AGHbin.*/d' "${add}"/availUpd.txt
				unset AGHbinUpdate AGHbinVer
			else
				AGHext="AGH bin"
				updAGH="${E_BG}$AGHbinUpdate${NC}"
			fi
		fi
	fi
	[ -z "$updcheck" -a -z "$ss" ] && printf "${GN_BG} ag${NC} %-9s%-21s%${COR}s\\n" "open" "AdGuardHome    $localver" " $upd"
	[ "$su" = 1 -a -z "$updcheck" ] || [ "$AGHbinUpdate" ] && printf "${GN_BG}   ${NC} %-9s%-21s%${COR}s\\n" "" "$AGHext $localAGHver" " $updAGH"
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
