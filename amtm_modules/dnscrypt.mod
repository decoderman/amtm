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
				[ "$tpu" ] && echo "- dnscrypt installer, dnscrypt-proxy v$localDPver -> v$remoteDPver <br>" >>/tmp/amtm-tpu-check
				suUpd=1
				localDPver=v$localDPver
			else
				localDPver=
			fi
		else
			updDP=" ${E_BG}upd err${NC}"
		fi
	else
		ditext="dnscrypt installer"
	fi

	scriptname="dnscrypt installer"
	scriptgrep='^DI_VERSION='
	if [ "$su" = 1 ]; then
		remoteurl="https://raw.githubusercontent.com/thuantran/dnscrypt-asuswrt-installer/master/installer"
		grepcheck=WARNING
	fi
	script_check

	printf "${GN_BG} di${NC} %-9s%-21s%${COR}s\\n" "open" "$ditext $localver" " $upd"
	[ "$su" = 1 ] && printf "${GN_BG}   ${NC} %-9s%-21s%${COR}s\\n" "" "$dptext $localDPver" " $updDP"
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
	echo " https://www.snbforums.com/threads/release-dnscrypt-installer-for-asuswrt.36071/"

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
	if [ -f /jffs/dnscrypt/manager ] && [ -f /jffs/dnscrypt/installer ] && grep -q 'manager init-start' /jffs/scripts/init-start 2> /dev/null; then
		show_amtm " dnscrypt installer installed"
	else
		rm -rf /jffs/dnscrypt
		am=;show_amtm " dnscrypt installer installation failed"
	fi
}
#eof
