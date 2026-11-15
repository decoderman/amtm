#!/bin/sh
#bof
opkgFile=$(/usr/bin/find /tmp/mnt/*/entware/bin/opkg 2> /dev/null)
if [ -f "$opkgFile" ]; then
	opkgDevice=${opkgFile%/entware/bin/opkg}
	printf "\\n------------------------------\\n\\n"
	logger -s -t amtm "Found Download Master installed, while Entware is present on $opkgDevice"
	logger -s -t amtm "Removing Download Master now as it is incompatible with Entware"
	service stop_nasapps >/dev/null 2>&1
	[ -d "$(nvram get apps_mounted_path)/$(nvram get apps_install_folder)" ] &&	rm -rf "$(nvram get apps_mounted_path)/$(nvram get apps_install_folder)"
	nvram set apps_mounted_path=
	nvram set apps_dev=
	nvram set apps_state_autorun=
	nvram set apps_state_enable=
	nvram set apps_state_install=
	nvram set apps_state_switch=
	nvram set apps_swap_enable=
	nvram commit
	if [ -L /tmp/opt ]; then
		rm -f /tmp/opt 2> /dev/null
		rm -f /opt 2> /dev/null
	fi
	service start_nasapps >/dev/null 2>&1
	logger -s -t amtm "Download Master removed, starting Entware services on $opkgDevice now"
	sh /jffs/scripts/post-mount $opkgDevice >/dev/null 2>&1
	printf "\\n------------------------------\\n"
	sleep 14
	r_m rmDLmaster.mod
fi
#eof
