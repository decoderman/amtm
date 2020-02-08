#!/bin/sh
#bof
disk_check_installed(){
	atii=1
	[ -f /jffs/scripts/disk-check ] && mv /jffs/scripts/disk-check "${add}"
	
	if ! grep -qE "^VERSION=$dc_version" "${add}"/disk-check; then
		if grep -q "^blkidExclude=" "${add}"/disk-check; then
			blkidExclude="$(grep "^blkidExclude=" "${add}"/disk-check | sed -e "s/blkidExclude=//;s/'//g")"
			[ "$blkidExclude" = "''" ] && blkidExclude=
		fi
		disk_check install
		a_m " - Disk check script updated to v$dc_version"
	fi
	[ -f "${add}"/amtm-disk-check.log ] && dcltext="${GN_BG}dcl${NC} show log" || dcltext=
	[ -z "$su" ] && printf "${GN_BG} dc${NC} %-9s%-19s%${COR}s\\n" "manage" "Disk check script" " $dcltext"
}
install_disk_check(){
	p_e_l
	echo " This installs ${add}/disk-check."
	echo " It runs a filesystem check on compatible"
	echo " USB storage devices before they are mounted."
	echo
	echo " Authors: ColinTaylor, thelonelycoder, latenitetech"
	echo " https://github.com/RMerl/asuswrt-merlin/wiki/USB-Disk-Check-at-Boot-or-Hot-Plug-(improved-version)"
	echo " https://github.com/RMerl/asuswrt-merlin/wiki/USB-Disk-Check-at-Boot"
	c_d
	disk_check install
	show_amtm " Disk check script installed.\\n The check log can be viewed with dcl."
}
disk_check(){
	if [ -f /jffs/scripts/pre-mount ] && grep -q "e2fsck -p" /jffs/scripts/pre-mount; then
		am=;show_amtm " Unsupported pre-mount script found,\\n please remove file manually"
	else
		if [ "$1" = install ]; then
			write_dc_file
			c_j_s /jffs/scripts/pre-mount
			if ! grep -q "^. ${add}/disk-check" /jffs/scripts/pre-mount; then
				sed -i "\~disk-check ~d" /jffs/scripts/pre-mount
				echo ". ${add}/disk-check # Added by amtm" >> /jffs/scripts/pre-mount
			fi

		elif [ "$1" = manage ]; then

			add_exclusion(){
				p_e_l
				printf " Listing compatible devices to exclude in\\n the disk check script.\\n\\n"
				i=1;did=1;noad=
				for usb_path in $(nvram show 2>/dev/null | grep '^usb_path.*=storage' | cut -d= -f1); do
					usb_dev=$(nvram get ${usb_path}_act)
					usb_manufacturer="$(nvram get ${usb_path}_manufacturer | xargs)"
					usb_product="$(nvram get ${usb_path}_product | xargs)"
					[ -z "$usb_manufacturer" ] && usb_name="$usb_product" || usb_name="$usb_manufacturer $usb_product"
					if [ "$(which blockdev)" ]; then
						thisdevsize=$(blockdev --getsize64 "/dev/$usb_dev" 2>/dev/null)
					else
						thisdevsize=$(cat /proc/partitions | grep "$usb_dev$" | awk '{print $3 * 1024}')
					fi
					if [ $? -eq 0 ]; then
						thisdevsize="$(echo $thisdevsize | awk '{ byte=$1/1000000000; printf "%.1f GB",byte }')"
						eval mounts$i=\"$usb_dev $usb_name '('$thisdevsize')'\"
						eval mtddev="\$mounts$i"

						printf " ${GN_BG} $mtddev ${NC}\\n\\n"
						for device in $(/bin/mount | grep "^/dev/${mtddev:0:3}" | awk '{print $1}') ; do
								exclusion="${GN_BG} $(/bin/mount | grep "^$device" | awk '{print $3}') ${NC} ${GY}$(blkid $device | grep -o 'UUID=".*"')${NC}"
								echo " ${did}. ${GN_BG} $device ${NC} mounted as $exclusion"
								eval exclusion$did="\$exclusion"
								noad="${noad}${did} "
								did=$((did+1))
						done
						echo
						i=$((i+1))
					fi
				done
				[ "$did" = 1 ] && show_amtm " No devices found to exclude in disk-check"
				while true;do
					printf " Select device to exclude [1-$((did-1)) e=Exit] ";read -r selection
					case "$selection" in
						e)			break;;
						[$noad])	eval exclusion="\$exclusion$selection"

									if grep -q $(echo "$exclusion" | grep -o 'UUID=".*"') "${add}"/disk-check; then
										echo
										echo "${E_BG} device is already exluded ${NC} $exclusion"
										p_e_t return
									else
										blkidExclude="$(echo $blkidExclude | sed -e "s/'//g")$(echo $exclusion | grep -o 'UUID=".*"') "
										write_dc_file
										printf "\\n added exclusion for device:\\n $exclusion\\n"
									fi
									break;;
						*)			printf "\\n input is not an option\\n\\n";;
					esac
				done
				disk_check manage
			}

			p_e_l
			printf " Disk check options\\n\\n 1. Remove Disk check script\\n"
			addexcl=;noad=
			if grep -q "^blkidExclude=" "${add}"/disk-check; then
				blkidExclude="$(grep "^blkidExclude=" ${add}/disk-check | sed -e "s/blkidExclude=//")"
				if [ "$blkidExclude" = "''" ]; then
					printf " 2. Add disk check exclusion\\n"
				else
					printf " 2. Edit disk check exclusion(s)\\n"
					addexcl=1
				fi
				noad=2
			fi

			while true; do
				printf "\\n Enter selection [1-2 e=Exit] ";read -r continue
				case "$continue" in
					1)			disk_check remove;break;;
					[$noad])	if [ "$addexcl" ]; then
									p_e_l
									printf " The following exclusions are active\\n\\n"

									for devblkid in $(echo $blkidExclude | sed -e "s/'//g") ; do
										if blkid | grep -q $devblkid; then
											device=$(blkid | grep $devblkid | awk '{print $1}' | sed 's/://')
											echo " ${GN_BG} $device ${NC} mounted as ${GN_BG} $(/bin/mount | grep "^$device" | awk '{print $3}') ${NC} ${GY}$devblkid${NC}"
										else
											echo " ${E_BG} not mounted ${NC} ${GY}$devblkid${NC}"
										fi
									done

									printf "\\n 1. Add disk check exclusion\\n 2. Remove exclusion\\n"
									while true; do
										printf "\\n Enter selection [1-2 e=Exit] ";read -r continue
										case "$continue" in
											1)		add_exclusion
													break;;
											2)		p_e_l
													printf " Remove active exclusions\\n\\n"
													i=1;noad=
													for devblkid in $(echo $blkidExclude | sed -e "s/'//g") ; do
														if blkid | grep -q $devblkid; then
															device=$(blkid | grep $devblkid | awk '{print $1}' | sed 's/://')
															echo " ${i}. ${GN_BG} $device ${NC} mounted as ${GN_BG} $(/bin/mount | grep "^$device" | awk '{print $3}') ${NC} ${GY}$devblkid${NC}"
														else
															echo " ${i}. ${E_BG} not mounted ${NC} ${GY}$devblkid${NC}"
														fi
														eval exclusion$i="\$devblkid"
														noad="${noad}${i} "
														i=$((i+1))
													done

													while true;do
														printf "\\n Select exclusion to remove [1-$((i-1)) e=Exit] ";read -r selection
														case "$selection" in
															e)			break;;
															[$noad])	eval exclusion="\$exclusion$selection"
																		blkidExclude="$(echo $blkidExclude | sed -e "s/'//g;s/$exclusion //")"
																		write_dc_file
																		printf "\\n removed exclusion for device:\\n ${GN_BG} $exclusion ${NC}\\n"
																		break;;
															*)			printf "\\n input is not an option\\n";;
														esac
													done
													disk_check manage
													break;;
											[Ee])	show_amtm menu;break;;
											*)		printf "\\n input is not an option\\n";;
										esac
									done
								else
									add_exclusion
								fi
								break;;
					[Ee])		show_amtm " Exited disk check function";;
					*)			printf "\\n input is not an option\\n";;
				esac
			done

		elif [ "$1" = remove ]; then
			p_e_l
			printf " This removes the Disk check script, log file\\n and exclusions you may have added.\\n"
			c_d
			sed -i '\~disk-check ~d' /jffs/scripts/pre-mount
			r_w_e /jffs/scripts/pre-mount
			rm -f "${add}"/disk-check
			rm -f "${add}"/amtm-disk-check.log
			blkidExclude=
			show_amtm " Disk check and log removed"
		fi
	fi
}

