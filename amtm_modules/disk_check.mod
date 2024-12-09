#!/bin/sh
#bof
disk_check_installed(){
	[ -z "$su" ] && atii=1
	if [ -f /jffs/scripts/pre-mount ] && ! grep -q "^. ${add}/disk_check.mod" /jffs/scripts/pre-mount; then
		if grep -q "e2fsck -p" /jffs/scripts/pre-mount; then
			rm -f "${add}"/disk_check.conf
			rm -f "${add}"/disk_check.log
			r_m disk_check.mod
			show_amtm " ! amtm removed its disk check:\\n${R} Unsupported pre-mount script found,\\n please remove this file manually${NC}"
		else
			if grep -q "disk-check" /jffs/scripts/pre-mount; then
				sed -i '/disk-check/d' /jffs/scripts/pre-mount
			fi
			echo ". ${add}/disk_check.mod;run_disk_check \$@ # Added by amtm" >> /jffs/scripts/pre-mount
		fi
	fi
	[ -f "${add}"/amtm-disk-check.log ] && mv "${add}"/amtm-disk-check.log "${add}"/disk_check.log
	if [ -f "${add}"/disk-check ]; then
		if grep -q "^blkidExclude=" "${add}"/disk-check; then
			blkidExclude="$(grep "^blkidExclude=" "${add}"/disk-check | sed -e "s/blkidExclude=//;s/'//g")"
			[ "$blkidExclude" = '' ] && blkidExclude=
			[ "$blkidExclude" ] && echo "blkidExclude='$blkidExclude '" > "${add}"/disk_check.conf
		fi
		a_m " - Disk check script updated"
		rm -f "${add}"/disk-check
	fi
	[ -f "${add}"/disk_check.log ] && dcltext="${GN_BG}dcl${NC} show log" || dcltext=
	if [ -z "$su" -a -z "$ss" ]; then
		printf "${GN_BG} dc${NC} %-9s%-19s%${COR}s\\n" "manage" "Disk check script" " $dcltext"
		if [ -f "${add}"/disk_check_err.log ]; then
			printf "    ${R_BG} Disk check found error in device ${NC}\\n"
			cat "${add}"/disk_check_err.log
			printf "${E_BG}dce${NC} %-9s%-19s%${COR}s\\n\\n" "Dismiss" "Disk check error" " $dcltext"
		fi
	fi
	case_dc(){
		disk_check_manage
		show_amtm menu
	}
}

install_disk_check(){
	p_e_l
	printf " This installs the disk-check script\\n on this router.\\n\\n It runs a filesystem check on compatible\\n USB storage devices before they are mounted\\n during (re)booting.\\n\\n"
	printf " Authors: ColinTaylor, thelonelycoder, latenitetech\\n"
	printf " github.com/RMerl/asuswrt-merlin/wiki/USB-Disk-Check-at-Boot-or-Hot-Plug-(improved-version)\\n github.com/RMerl/asuswrt-merlin/wiki/USB-Disk-Check-at-Boot\\n"
	c_d disk_check.mod
	c_j_s /jffs/scripts/pre-mount
	if grep -q "disk-check" /jffs/scripts/pre-mount; then
		sed -i '/disk-check/d' /jffs/scripts/pre-mount
	fi
	if ! grep -q "^. ${add}/disk_check.mod" /jffs/scripts/pre-mount; then
		echo ". ${add}/disk_check.mod;run_disk_check \$@ # Added by amtm" >> /jffs/scripts/pre-mount
	fi
	show_amtm " Disk check script installed.\\n The check log can be viewed with ${GN_BG}dcl${NC}"
}

