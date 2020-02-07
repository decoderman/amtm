## amtm - the Asuswrt-Merlin Terminal Menu

amtm is a front end that manages popular scripts for wireless routers running [Asuswrt-Merlin](https://github.com/RMerl) firmware.

Starting with Asuswrt-Merlin 384.15, amtm is included in the firmware.

**The file /amtm_fw/amtm is for firmware inclusion only**. 
Use the install link on this page to install the regular version on Asuswrt-Merlin firmware older than 384.15.
 
See the Asuswrt-Merlin wiki for the [usage of this firmware version](https://github.com/RMerl/asuswrt-merlin/wiki/AMTM).

News and more about amtm at [Diversion - the Router Adblocker](https://diversion.ch).  
Discussion about amtm [amtm - the SNBForum Asuswrt-Merlin Terminal Menu](https://www.snbforums.com/threads/amtm-the-snbforums-asuswrt-merlin-terminal-menu.42415/).

**Note that starting with version 2.7, amtm is now hosted on the Diversion Server, this repository will no longer be updated**.  
The transition for the built in amtm updater is seamless, no user action is required to use the new Server.

### How to install or reinstall amtm on Asuswrt-Merlin
Enter the complete command below into your favorite SSH terminal, then press Enter.

```Shell
/usr/sbin/curl -Os https://diversion.ch/amtm/amtm && sh amtm
```

[![amtm v2.8](https://i.imgur.com/XWGL9vN.png "amtm v2.8")](https://i.imgur.com/XWGL9vN.png "amtm v2.8")

### Supported scripts

[Diversion](https://www.snbforums.com/threads/diversion-the-router-adblocker.48538/) - maintained by thelonelycoder<br/>
[Skynet](https://www.snbforums.com/threads/release-skynet-router-firewall-security-enhancements.16798/) - maintained by Adamm<br/>
[Stubby-Installer](https://www.snbforums.com/threads/stubby-installer-asuswrt-merlin.49469/) - maintained by Xentrk and Adamm (partially deprecated due to native support in firmware)<br/>
[YazFi](https://www.snbforums.com/threads/yazfi-enhanced-asuswrt-merlin-guest-wifi-inc-ssid-vpn-client.45924/) - maintained by Jack Yaz<br/>
[scribe](https://www.snbforums.com/threads/scribe-syslog-ng-and-logrotate-installer.55853/) - maintained by cmkelley<br/>
[x3mRouting](https://www.snbforums.com/threads/x3mrouting-selective-routing-for-asuswrt-merlin-firmware.57793/) - maintained by Xentrk<br/>

[connmon](https://www.snbforums.com/threads/connmon-internet-connection-monitoring.56163/) - maintained by Jack Yaz<br/>
[ntpMerlin](https://www.snbforums.com/threads/ntpmerlin-installer-for-kvic-ntp-daemon.55756/) - maintained by Jack Yaz<br/>
[scMerlin](https://www.snbforums.com/threads/scmerlin-service-and-script-control-menu-for-asuswrt-merlin.56277/) - maintained by Jack Yaz<br/>
[spdMerlin](https://www.snbforums.com/threads/spdmerlin-automated-speedtests-with-graphs.55904/) - maintained by Jack Yaz<br/>
[uiDivStats](https://www.snbforums.com/threads/uidivstats-webui-for-diversion-statistics.56393/) - maintained by Jack Yaz<br/>
[uiScribe](https://www.snbforums.com/threads/uiscribe-custom-system-log-page-for-scribed-logs.57040/) - maintained by Jack Yaz<br/>

[DNSCrypt](https://www.snbforums.com/threads/release-dnscrypt-installer-for-asuswrt.36071/) - maintained by bigeyes0x0<br/>
[Entware](https://github.com/Entware/entware) - maintained by zyxmon & ryzhovau<br/>
[Pixelserv-tls](https://www.snbforums.com/threads/pixelserv-a-better-one-pixel-webserver-for-adblock.26114/) - maintained by kvic (beta support suspended)<br/>

[USB Disk Check at Boot or Hot Plug (improved version)](https://github.com/RMerl/asuswrt-merlin/wiki/USB-Disk-Check-at-Boot-or-Hot-Plug-(improved-version)) - maintained by ColinTaylor, latenitetech, thelonelycoder<br/>
[Format Disk](https://www.snbforums.com/threads/amtm-the-snbforum-asuswrt-merlin-terminal-menu.42415/) - maintained by thelonelycoder and ColinTaylor. Now supports creation of up to three partitions.<br/>

### Additional features

Reboot scheduler via cron job - maintained by thelonelycoder<br/>
Swap file creation and management - maintained by thelonelycoder<br/>
amtm themes - maintained by thelonelycoder<br/>

### How to start amtm after installation
Enter this into your SSH terminal:

```Shell
/jffs/scripts/amtm
```

If Entware is installed on the router, start amtm with this command, [Diversion](https://diversion.ch/) installs Entware by default, amtm has an option to do so.

```Shell
amtm
```
