#!/bin/sh
#bof
dnscrypt_installed(){
	if [ "$su" = 1 ]; then
		localDPver="$(/jffs/dnscrypt/dnscrypt-proxy -version)"
		remoteDPver=$(c_url -H 'Accept: application/json' https://github.com/DNSCrypt/dnscrypt-proxy/releases/latest | sed -e 's/.*"tag_name":"\([^"]*\)".*/\1/')
		updDP="${E_BG}${NC}v$localDPver"
		ditext="dnscrypt inst"
		dptext="dnscrypt-prox"
		updDP="${GN_BG}v$localDPver${NC}"
		if [ "$localDPver" ] && [ "$remoteDPver" ]; then
			if [ "$localDPver" != "$remoteDPver" ]; then
				updDP="${E_BG}-> v$remoteDPver${NC}"
				updtpuDP="-> v$remoteDPver"
				[ "$tpu" ] && echo "- dnscrypt installer, dnscrypt-proxy v$localDPver -> v$remoteDPver <br>" >>/tmp/amtm-tpu-check
				suUpd=1
				localDPver=v$localDPver
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
				sed -i '/^dnscrypt_installerU.*/d' "${add}"/availUpd.txt
				sed -i '/^dnscrypt_installerM.*/d' "${add}"/availUpd.txt
				unset localver dnscrypt_installerUpate dnscrypt_installerMD5
				upd="${E_BG}${NC}$lvtpu"
				ditext="dnscrypt installer"
			fi
		fi
		if [ "$dnscrypt_installerPxUpate" ]; then
			localDPver="v$(/jffs/dnscrypt/dnscrypt-proxy -version)"
			updDP="${E_BG}$dnscrypt_installerPxUpate${NC}"
			if [ "$dnscrypt_installerPxVer" != "$localDPver" ]; then
				sed -i '/^dnscrypt_installerP.*/d' "${add}"/availUpd.txt
				unset dnscrypt_installerPxUpate dnscrypt_installerPxVer
			fi
		fi
	fi
	printf "${GN_BG} di${NC} %-9s%-21s%${COR}s\\n" "open" "$ditext $localver" " $upd"
	[ "$su" = 1 ] || [ "$dnscrypt_installerPxUpate" ] && printf "${GN_BG}   ${NC} %-9s%-21s%${COR}s\\n" "" "$dptext $localDPver" " $updDP"
	case_di(){
		p_e_l
		/jffs/dnscrypt/installer
		sleep 5
		show_amtm menu
	}
}
install_dnscrypt(){
	p_e_l
	echo " This installs dnscrypt installer"
	echo " on your router."
	echo
	echo " Authors: bigeyes0x0, SomeWhereOverTheRainBow"
	echo " https://www.snbforums.com/threads/36071"

	c_d

	if [ "$(uname -m)" = mips ]; then
		am=;show_amtm " dnscrypt install failed,\\n MIPS routers are not supported"
	fi

	if [ -f "/jffs/scripts/install_stubby.sh" ] && [ -f "/opt/etc/stubby/stubby.yml" ]; then
		am=;show_amtm " dnscrypt install failed.\\n It is not compatible with Stubby DNS\\n which is installed on this router."
	fi

	if [ "$(nvram get dnspriv_enable)" = 1 ]; then
		am=;show_amtm " dnscrypt install failed.\\n DNS-over-TLS (DoT) is enabled in the router\\n WebUI."
	fi

	mkdir -p /jffs/dnscrypt
	c_url "https://raw.githubusercontent.com/thuantran/dnscrypt-asuswrt-installer/master/installer" -o "/jffs/dnscrypt/installer" && chmod 0755 /jffs/dnscrypt/installer
	/jffs/dnscrypt/installer

	sleep 5
	if [ -f /jffs/dnscrypt/manager ]; then
		show_amtm " dnscrypt installer installed"
	else
		rm -rf /jffs/dnscrypt
		am=;show_amtm " dnscrypt installer installation failed"
	fi
}
#eof
