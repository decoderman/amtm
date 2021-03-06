#!/bin/sh
#bof
check_ps_ca(){ [ -f /opt/var/cache/pixelserv/router.asus.com ] || [ -f "/opt/var/cache/pixelserv/$(nvram get ddns_hostname_x)" ] && psca=1 || psca=;}
check_ps_ca

if [ "$psca" = 1 ]; then
	atii=1
	[ -z "$su" ] && printf "${GN_BG} ps${NC} %-9s%-21s%${COR}s\\n" "reissue" "pixelserv-tls CA for WebUI" ""
	run=Rerun
	runs="(re)runs"
else
	[ "$ss" ] && [ -z "$su" ] && printf "${E_BG} ps${NC} %-9s%-21s%${COR}s\\n" "use" "pixelserv-tls CA for WebUI" ""
	run=Run
	runs=runs
fi

use_ps_ca(){
	p_e_l
	echo " This $runs the pixelserv-tls helper"
	echo " script to use its CA to issue a certificate"
	echo " for your routers https (secure) WebUI."
	echo
	echo " Author: kvic"
	echo " https://github.com/kvic-z/pixelserv-tls/wiki/%5BASUSWRT%5D-Use-Pixelserv-CA-to-issue-a-certificate-for-WebGUI"
	echo
	echo " With updated Asuswrt-Merlin router list by thelonelycoder"
	p_e_l

	echo " 1. $run helper script, modified by"
	echo "    thelonelycoder with updated"
	echo "    Asuswrt-Merlin router list (March 3 2021)"
	while true; do
		printf "\\n Enter selection [1-1 e=Exit] ";read -r continue
		case "$continue" in
			1)			p_e_l
						sh -c "$(wget -qO - https://diversion.ch/scripts/config-webgui.sh)"
						echo
						check_ps_ca;break;;
			[Ee])		check_ps_ca
						[ -z "$psca" ] && r_m pixelserv-tls.mod
						am=;show_amtm menu;break;;
			*)			printf "\\n input is not an option\\n";;
		esac
	done

	if [ "$psca" = 1 ]; then
		show_amtm " pixelserv-tls CA for WebUI (re)issued "
	else
		r_m pixelserv-tls.mod
		am=;show_amtm " Failed to issue pixelserv-tls CA for WebUI"
	fi
}
#eof
