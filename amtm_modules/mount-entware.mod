#!/bin/sh
#bof

mount_entware(){
	if [ -f "${opkgFile%/opkg}/diversion" ]; then
		logger -t Entware "Starting Entware and Diversion services on $1"
		ln -nsf "${opkgFile%/bin/opkg}" /tmp/opt
		/opt/etc/init.d/rc.unslung start $0
		service restart_dnsmasq
	else
		logger -t Entware "Starting Entware services on $1"
		ln -nsf "${opkgFile%/bin/opkg}" /tmp/opt
		/opt/etc/init.d/rc.unslung start $0
	fi
}

opkgFile=$(/usr/bin/find $1/entware/bin/opkg 2> /dev/null)
if [ "$opkgFile" ] && [ ! -d /opt/bin ]; then
	mount_entware $1
elif [ "$opkgFile" ] && [ -d /opt/bin ]; then
	logger -t Entware "Not starting Entware services on $1, Entware is already started"
else
	opkgUnknown=$(/usr/bin/find $1/entware*/bin/opkg 2> /dev/null)
	if [ "$opkgUnknown" ]; then
		mv "${opkgUnknown%/bin/opkg}" "${opkgUnknown%/entware*/bin/opkg}/entware"
		logger -t Entware "(Alert) Entware folder ${opkgUnknown%/bin/opkg} renamed to $1/entware"
		opkgFile=$(/usr/bin/find $1/entware/bin/opkg 2> /dev/null)
		mount_entware $1
	else
		logger -t Entware "(Notice) $1 does not contain Entware, skipping device"
	fi
fi
#eof
