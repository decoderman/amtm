#!/usr/bin/env sh

_scriptver=v0.2.2

# DESCRIPTION
#
# A script to issue and configure ASUSWRT WebGUI by using pixelserv-tls and
# a user-generated Pixelserv CA certificate.
#
#    (c) 2018-19 kvic (aka kvic-z@github)
#
#    https://kazoo.ga/pixelserv-tls/
#
# HISTORY
#
# Nov 6 2021   Simplified supported models.
# March 6 2020 Modification by thelonelycoder.
#              Added GT-AC2900 and RT-AX86U, added stop point for errors.
# May 2 2020   Modification by thelonelycoder.
#              Added DSL-AC68U RT-AC88U RT-AX56U RT-AX58U RT-AX3000. Removed R7000 (cannot legally run Asuswrt-Merlin)
# 2019-1-12    Added RT-AX88U
# 2018-12-25   Added compatibility for FW >= 384.8
# 2018-9-16    Added R7000.
# 2018-8-24    Fix error using DDNS.
# 2018-3-22    Swap domain choices. Put router.asus.com first.
# 2018-3-21    Persist certs for FW > 380.66
# 2018-3-16    Initial release
#

p_e_l(){ echo "_____________________________________________";echo;}
p_e_t(){ printf "\\n Press Enter to Exit ";read -r;echo;exit 1;}
issue_config_webgui() {

	[[ "$(/bin/ps | grep -v grep | grep -o pixelserv-tls)" = ""  || ! -x /opt/bin/pixelserv-tls ]] && \
		p_e_l && \
		echo "You do not appear to have pixelserv-tls installed or running." &&  \
		p_e_t

	_model=$(nvram get model | grep 'RT-AC56\|-AC68\|RT-AC87\|RT-AC3100\|RT-AC88\|RT-AC3200\|RT-AC5300\|RT-AC86U\|-AX\|RT-AC88U\|GT-AC2900')
	_ddns=$(nvram get ddns_hostname_x)
	_le_en=$(nvram get le_enable)

	if [ "$_model" = "" ]; then
	p_e_l
	echo "This feature is currently not supported on your model ($(nvram get model))."
	echo "Please contact @thelonelycoder for assistance."
	p_e_t
	fi

	[ "${_ddns}" = "" ] && \
	echo "Note that you do not appear to have DDNS configured or working."
	echo ""
	echo "Use your Pixelserv CA to issue a certificate to domain:"
	echo ""
	echo "  a. router.asus.com"
	[ "${_ddns}" != "" ] && \
	echo "  b. ${_ddns}"
	echo ""
	[ "${_ddns}" != "" ] && \
	echo "Note that (a) works from LAN and VPN. It's recommended."
	echo "(b) additionally works for access from WAN."
	echo ""
	echo ""
	echo -n "Type a" && [ "${_ddns}" != "" ] && echo -n ", b"
	echo -n " to proceed or anything else to quit: "

	read ans

	echo ""

	_domain=""
	[ "$ans" = "a" ] && _domain="router.asus.com"
	[ "$ans" = "b" ] && [ "$_ddns" != "" ] && _domain=${_ddns}

	[ "$_domain" = "" ] && exit 0

	echo -n ${_domain} > /tmp/pixelcerts && sleep 1
	[ ! -f /opt/var/cache/pixelserv/${_domain} ] && \
	p_e_l && \
	echo "Failed to issue a cert to ${_domain}." && \
	echo "You may re-run this script to try again or contact me for assistance." && \
	p_e_t

	echo "*****"
	echo "A new cert has been issued by your Pixelserv CA to domain: ${_domain}"
	echo ""
	echo "This script is about to config and restart WebGUI."
	echo ""
	echo "Please type 'yes' to proceed or anything else to quit."
	echo ""

	read ans

	echo ""

	[ "$ans" != "yes" ] && exit 0

	_certbk=no
	[ -f /etc/cert.pem ] && cp /etc/cert.pem /jffs/cert.pem-bk && \
	[ -f /etc/key.pem ] && cp /etc/key.pem /jffs/key.pem-bk && _certbk=yes && \
		rm /etc/key.pem && rm /etc/cert.pem

	cp -f /opt/var/cache/pixelserv/${_domain} /etc/cert.pem
	cp -f /opt/var/cache/pixelserv/${_domain} /etc/key.pem
	for p in "/jffs/ssl" "/jffs/.cert"; do
	[ -d "$p" ] && \
		cp /opt/var/cache/pixelserv/${_domain} ${p}/cert.pem && \
		cp /opt/var/cache/pixelserv/${_domain} ${p}/key.pem
	done
	nvram set le_enable=2
	nvram set https_crt_save=1
	nvram set https_crt_file=""
	service restart_httpd 1>&2 > /dev/null
	nvram commit

	echo "*****"
	echo "Configured new cert and restarted WebGUI. Please keep this terminal open."
	echo "Now try to access WebGUI from a test client."
	echo ""
	echo "If you see a padlock, congrats or else you may revert the change."
	echo ""
	echo "Type 'revert' to restore or anything else to quit and enjoy the new cert."
	echo ""

	read ans

	echo ""

	if [ "$ans" != "revert" ]; then
		echo ""
		echo "Congratulations. All done. Happy pixelserv'ing!"
		echo ""
		[ "$_certbk" = "yes" ] && \
			echo "This script has backup of original WebGUI cert under /jffs." && \
			echo "You may safely delete them by issuing the following:" && \
			echo "" && \
			echo "       rm -i /jffs/cert.pem-bk" && \
			echo "       rm -i /jffs/key.pem-bk" && \
		echo ""
		exit 0
	fi

	echo -n "Reverting..."

	mv -f /jffs/cert.pem-bk /etc/cert.pem
	mv -f /jffs/key.pem-bk /etc/key.pem
	[ -d /jffs/ssl ] && \
	cp -f /etc/cert.pem /jffs/ssl && \
	  cp -f /etc/key.pem /jffs/ssl
	[ "${_le_en}" = "" ] && nvram unset le_enable
	[ "${_le_en}" != "" ] && nvram set le_enable=${_le_en}
	nvram set https_crt_save=1
	nvram set https_crt_file=""
	service restart_httpd 1>&2 > /dev/null
	nvram commit

	echo "done. All good as before."
	exit 0
}

