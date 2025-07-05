## amtm - the Asuswrt-Merlin Terminal Menu

amtm is a shell-based front end that manages popular scripts for wireless routers running [Asuswrt-Merlin](https://github.com/RMerl) firmware.

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
| FlexQoS | dave14305, AMTM-OSR team | [Link](https://www.snbforums.com/forums/asuswrt-merlin-addons.60/?prefix_id=8&starter_id=58901) |
| YazFi | Jack Yaz, AMTM-OSR team | [Link](https://www.snbforums.com/forums/asuswrt-merlin-addons.60/?prefix_id=13&starter_id=53009) |
| scribe | cmkelley | [Link](https://www.snbforums.com/forums/asuswrt-merlin-addons.60/?prefix_id=7) |
| x3mRouting | Xentrk | [Link](https://www.snbforums.com/forums/asuswrt-merlin-addons.60/?prefix_id=9) |
| unbound Manager | Martineau | [Link](https://www.snbforums.com/forums/asuswrt-merlin-addons.60/?prefix_id=5) |
| connmon |Jack Yaz, AMTM-OSR team | [Link](https://www.snbforums.com/forums/asuswrt-merlin-addons.60/?prefix_id=18&starter_id=53009) |
| ntpMerlin | Jack Yaz, AMTM-OSR team | [Link](https://www.snbforums.com/forums/asuswrt-merlin-addons.60/?prefix_id=22&starter_id=53009) |
| scMerlin | Jack Yaz, AMTM-OSR team | [Link](https://www.snbforums.com/forums/asuswrt-merlin-addons.60/?prefix_id=23&starter_id=53009) |
| spdMerlin | Jack Yaz, AMTM-OSR team | [Link](https://www.snbforums.com/forums/asuswrt-merlin-addons.60/?prefix_id=19&starter_id=53009) |
| uiDivStats | Jack Yaz, AMTM-OSR team | [Link](https://www.snbforums.com/forums/asuswrt-merlin-addons.60/?prefix_id=15&starter_id=53009) |
| uiScribe | Jack Yaz | [Link](https://www.snbforums.com/forums/asuswrt-merlin-addons.60/?prefix_id=24&starter_id=53009) |
| DNSCrypt | bigeyes0x0, SomeWhereOverTheRainBow | [Link](https://www.snbforums.com/forums/asuswrt-merlin-addons.60/?prefix_id=29&starter_id=64179) |
| YazDHCP | Jack Yaz, AMTM-OSR team | [Link](https://www.snbforums.com/forums/asuswrt-merlin-addons.60/?prefix_id=31&starter_id=53009) |
| Vnstat | dev_null | [Link](https://www.snbforums.com/threads/beta-2-vnstat-on-merlin-ui-cli-and-email-data-use-monitoring-with-full-install-and-menu.70727/) |
| WireGuard Session Manager | Martineau | [Link](https://www.snbforums.com/forums/asuswrt-merlin-addons.60/?prefix_id=32&starter_id=13215) |
| Asuswrt-Merlin-AdGuardHome-Installer | SomeWhereOverTheRainBow | [Link](https://www.snbforums.com/threads/new-release-asuswrt-merlin-adguardhome-installer.76506/) |
| VPNMON-R3 | Viktor Jaep | [Link](https://www.snbforums.com/forums/asuswrt-merlin-addons.60/?prefix_id=36) |
| RTRMON | Viktor Jaep | [Link](https://www.snbforums.com/forums/asuswrt-merlin-addons.60/) |
| WICENS | Maverickcdn | [Link](https://www.snbforums.com/threads/wicens-wan-ip-change-email-notification-script.69294/) |
| KILLMON | Viktor Jaep | [Link](https://www.snbforums.com/threads/killmon-v1-05-feb-20-2023-ip4-ip6-vpn-kill-switch-monitor-configurator.81758/) |
| Dual WAN Failover | Ranger802004 | [Link](https://www.snbforums.com/threads/dual-wan-failover-v2-0-2-release.83674/) |
| BACKUPMON | Viktor Jaep | [Link](https://www.snbforums.com/threads/backupmon-v1-22-oct-2-2023-backup-restore-your-router-jffs-nvram-external-usb-drive.86645/) |
| Domain-based VPN Routing | Ranger802004 | [Link](https://www.snbforums.com/threads/domain-based-vpn-routing-script.79264/) |
| MerlinAU Firmware Auto-Updater | ExtremeFiretop | [Link](https://www.snbforums.com/threads/introducing-merlinau-the-ultimate-firmware-auto-updater-addon.88577/) |
| TAILMON Tailscale installer | Viktor Jaep | [Link](https://www.snbforums.com/threads/release-tailmon-v1-0-8-may-3-2024-wireguard-based-tailscale-installer-configurator-and-monitor.89860/) |
| WXMON Localized Weather Monitoring | Viktor Jaep | [Link](https://www.snbforums.com/threads/release-wxmon-v2-1-1-jul-3-2025-localized-weather-monitoring-extended-forecasts-including-aviation-metars-and-tafs-us-global.83479/) |

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
| email settings | thelonelycoder |
| 10 router games to choose from | thelonelycoder |
| Keep a history of entered shell commands | thelonelycoder
| Router date keeper | thelonelycoder
| amtm and third party script reset/remove options | thelonelycoder
| Show all cron jobs | thelonelycoder
| Reboot router command | thelonelycoder
| Scripts update notification | thelonelycoder

Feel free to visit and contribute to the AMTM Orphaned Script Revival repo (AMTM-OSR): [Link](https://github.com/AMTM-OSR)

[![amtm 6.0](https://cdn.imgchest.com/files/7w6c25ndqxy.png "amtm 6.0")](https://cdn.imgchest.com/files/7w6c25ndqxy.png "amtm 6.0")