disk_check_manage(){
	if [ -f /jffs/scripts/pre-mount ] && grep -q "e2fsck -p" /jffs/scripts/pre-mount; then
		am=;show_amtm " Unsupported pre-mount script found,\\n please remove file manually"
	else
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
								blkidExclude=
								if [ -f "${add}"/disk_check.conf ] && grep -q $(echo "$exclusion" | grep -o 'UUID=".*"') "${add}"/disk_check.conf; then
									echo
									echo "${E_BG} device is already exluded ${NC} $exclusion"
									p_e_t return
								else
									[ -f "${add}"/disk_check.conf ] && . "${add}"/disk_check.conf
									if [ "$blkidExclude" ]; then
										sed -i '/blkidExclude/d' "${add}"/disk_check.conf
										echo blkidExclude="'$(echo "$blkidExclude")$(echo "$exclusion" | grep -o 'UUID=".*"') '" >>"${add}"/disk_check.conf
									else
										sed -i '/blkidExclude/d' "${add}"/disk_check.conf
										echo blkidExclude="'$(echo "$exclusion" | grep -o 'UUID=".*"') '" >>"${add}"/disk_check.conf
									fi
									printf "\\n added exclusion for device:\\n $exclusion\\n"
								fi
								break;;
					*)			printf "\\n input is not an option\\n\\n";;
				esac
			done
			disk_check_manage
		}

		p_e_l
		unset addexcl blkidExclude dcErrMail
		[ -f "${add}"/disk_check.conf ] && . "${add}"/disk_check.conf
		printf " Disk check options\\n\\n 1. Remove Disk check script\\n 2. Disk check error email setting $dcErrMail\\n"
		if [ "$blkidExclude" ]; then
			printf " 3. Edit disk check exclusion(s)\\n"
			addexcl=1
		else
			printf " 3. Add disk check exclusion\\n"
		fi

		while true; do
			printf "\\n Enter selection [1-3 e=Exit] ";read -r continue
			case "$continue" in
				1)		p_e_l
						printf " This removes the Disk check script, log file\\n and exclusions you may have added.\\n"
						c_d
						sed -i '/disk_check.mod/d' /jffs/scripts/pre-mount
						r_w_e /jffs/scripts/pre-mount
						rm -f "${add}"/disk_check.conf
						rm -f "${add}"/disk_check.log
						rm -f "${add}"/disk_check_err.log
						r_m disk_check.mod
						show_amtm " Disk check and log removed"
						break;;
				2)		p_e_l
						printf " This sends an email if an error was logged\\n during the disk check.\\n\\n"
						if [ "$dcErrMail" ]; then
							printf " 1. Disable disk check error email\\n"
						else
							printf " 1. Enable disk check error email\\n"
						fi
						while true;do
							printf "\\n Enter selection [1-1 e=Exit] ";read -r selection
							case "$selection" in
								1)		if [ "$dcErrMail" ]; then
											sed -i '/dcErrMail/d' "${add}"/disk_check.conf
											r_w_e "${add}"/disk_check.conf
											show_amtm " Disk check error email disabled"
										else
											check_email_conf
											echo dcErrMail=on >>"${add}"/disk_check.conf
											show_amtm " Disk check error email enabled"
										fi
										break;;
								[Ee])	show_amtm " Exited disk check function";;
								*)		printf "\\n input is not an option\\n";;
							esac
						done
						break;;
				3)		if [ "$addexcl" ]; then
							p_e_l
							printf " The following exclusions are active:\\n\\n"

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
																if [ "$i" = 2 ]; then
																	sed -i '/blkidExclude/d' "${add}"/disk_check.conf
																	r_w_e "${add}"/disk_check.conf
																else
																	sed -i '/blkidExclude/d' "${add}"/disk_check.conf
																	echo blkidExclude="'$(echo "$blkidExclude" | sed "s|$exclusion ||")'" >>"${add}"/disk_check.conf
																fi
																printf "\\n removed exclusion for device:\\n ${GN_BG} $exclusion ${NC}\\n"
																break;;
													*)			printf "\\n input is not an option\\n";;
												esac
											done
											disk_check_manage
											break;;
									[Ee])	show_amtm menu;break;;
									*)		printf "\\n input is not an option\\n";;
								esac
							done
						else
							add_exclusion
						fi
						break;;
				[Ee])	show_amtm " Exited disk check function";;
				*)		printf "\\n input is not an option\\n";;
			esac
		done
	fi
}

