#!/bin/sh
#bof

mount_entware(){
	[ ! -L /tmp/opt ] && rm -rf /tmp/opt

	if [ -f "${opkgFile%/opkg}/diversion" ]; then
		logger -t Entware "Starting Entware and Diversion services on $opkgPath"
		ln -nsf "${opkgFile%/bin/opkg}" /tmp/opt
		/opt/etc/init.d/rc.unslung start "$0"
		service restart_dnsmasq
	else
		logger -t Entware "Starting Entware services on $opkgPath"
		ln -nsf "${opkgFile%/bin/opkg}" /tmp/opt
		/opt/etc/init.d/rc.unslung start "$0"
	fi
}

opkgPath="${1:-/mnt/MERLIN}"
opkgFile=$(/usr/bin/find "$opkgPath/entware/bin/opkg" 2> /dev/null)

if [ "$opkgFile" ] && [ ! -d /opt/bin ]; then
	mount_entware
elif [ "$opkgFile" ] && [ -d /opt/bin ]; then
	if [ -f /opt/.asusrouter ]; then # remove DLM
		[ -f /jffs/addons/amtm/a_fw/amtm.mod ] && . /jffs/addons/amtm/a_fw/amtm.mod
		[ -f /jffs/scripts/amtm ] && . /jffs/scripts/amtm
	else
		logger -t Entware "Not starting Entware services on $opkgPath, Entware is already started"
	fi
else
	opkgUnknown=$(/usr/bin/find "$opkgPath/entware*/bin/opkg" 2> /dev/null)
	if [ "$opkgUnknown" ]; then
		mv "${opkgUnknown%/bin/opkg}" "${opkgUnknown%/entware*/bin/opkg}/entware"
		logger -t Entware "(Alert) Entware folder ${opkgUnknown%/bin/opkg} renamed to $opkgPath/entware"
		opkgFile=$(/usr/bin/find "$opkgPath/entware/bin/opkg" 2> /dev/null)
		mount_entware
	else
		logger -t Entware "(Notice) $opkgPath does not contain Entware, skipping device"
	fi
fi
#eof
