## amtm - the Asuswrt-Merlin Terminal Menu

amtm is a front end that manages popular scripts for wireless routers running [Asuswrt-Merlin](https://github.com/RMerl) firmware.

Starting with Asuswrt-Merlin 384.15, amtm is included in the firmware.

**The file /amtm_fw/amtm is for firmware inclusion only**.
Use the install link on this page to install the regular version on Asuswrt-Merlin firmware older than 384.15.

See the Asuswrt-Merlin wiki for the [usage of this firmware version](https://github.com/RMerl/asuswrt-merlin.ng/wiki/AMTM).

News and more about amtm at [Diversion - the Router Adblocker](https://diversion.ch).
Discussion about [amtm - the Asuswrt-Merlin Terminal Menu](https://www.snbforums.com/forums/asuswrt-merlin-addons.60/?prefix_id=16&starter_id=25480).

**Note that starting with version 2.7, amtm is hosted on the Diversion Server**.
The transition for the built in amtm updater is seamless, no user action is required to use the new Server.

### How to install or reinstall amtm on Asuswrt-Merlin older than 384.15
Enter the complete command below into your favorite SSH terminal, then press Enter.

```Shell
/usr/sbin/curl -Os https://diversion.ch/amtm/amtm && sh amtm
```

### How to start amtm after installation or in Asuswrt-Merlin firmware 384.15 and newer
Enter this into your favorite SSH terminal:

```Shell
amtm
```

### Supported scripts

| Script | Maintainer | Infos |
|--------|------------|------|
| Diversion | thelonelycoder | [Link](https://www.snbforums.com/forums/asuswrt-merlin-addons.60/?prefix_id=10&starter_id=25480) |
| Skynet | Adamm | [Link](https://www.snbforums.com/forums/asuswrt-merlin-addons.60/?prefix_id=14) |
| FlexQoS | dave14305 | [Link](https://www.snbforums.com/forums/asuswrt-merlin-addons.60/?prefix_id=8&starter_id=58901) |
| FreshJR Adaptive QOS | FreshJR | [Link](https://www.snbforums.com/threads/release-freshjr-adaptive-qos-improvements-custom-rules-and-inner-workings.36836/) deprecated |
| YazFi | Jack Yaz | [Link](https://www.snbforums.com/forums/asuswrt-merlin-addons.60/?prefix_id=13&starter_id=53009) |
| scribe | cmkelley | [Link](https://www.snbforums.com/forums/asuswrt-merlin-addons.60/?prefix_id=7) |
| x3mRouting | Xentrk | [Link](https://www.snbforums.com/forums/asuswrt-merlin-addons.60/?prefix_id=9) |
| unbound Manager | Martineau | [Link](https://www.snbforums.com/forums/asuswrt-merlin-addons.60/?prefix_id=5) |
| connmon |Jack Yaz | [Link](https://www.snbforums.com/forums/asuswrt-merlin-addons.60/?prefix_id=18&starter_id=53009) |
| ntpMerlin | Jack Yaz | [Link](https://www.snbforums.com/forums/asuswrt-merlin-addons.60/?prefix_id=22&starter_id=53009) |
| scMerlin | Jack Yaz | [Link](https://www.snbforums.com/forums/asuswrt-merlin-addons.60/?prefix_id=23&starter_id=53009) |
| spdMerlin | Jack Yaz | [Link](https://www.snbforums.com/forums/asuswrt-merlin-addons.60/?prefix_id=19&starter_id=53009) |
| uiDivStats | Jack Yaz | [Link](https://www.snbforums.com/forums/asuswrt-merlin-addons.60/?prefix_id=15&starter_id=53009) |
| uiScribe | Jack Yaz | [Link](https://www.snbforums.com/forums/asuswrt-merlin-addons.60/?prefix_id=24&starter_id=53009) |
| Stubby DNS | Xentrk and Adamm | _deprecated_ |
| DNSCrypt | bigeyes0x0, SomeWhereOverTheRainBow | [Link](https://www.snbforums.com/forums/asuswrt-merlin-addons.60/?prefix_id=29&starter_id=64179) |
| Pixelserv-tls | kvic | [Link](https://www.snbforums.com/forums/asuswrt-merlin-addons.60/?prefix_id=17) |
| NVRAM Save/Restore Utility | Xentrk, John9527 & others | [Link](https://www.snbforums.com/forums/asuswrt-merlin-addons.60/?prefix_id=28) |
| YazDHCP | Jack Yaz | [Link](https://www.snbforums.com/forums/asuswrt-merlin-addons.60/?prefix_id=31&starter_id=53009) |
| Vnstat | dev_null | [Link](https://www.snbforums.com/threads/beta-2-vnstat-on-merlin-ui-cli-and-email-data-use-monitoring-with-full-install-and-menu.70727/) |
| WireGuard Session Manager | Martineau | [Link](https://www.snbforums.com/forums/asuswrt-merlin-addons.60/?prefix_id=32&starter_id=13215) |

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

[![amtm v3.1.8](https://cdn.imgchest.com/files/my2pckno67j.png "amtm v3.1.1")](https://cdn.imgchest.com/files/my2pckno67j.png "amtm v3.1.8")
