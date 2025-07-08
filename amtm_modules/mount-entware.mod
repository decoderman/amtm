#!/bin/sh
#bof

MOUNT_PATH="${1:-/mnt/MERLIN}"

mount_entware() {
    # Clean up /tmp/opt if it's a directory or broken link
    [ ! -L /tmp/opt ] && rm -rf /tmp/opt

    if [ -f "${opkgFile%/opkg}/diversion" ]; then
        logger -t Entware "Starting Entware and Diversion services on $MOUNT_PATH"
        ln -nsf "${opkgFile%/bin/opkg}" /tmp/opt
        /opt/etc/init.d/rc.unslung start "$0"
        service restart_dnsmasq
    else
        logger -t Entware "Starting Entware services on $MOUNT_PATH"
        ln -nsf "${opkgFile%/bin/opkg}" /tmp/opt
        /opt/etc/init.d/rc.unslung start "$0"
    fi
}

opkgFile=$(/usr/bin/find "$MOUNT_PATH/entware/bin/opkg" 2> /dev/null)

if [ "$opkgFile" ] && [ ! -d /opt/bin ]; then
    mount_entware
elif [ "$opkgFile" ] && [ -d /opt/bin ]; then
    logger -t Entware "Not starting Entware services on $MOUNT_PATH, Entware is already started"
else
    opkgUnknown=$(/usr/bin/find "$MOUNT_PATH/entware*/bin/opkg" 2> /dev/null)
    if [ "$opkgUnknown" ]; then
        mv "${opkgUnknown%/bin/opkg}" "${opkgUnknown%/entware*/bin/opkg}/entware"
        logger -t Entware "(Alert) Entware folder ${opkgUnknown%/bin/opkg} renamed to $MOUNT_PATH/entware"
        opkgFile=$(/usr/bin/find "$MOUNT_PATH/entware/bin/opkg" 2> /dev/null)
        mount_entware
    else
        logger -t Entware "(Notice) $MOUNT_PATH does not contain Entware, skipping device"
    fi
fi
#eof
