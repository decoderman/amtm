# amtm - the SNBForum Asuswrt-Merlin Terminal Menu

A shortcut manager for popular scripts for wireless routers running Asuswrt-Merlin firmware.

Discuss and read more on the SmallNetBuilders Forum: [amtm - the SNBForum Asuswrt-Merlin Terminal Menu](https://www.snbforums.com/threads/amtm-the-snbforums-asuswrt-merlin-terminal-menu.42415/)


### How to install on Asuswrt-Merlin
Enter this into your favorite SSH terminal:

`/usr/sbin/curl -Os https://raw.githubusercontent.com/decoderman/amtm/master/amtm && sh amtm`


Screenshot of v1.7, uses selected color theme when [Diversion](https://diversion.ch/) is installed:

[![amtm v1.7](https://i.imgur.com/r78Jzxl.png "amtm v1.7")](https://i.imgur.com/r78Jzxl.png "amtm v1.7")

### Currently supported scripts

[Diversion / AB-Solution](https://www.snbforums.com/threads/diversion-the-router-adblocker.48538/) - maintained by thelonelycoder
 
[DNSCrypt](https://www.snbforums.com/threads/release-dnscrypt-installer-for-asuswrt.36071/) - maintained by bigeyes0x0
 
[Entware](https://github.com/Entware/entware) - maintained by zyxmon & ryzhovau
 
[Pixelserv-tls](https://www.snbforums.com/threads/pixelserv-a-better-one-pixel-webserver-for-adblock.26114/) - maintained by kvic
 
[Skynet](https://www.snbforums.com/threads/skynet-asus-firewall-addition-dynamic-malware-country-manual-ip-blocking.16798/) - maintained by Adamm

[USB Disk Check at Boot](https://github.com/RMerl/asuswrt-merlin/wiki/USB-Disk-Check-at-Boot) - maintained by latenitetech, thelonelycoder

[Format Disk](https://www.snbforums.com/threads/amtm-the-snbforum-asuswrt-merlin-terminal-menu.42415/) - maintained by thelonelycoder

[Stubby-Installer](https://www.snbforums.com/threads/stubby-installer-asuswrt-merlin.49469/) - maintained by Xentrk


### How to start amtm after installation
Enter this into your SSH terminal:

`/jffs/scripts/amtm`

If Entware is installed on the router, start amtm with this command.
[Diversion / AB-Solution](https://www.snbforums.com/threads/diversion-the-router-adblocker.48538/) installs Entware by default, amtm has an option to do so.

`amtm`