run_disk_check(){
	TAG="amtm disk check"
	add=/jffs/addons/amtm
	CHKLOG="${add}"/disk_check.log
	CHKCMD=
	ntptimer=0
	ntptsync=0
	ntptimeout=10
	TZ=$(cat /etc/TZ); export TZ

	[ -f "${add}"/disk_check.conf ] && . "${add}"/disk_check.conf
	if [ "$blkidExclude" ] && echo "$blkidExclude" | grep -q "$(blkid $1 | grep -o 'UUID=".*"')"; then
		if [ "$#" -lt 2 ]; then
			text="$1 exluded from check ($(blkid $1 | grep -o 'UUID=".*"'))"
		else
			text="$1 with $2 file system exluded from check ($(blkid $1 | grep -o 'UUID=".*"'))"
		fi
		printf "\\n$text\\n" >> $CHKLOG
		logger -t "$TAG" "$text"
		exit 0
	fi

	while [ "$(nvram get ntp_ready)" = 0 ] && [ "$ntptimer" -lt "$ntptimeout" ]; do
		ntptimer=$((ntptimer+1))
		sleep 1
		if [ "$ntptsync" -lt "$ntptimeout" ]; then
			logger -t "$TAG" "trying force-sync of NTP, restarting service, sync counter at $ntptsync"
			service restart_ntpc
			ntptsync=$((ntptsync+1))
			sleep 5
		fi
	done

	if [ "$ntptimer" -ge "$ntptimeout" ]; then
		text="NTP timeout (${ntptimeout}s) reached, date is router default"
		printf "\\n$text\\n" >> $CHKLOG
		logger -t "$TAG" "$text"
	elif [ "$ntptimer" -gt 0 ]; then
		text="Waited ${ntptimer}s for NTP to sync date"
		printf "\\n$(date) $text\\n" >> $CHKLOG
		logger -t "$TAG" "$text"
	else
		printf "\\n" >> $CHKLOG
	fi

	if [ -f "$CHKLOG" ] && [ "$(wc -c < $CHKLOG)" -gt "300000" ]; then
		sed -i '1,300d' "$CHKLOG"
		sed -i "1s/^/Truncated log file, size over 300KB, on $(date)\n\n/" "$CHKLOG"
		logger -t "$TAG" "Truncated $CHKLOG, size over 300KB"
	fi

	if [ "$#" -lt 2 ]; then
		FSTYPE=$(fdisk -l ${1:0:8} | grep $1 | cut -c55-65)
		text="Firmware too old, running basic check. Probing '$FSTYPE' on device $1"
		printf "$(date) $text\\n" >> $CHKLOG
		logger -t "$TAG" "$text"
		case "$FSTYPE" in
			Linux*)             CHKCMD="e2fsck -p";;
			Win95* | FAT*)      CHKCMD="fatfsck -a";;
			HPFS/NTFS)          CHKCMD="ntfsck -a";;
			*)                  text="Unknown filesystem type '$FSTYPE' on $1 - skipping check"
								printf "$(date) $text\\n" >> $CHKLOG
								logger -t "$TAG" "$text";;
		esac
	else
		text="Probing '$2' on device $1"
		printf "$(date) $text\\n" >> $CHKLOG
		logger -t "$TAG" "$text"
		case "$2" in
			"")                 text="Error reading device $1 - skipping check"
								printf "$(date) $text\\n" >> $CHKLOG
								logger -t "$TAG" "$text";;
			ext2|ext3|ext4)     CHKCMD="e2fsck -p";;
			hfs|hfs+j|hfs+jx)   if [ -x /usr/sbin/chkhfs ]; then
									CHKCMD="chkhfs -a -f"
								elif [ -x /usr/sbin/fsck_hfs ]; then
									CHKCMD="fsck_hfs -d -ay"
								else
									text="Unsupported filesystem '$2' on device $1 - skipping check"
									printf "$(date) $text\\n" >> $CHKLOG
									logger -t "$TAG" "$text"
								fi;;
			ntfs)               if [ -x /usr/sbin/chkntfs ]; then
									CHKCMD="chkntfs -a -f"
								elif [ -x /usr/sbin/ntfsck ]; then
									CHKCMD="ntfsck -a"
								fi;;
			vfat)               CHKCMD="fatfsck -a";;
			unknown)            text="$1 Unknown filesystem (e.g. exFAT) or no partition table (e.g. blank media) - skipping check"
								printf "$(date) $text\\n" >> $CHKLOG
								logger -t "$TAG" "$text";;
			*)                  text="Unexpected filesystem type '$2' for $1 - skipping check"
								printf "$(date) $text\\n" >> $CHKLOG
								logger -t "$TAG" "$text";;
		esac
	fi

	if [ "$CHKCMD" ]; then
		lcDCL=$(wc -l < $CHKLOG)
		text="Running disk check with command '$CHKCMD' on $1"
		printf "$text\\n" >> $CHKLOG
		logger -t "$TAG" "$text"
		$CHKCMD "$1" >> $CHKLOG 2>&1
		text="Disk check done on $1"
		printf "$(date) $text\\n" >> $CHKLOG
		logger -t "$TAG" "$text"
		errDCL=$(tail -n$(($(wc -l < $CHKLOG)-lcDCL)) $CHKLOG | grep 'error')
		[ "$errDCL" ] && printf "    - $1\\n" >>"${add}"/disk_check_err.log
		if [ "$errDCL" ] && [ "$dcErrMail" = on -a "$(nvram get ntp_ready)" = 1 ]; then
			EMAIL_DIR="${add}/mail"
			. "${EMAIL_DIR}/email.conf"
			[ -z "$(nvram get odmpid)" ] && routerModel=$(nvram get productid) || routerModel=$(nvram get odmpid)
			rm -f /tmp/amtm-mail-body
			echo
			echo "Subject: amtm Disk check error $(date +"%a %b %d %Y")" >/tmp/amtm-mail-body
			echo "From: \"amtm\" <$FROM_ADDRESS>" >>/tmp/amtm-mail-body
			echo "Date: $(date -R)" >>/tmp/amtm-mail-body
			echo "To: \"$TO_NAME\" <$TO_ADDRESS>" >>/tmp/amtm-mail-body
			echo >>/tmp/amtm-mail-body
			echo " The words 'error' were encountered during the disk check, please investigate ASAP." >>/tmp/amtm-mail-body
			echo >>/tmp/amtm-mail-body
			echo "Error for device $1:" >>/tmp/amtm-mail-body
			echo "$(tail -n$(($(wc -l < $CHKLOG)-lcDCL)) $CHKLOG)" >>/tmp/amtm-mail-body
			echo >>/tmp/amtm-mail-body
			echo " Very truly yours," >>/tmp/amtm-mail-body
			echo " Your $FRIENDLY_ROUTER_NAME router (Model type $routerModel)" >>/tmp/amtm-mail-body
			echo >>/tmp/amtm-mail-body

			/usr/sbin/curl $verbose --url $PROTOCOL://$SMTP:$PORT/$SMTP \
				--mail-from "$FROM_ADDRESS" --mail-rcpt "$TO_ADDRESS" \
				--upload-file /tmp/amtm-mail-body \
				--ssl-reqd \
				--crlf \
				--user "$USERNAME:$(/usr/sbin/openssl aes-256-cbc $emailPwEnc -d -in "${EMAIL_DIR}/emailpw.enc" -pass pass:ditbabot,isoi)" $SSL_FLAG

			if [ "$?" = 0 ]; then
				logger -t "$TAG" "sent Disk check error email for device $1"
			else
				logger -t "$TAG" "Disk check error email sending failed for device $1"
			fi
			rm -f /tmp/amtm-mail*
		fi

	fi
	exit 0
}
#eof
