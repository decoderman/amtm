## amtm - the SNBForum Asuswrt-Merlin Terminal Menu

A shortcut manager for popular scripts for wireless routers running Asuswrt-Merlin firmware.

Discuss and read more on the SmallNetBuilders Forum: [amtm - the SNBForum Asuswrt-Merlin Terminal Menu](https://www.snbforums.com/threads/amtm-the-snbforums-asuswrt-merlin-terminal-menu.42415/)

### How to install on Asuswrt-Merlin
Enter this into your favorite SSH terminal:

```Shell
/usr/sbin/curl -Os https://raw.githubusercontent.com/decoderman/amtm/master/amtm && sh amtm
```

Screenshot of amtm 1.9, uses selected color theme when [Diversion](https://diversion.ch/) is installed:

[![amtm v1.7](https://i.imgur.com/32S8wD0.png "amtm v1.9")](https://i.imgur.com/32S8wD0.png "amtm v1.9")

### Currently supported scripts

[Diversion](https://www.snbforums.com/threads/diversion-the-router-adblocker.48538/) - maintained by thelonelycoder<br/>
[DNSCrypt](https://www.snbforums.com/threads/release-dnscrypt-installer-for-asuswrt.36071/) - maintained by bigeyes0x0<br/>
[Entware](https://github.com/Entware/entware) - maintained by zyxmon & ryzhovau<br/>
[Pixelserv-tls](https://www.snbforums.com/threads/pixelserv-a-better-one-pixel-webserver-for-adblock.26114/) - maintained by kvic<br/>
[Skynet](https://www.snbforums.com/threads/release-skynet-router-firewall-security-enhancements.16798/) - maintained by Adamm<br/>
[USB Disk Check at Boot](https://github.com/RMerl/asuswrt-merlin/wiki/USB-Disk-Check-at-Boot) - maintained by latenitetech, thelonelycoder<br/>
[Format Disk](https://www.snbforums.com/threads/amtm-the-snbforum-asuswrt-merlin-terminal-menu.42415/) - maintained by thelonelycoder<br/>
[Stubby-Installer](https://www.snbforums.com/threads/stubby-installer-asuswrt-merlin.49469/) - maintained by Xentrk and Adamm<br/>
[YazFi](https://www.snbforums.com/threads/yazfi-enhanced-asuswrt-merlin-guest-wifi-inc-ssid-vpn-client.45924/) - maintained by Jack Yaz<br/>
[ntpMerlin](https://www.snbforums.com/threads/ntpmerlin-installer-for-kvic-ntp-daemon.55756/) - maintained by Jack Yaz<br/>

### How to start amtm after installation
Enter this into your SSH terminal:

```Shell
/jffs/scripts/amtm
```

If Entware is installed on the router, start amtm with this command.<br/>
[Diversion](https://diversion.ch/) installs Entware by default, amtm has an option to do so.

```Shell
amtm
```