write_dc_file(){
	cat <<-EOF > "${add}"/disk-check
	#!/bin/sh
	# disk-check, check filesystem before partition is mounted
	# generated by amtm $version

	# Proudly coded by thelonelycoder
	# Copyright (c) 2016-2066 thelonelycoder - All Rights Reserved
	# https://www.snbforums.com/members/thelonelycoder.25480/

	# Contributors:
	# ColinTaylor: https://github.com/RMerl/asuswrt-merlin/wiki/USB-Disk-Check-at-Boot-or-Hot-Plug-(improved-version)
	# latenitetech: https://github.com/RMerl/asuswrt-merlin/wiki/USB-Disk-Check-at-Boot

	# amtm is free to use under the GNU General Public License version 3 (GPL-3.0)
	# https://opensource.org/licenses/GPL-3.0

	VERSION=$dc_version
	TAG="amtm disk-check"
	CHKLOG=${add}/amtm-disk-check.log
	CHKCMD=
	ntptimer=0
	ntptimeout=100

	blkidExclude='$blkidExclude'

	if [ "\$blkidExclude" != '' ] && echo "\$blkidExclude" | grep -q "\$(blkid \$1 | grep -o 'UUID=".*"')"; then
	    if [ "\$#" -lt 2 ]; then
	        text="\$1 exluded from check (\$(blkid \$1 | grep -o 'UUID=".*"'))"
	    else
	        text="\$1 with \$2 file system exluded from check (\$(blkid \$1 | grep -o 'UUID=".*"'))"
	    fi
	    printf "\\\n\$text\\\n" >> \$CHKLOG
	    logger -t "\$TAG" "\$text"
	    exit 0
	fi

	while [ "\$(nvram get ntp_ready)" = "0" ] && [ "\$ntptimer" -lt "\$ntptimeout" ]; do
	    ntptimer=\$((ntptimer+1))
	    sleep 1
	done

	if [ "\$ntptimer" -ge "\$ntptimeout" ]; then
	    text="NTP timeout (\${ntptimeout}s) reached, date is router default"
	    printf "\\\n\$text\\\n" >> \$CHKLOG
	    logger -t "\$TAG" "\$text"
	elif [ "\$ntptimer" -gt "0" ]; then
	    text="Waited \${ntptimer}s for NTP to sync date"
	    printf "\\\n\$(date) \$text\\\n" >> \$CHKLOG
	    logger -t "\$TAG" "\$text"
	else
	    printf "\\\n" >> \$CHKLOG
	fi

	if [ -f "\$CHKLOG" ] && [ "\$(wc -c < \$CHKLOG)" -gt "300000" ]; then
	    sed -i '1,300d' "\$CHKLOG"
	    sed -i "1s/^/Truncated log file, size over 300KB, on \$(date)\n\n/" "\$CHKLOG"
	    logger -t "\$TAG" "Truncated \$CHKLOG, size over 300KB"
	fi

	if [ "\$#" -lt 2 ]; then
	    FSTYPE=\$(fdisk -l \${1:0:8} | grep \$1 | cut -c55-65)
	    text="Firmware too old, running basic check. Probing '\$FSTYPE' on device \$1"
	    printf "\$(date) \$text\\\n" >> \$CHKLOG
	    logger -t "\$TAG" "\$text"
	    case "\$FSTYPE" in
	        Linux*)             CHKCMD="e2fsck -p" ;;
	        Win95* | FAT*)      CHKCMD="fatfsck -a" ;;
	        HPFS/NTFS)          CHKCMD="ntfsck -a" ;;
	        *)                  text="Unknown filesystem type '\$FSTYPE' on \$1 - skipping check"
	                            printf "\$(date) \$text\\\n" >> \$CHKLOG
	                            logger -t "\$TAG" "\$text" ;;
	    esac
	else
	    text="Probing '\$2' on device \$1"
	    printf "\$(date) \$text\\\n" >> \$CHKLOG
	    logger -t "\$TAG" "\$text"
	    case "\$2" in
	        "")                 text="Error reading device \$1 - skipping check"
	                            printf "\$(date) \$text\\\n" >> \$CHKLOG
	                            logger -t "\$TAG" "\$text" ;;
	        ext2|ext3|ext4)     CHKCMD="e2fsck -p" ;;
	        hfs|hfs+j|hfs+jx)   if [ -x /usr/sbin/chkhfs ]; then
	                                CHKCMD="chkhfs -a -f"
	                            elif [ -x /usr/sbin/fsck_hfs ]; then
	                                CHKCMD="fsck_hfs -d -ay"
	                            else
	                                text="Unsupported filesystem '\$2' on device \$1 - skipping check"
	                                printf "\$(date) \$text\\\n" >> \$CHKLOG
	                                logger -t "\$TAG" "\$text"
	                            fi ;;
	        ntfs)               if [ -x /usr/sbin/chkntfs ]; then
	                                CHKCMD="chkntfs -a -f"
	                            elif [ -x /usr/sbin/ntfsck ]; then
	                                CHKCMD="ntfsck -a"
	                            fi ;;
	        vfat)               CHKCMD="fatfsck -a" ;;
	        unknown)            text="\$1 Unknown filesystem (e.g. exFAT) or no partition table (e.g. blank media) - skipping check"
	                            printf "\$(date) \$text\\\n" >> \$CHKLOG
	                            logger -t "\$TAG" "\$text" ;;
	        *)                  text="Unexpected filesystem type '\$2' for \$1 - skipping check"
	                            printf "\$(date) \$text\\\n" >> \$CHKLOG
	                            logger -t "\$TAG" "\$text" ;;
	    esac
	fi

	if [ "\$CHKCMD" ]; then
	    text="Running disk check v\$VERSION, with command '\$CHKCMD' on \$1"
	    printf "\$text\\\n" >> \$CHKLOG
	    logger -t "\$TAG" "\$text"
	    \$CHKCMD "\$1" >> \$CHKLOG 2>&1
	    text="Disk check done on \$1"
	    printf "\$(date) \$text\\\n" >> \$CHKLOG
	    logger -t "\$TAG" "\$text"
	fi

	EOF

	[ ! -x "${add}"/disk-check ] && chmod 0755 "${add}"/disk-check
}

#eof
