## amtm - the Asuswrt-Merlin Terminal Menu

amtm is a front end that manages popular scripts for wireless routers running [Asuswrt-Merlin](https://github.com/RMerl) firmware.

Starting with Asuswrt-Merlin 384.15, amtm is included in the firmware.

**The file /amtm_fw/amtm is for firmware inclusion only**.
Use the install link on this page to install the regular version on Asuswrt-Merlin firmware older than 384.15.

See the Asuswrt-Merlin wiki for the [usage of this firmware version](https://github.com/RMerl/asuswrt-merlin/wiki/AMTM).

News and more about amtm at [Diversion - the Router Adblocker](https://diversion.ch).
Discussion about [amtm - the Asuswrt-Merlin Terminal Menu](https://www.snbforums.com/threads/amtm-the-snbforums-asuswrt-merlin-terminal-menu.42415/).

**Note that starting with version 2.7, amtm is hosted on the Diversion Server**.
The transition for the built in amtm updater is seamless, no user action is required to use the new Server.

### How to install or reinstall amtm on Asuswrt-Merlin older than 384.15
Enter the complete command below into your favorite SSH terminal, then press Enter.

```Shell
/usr/sbin/curl -Os https://diversion.ch/amtm/amtm && sh amtm
```

[![amtm v3.1.8](https://cdn.imgchest.com/files/my2pckno67j.png "amtm v3.1.1")](https://cdn.imgchest.com/files/my2pckno67j.png "amtm v3.1.8")

### Supported scripts

| Script | Maintainer | Infos |
|--------|------------|------|
| Diversion | thelonelycoder | [Link](https://www.snbforums.com/threads/diversion-the-router-ad-blocker.48538/) |
| Skynet | Adamm | [Link](https://www.snbforums.com/threads/skynet-asus-firewall-addition-dynamic-malware-country-manual-ip-blocking.16798/) |
| FlexQoS | dave14305 | [Link](https://www.snbforums.com/threads/fork-flexqos-flexible-qos-enhancement-script-for-adaptive-qos.64882/) |
| FreshJR Adaptive QOS | FreshJR | [Link](https://www.snbforums.com/threads/release-freshjr-adaptive-qos-improvements-custom-rules-and-inner-workings.36836/) deprecated |
| YazFi | Jack Yaz | [Link](https://www.snbforums.com/threads/yazfi-enhanced-asuswrt-merlin-guest-wifi-inc-ssid-vpn-client.45924/) |
| scribe | cmkelley | [Link](https://www.snbforums.com/threads/scribe-syslog-ng-and-logrotate-installer.55853/) |
| x3mRouting | Xentrk | [Link](https://www.snbforums.com/threads/x3mrouting-selective-routing-for-asuswrt-merlin-firmware.57793/) |
| unbound Manager | Martineau | [Link](https://www.snbforums.com/threads/release-unbound_manager-manager-installer-utility-for-unbound-recursive-dns-server.61669/) |
| connmon |Jack Yaz | [Link](https://www.snbforums.com/threads/connmon-internet-connection-monitoring.56163/) |
| ntpMerlin | Jack Yaz | [Link](https://www.snbforums.com/threads/ntpmerlin-ntp-daemon-for-asuswrt-merlin.55756/) |
| scMerlin | Jack Yaz | [Link](https://www.snbforums.com/threads/scmerlin-service-and-script-control-menu-for-asuswrt-merlin.56277/) |
| spdMerlin | Jack Yaz | [Link](https://www.snbforums.com/threads/spdmerlin-automated-speedtests-with-graphs.55904/) |
| uiDivStats | Jack Yaz | [Link](https://www.snbforums.com/threads/uidivstats-webui-for-diversion-statistics.56393/) |
| uiScribe | Jack Yaz | [Link](https://www.snbforums.com/threads/uiscribe-custom-system-log-page-for-scribed-logs.57040/) |
| Stubby DNS | Xentrk and Adamm | _deprecated_ |
| DNSCrypt | bigeyes0x0, SomeWhereOverTheRainBow | [Link](https://www.snbforums.com/threads/release-dnscrypt-installer-for-asuswrt.36071/) |
| Pixelserv-tls | kvic | [Link](https://www.snbforums.com/threads/pixelserv-a-better-one-pixel-webserver-for-adblock.26114/) |

amtm also offers an interface for managing a number of other features:

| Other features | Maintainer |
|----------------|-----------|
| Entware | zyxmon, ryzhovau, themiron |
| USB disk check at boot | ColinTaylor, latenitetech, thelonelycoder |
| Format disk | thelonelycoder, ColinTaylor |
| Router LED control, smart router LED scheduler | thelonelycoder |
| Reboot scheduler via cron job | thelonelycoder |
| Swap file creation and management | thelonelycoder |
| amtm themes | thelonelycoder |

### How to start amtm after installation or in Asuswrt-Merlin firmware 384.15 and newer
Enter this into your favorite SSH terminal:

```Shell
amtm
```