cat <<EOF

(c) 2018-19 kvic (aka kvic-z@github)

https://kazoo.ga/pixelserv-tls/

PERMISSION IS GRANTED TO USE OR MODIFY THIS SCRIPT FREE OF CHARGE
AS LONG AS THE ABOVE COPYRIGHT NOTICE REMAINS INTACT.
NO WARRANTY IS PROVIDED. PLEASE DECIDE AND USE AT YOUR OWN RISK.

This script (${_scriptver}) will guide you through the process of using
your Pixelserv CA to issue a new certificate to ASUSWRT WebGUI.

As a pixelserv-tls user, you have generated your own root CA during
installation and have it imported on client devices and in browsers.

Hence, using your Pixelserv CA to issue a new certificate to WebGUI saves you
hassle to import a newly self-signed certificate after every firmware upgrade.
Simply re-run this script to configure WebGUI again after firmware upgrade.

** NOTE **

Re-run after firmware upgrade ONLY required if you have done
Factory Resets that wipe out NVRAM and /jffs partition.

*****
Before you proceed, pls have pixelserv-tls installed and running. You shall also
have your Pixelserv CA cert imported on a test client.


  1. Issue and config a certificate for ASUSWRT WebGUI


EOF

echo -n "Type 1 to proceed or anything else to quit: "

read ans

echo ""

[ "$ans" != "1" ] && exit 0

issue_config_webgui

