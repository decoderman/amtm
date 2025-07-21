#!/bin/sh
#bof
dnscrypt_sh(){
	local dnscrypt_script tmpfile
	tmpfile="/tmp/home/root/installer"
	dnscrypt_script="$(c_url https://raw.githubusercontent.com/thuantran/dnscrypt-asuswrt-installer/master/installer)" || return 1
	[ -n "$dnscrypt_script" ] || return 1

	printf "%s\n" "$dnscrypt_script" > "$tmpfile"
	chmod 0755 "$tmpfile"
	$tmpfile
	[ -f "$tmpfile" ] && rm -rf "$tmpfile"
	return 0
}
dnscrypt_installed(){
	if [ "$su" = 1 ]; then
		localDPver="$(/jffs/dnscrypt/dnscrypt-proxy -version)"
		remoteDPver=$(c_url -H 'Accept: application/json' https://github.com/DNSCrypt/dnscrypt-proxy/releases/latest | sed -e 's/.*"tag_name":"\([^"]*\)".*/\1/')
		updDP="${E_BG}${NC}$localDPver"
		ditext="dnscrypt inst"
		dptext="dnscrypt-prox"
		updDP="${GN_BG}$localDPver${NC}"
		if [ "$localDPver" ] && [ "$remoteDPver" ]; then
			if [ "$localDPver" != "$remoteDPver" ]; then
				updDP="${E_BG}-> $remoteDPver${NC}"
				updtpuDP="-> $remoteDPver"
				[ "$tpu" ] && echo "- dnscrypt installer, dnscrypt-proxy $localDPver -> $remoteDPver <br>" >>/tmp/amtm-tpu-check
				suUpd=1
				localDPver=$localDPver
				echo "dnscrypt_installerPxUpate=\"$updtpuDP\"">>"${add}"/availUpd.txt
				echo "dnscrypt_installerPxVer=\"$localDPver\"">>"${add}"/availUpd.txt
			else
				localDPver=
			fi
		else
			updDP=" ${E_BG}upd err${NC}"
		fi
	else
		ditext="dnscrypt installer"
	fi

	scriptname='dnscrypt installer'
	scriptgrep='^DI_VERSION='
	if [ "$su" = 1 ]; then
		remoteurl="https://raw.githubusercontent.com/thuantran/dnscrypt-asuswrt-installer/master/installer"
		grepcheck=WARNING
	fi
	script_check
	[ "$su" = 1 ] && [ -z "$localver" ] && ditext="dnscrypt installer"
	if [ -z "$su" -a -z "$tpu" ] && [ "$dnscrypt_installerUpate" -o "$dnscrypt_installerPxUpate" ]; then
		dptext="dnscrypt-prox"
		if [ "$dnscrypt_installerUpate" ]; then
			ditext="dnscrypt inst"
			localver="$lvtpu"
			upd="${E_BG}$dnscrypt_installerUpate${NC}"
			if [ "$dnscrypt_installerMD5" != "$(md5sum "$scriptloc" | awk '{print $1}')" ]; then
				if [ -f "${add}"/availUpd.txt ]; then
					sed -i '/^dnscrypt_installerU.*/d' "${add}"/availUpd.txt
					sed -i '/^dnscrypt_installerM.*/d' "${add}"/availUpd.txt
				fi
				unset localver dnscrypt_installerUpate dnscrypt_installerMD5
				upd="${E_BG}${NC}$lvtpu"
				ditext="dnscrypt installer"
			fi
		fi
		if [ "$dnscrypt_installerPxUpate" ]; then
			localDPver="$(/jffs/dnscrypt/dnscrypt-proxy -version)"
			updDP="${E_BG}$dnscrypt_installerPxUpate${NC}"
			if [ "$dnscrypt_installerPxVer" != "$localDPver" ]; then
				[ -f "${add}"/availUpd.txt ] && sed -i '/^dnscrypt_installerP.*/d' "${add}"/availUpd.txt
				unset dnscrypt_installerPxUpate dnscrypt_installerPxVer
			fi
		fi
	fi
	[ -z "$updcheck" -a -z "$ss" ] && printf "${GN_BG} di${NC} %-9s%-21s%${COR}s\\n" "open" "$ditext $localver" " $upd"
	[ "$su" = 1 -a -z "$updcheck" ] || [ "$dnscrypt_installerPxUpate" ] && printf "${GN_BG}   ${NC} %-9s%-21s%${COR}s\\n" "" "$dptext $localDPver" " $updDP"
	case_di(){
		p_e_l
		if ! dnscrypt_sh && [ -s "/jffs/dnscrypt/installer" ]; then
			if [ ! -x "/jffs/dnscrypt/installer" ]; then chmod 0755 /jffs/dnscrypt/installer; fi
			/jffs/dnscrypt/installer
		fi
		sleep 5
		show_amtm menu
	}
}
install_dnscrypt(){
	if [ -f /opt/etc/AdGuardHome/installer ]; then
		am=;show_amtm " ! dnscrypt installer is not available to install.\\n AdGuardHome is installed which is incompatible\\n with dnscrypt installer."
	fi
	if [ "$(uname -m)" = mips ]; then
		am=;show_amtm " dnscrypt install not possible,\\n MIPS routers are not supported"
	fi
	if [ -f /jffs/scripts/install_stubby.sh ] && [ -f /opt/etc/stubby/stubby.yml ]; then
		am=;show_amtm " dnscrypt install not possible,\\n it is not compatible with Stubby DNS\\n which is installed on this router."
	fi
	if [ "$(nvram get dnspriv_enable)" = 1 ]; then
		am=;show_amtm " dnscrypt install not possible,\\n DNS-over-TLS (DoT) is enabled in the router\\n WebUI."
	fi
	p_e_l
	printf " This installs dnscrypt installer\\n on your router.\\n\\n"
	printf " Authors: bigeyes0x0, SomeWhereOverTheRainBow\\n snbforums.com/forums/asuswrt-merlin-addons.60/?prefix_id=29&starter_id=64179\\n"
	c_d
	mkdir -p /jffs/dnscrypt
	dnscrypt_sh
	sleep 2
	if [ -f /jffs/dnscrypt/manager ]; then
		show_amtm " dnscrypt installer installed"
	else
		{ rm -rf /jffs/dnscrypt; } 2>/dev/null
		am=;show_amtm " dnscrypt installer installation failed"
	fi
}
#eof
