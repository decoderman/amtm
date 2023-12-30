#!/bin/sh
#bof
format_disk(){
	p_e_l
	printf " This (re)formats a plugged in USB storage\\n device with up to three partitions.\\n\\n"
	printf " The process erases all data and partitions\\n on the device.\\n ${E_BG} After formatting, the router will reboot. ${NC}\\n\\n"
	printf " To be on the safe side, remove all other\\n attached USB devices before continuing.\\n\\n"
	printf " Authors: ColinTaylor, thelonelycoder, Zonkd\\n"
	printf " https://github.com/RMerl/asuswrt-merlin/wiki/Disk-formatting\\n https://www.snbforums.com/threads/ext4-disk-formatting-options-on-the-router.48302/page-2#post-455723\\n"
	c_d
	select_device(){
		pts=4
		case "$(uname -m)" in
			mips)	pts=;;
		esac

		i=1;noad=
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
				if [ -z "$sdh" ]; then
					p_e_l
					echo " Select your device to format"
					echo
					echo " ${E_BG} Again, this will erase all data and ${NC}"
					echo " ${E_BG} partitions on the selected device! ${NC}"
					echo
					sdh=1
				fi
				thisdevsize="$(echo $thisdevsize | awk '{ byte=$1/1000000000; printf "%.1f GB",byte }')"
				echo " $i. ${GN_BG} $usb_dev $usb_name ($thisdevsize) ${NC}"
				eval mounts$i=\"$usb_dev $usb_name '('$thisdevsize')'\"
				noad="${noad}${i} "
				i=$((i+1))
			fi
		done

		sdh=
		if [ "$i" = 1 ]; then
			am=;show_amtm " No compatible plugged in USB storage\\n device(s) found to format"
		fi

		[ "$i" = 2 ] && devNo=1-1 || devNo="1-$((i-1))"
		while true; do
			printf "\\n Select device [$devNo e=Exit] ";read -r device
			case "$device" in
				[$noad])	break;;
				[Ee])		am=;show_amtm " Exited Format disk function";break;;
				*)			printf "\\n input is not an option\\n";;
			esac
		done

		eval mtddev="\$mounts$device"

		devtf="/dev/${mtddev:0:3}"
		if [ "$(which blockdev)" ]; then
			devtfsize=$(blockdev --getsize64 $devtf)
		else
			devtfsize=$(cat /proc/partitions | grep "$(echo ${devtf##*/})$" | awk '{print $3 * 1024}')
		fi

		if [ "$devtfsize" -gt 2199023255552 ]; then
			am=;show_amtm " Device is over 2TB and cannot be\\n formatted by amtm. Read here why:\\n https://github.com/RMerl/asuswrt-merlin.ng/wiki/Disk-formatting"
		fi

		p_e_l
		echo " You selected the following device:"
		echo
		echo " ${GN_BG} $mtddev ${NC}"
		listptd="$(/bin/mount | grep "^$devtf" | awk -v R="${E_BG}" -v NC="${NC}" '{print " "R" "$1" "NC" mounted as "R" "$3" "NC}')"
		if [ "$listptd" ]; then
			echo
			echo " This will delete ALL of the following:"
			echo
			echo "$listptd"
			echo
		else
			echo
			echo " to be formatted."
			echo
		fi

		printf " 1. Continue\\n 2. Return to device selection\\n"
		while true; do
			printf "\\n Enter selection [1-2 e=Exit] ";read -r continue
			case "$continue" in
				1)		break;;
				2)		select_device;break;;
				[Ee])	am=;show_amtm " Exited Format disk function";;
				*)		printf "\\n input is not an option\\n";;
			esac
		done
	}
	select_device

	select_file_system(){
		p_e_l
		printf " Select new filesystem$pn\\n\\n"
		printf " 2. ext2\\n"
		pto=3

		case "$1" in
			1)		recomm="(recommended)";;
			2|3)	recomm=;;
		esac

		if [ "$pts" ]; then
			pto=4
			printf " 3. ext3\\n"
			printf " 4. ext4 $recomm\\n"
		else
			printf " 3. ext3 $recomm\\n"
			printf "${GY} 4. ext4 not available on this router${NC}\\n"
		fi

		unset ptf ptn ptz
		if [ "$1" -gt 1 ]; then
			if [ -f /sbin/mkdosfs ] || [ -f /usr/sbin/mkdosfs ] ; then
				printf " 5. FAT32\\n"
				ptf=5
			else
				printf "${GY} 5. FAT32 not available on this router${NC}\\n"
			fi
			if [ -f /usr/sbin/mkntfs ] ; then
				printf " 6. NTFS\\n"
				ptn=6
			else
				printf "${GY} 6. NTFS not available on this router${NC}\\n"
			fi
			printf " 7. Don't format, just zero Partition ${GN_BG} $1 ${NC}\\n"
			pto=7;ptz=7
		fi

		while true; do
			printf "\\n Set filesystem [2-$pto] ";read -r continue
			case "$continue" in
				2)			nfs=ext2;break;;
				3)			nfs=ext3;break;;
				[$pts])		nfs=ext4;break;;
				[$ptf])		nfs=FAT32;break;;
				[$ptn])		nfs=NTFS;break;;
				[$ptz])		nfs=none;break;;
				*)			printf "\\n input is not an option\\n";;
			esac
		done
		case "$1" in
			1)	nfs1=$nfs;;
			2)	nfs2=$nfs;;
			3)	nfs3=$nfs;;
		esac
	}

	select_journalling(){
		if [ "$nfs" = "ext3" ] || [ "$nfs" = "ext4" ]; then
			p_e_l
			printf " Enable journalling$pn\\n\\n"
			printf " 1. Enable journalling (recommended)\\n 2. No journalling\\n"
			while true; do
				printf "\\n Enter selection [1-2] ";read -r continue
				case "$continue" in
					1)	journalling=on;break;;
					2)	journalling=off;break;;
					*)	printf "\\n input is not an option\\n";;
				esac
			done
			case "$1" in
				1)	journalling1=$journalling;;
				2)	journalling2=$journalling;;
				3)	journalling3=$journalling;;
			esac
		else
			case "$1" in
				1)	journalling1=off;;
				2)	journalling2=off;;
				3)	journalling3=off;;
			esac
		fi
	}

	enter_label(){
		printf "\\n Enter label: ";read -r label
		case "$label" in
			*[^a-zA-Z0-9-_]*)	printf "\\n Label contains unsupported character\\n"
								enter_label;;
		esac
		if [ "${#label}" -gt 11 ]; then
			printf "\\n Label is over the limit of 11 characters\\n"
			enter_label
		fi
	}

	select_label(){
		p_e_l
		printf " Set device label$pn\\n\\n"
		printf " 1. Set label, highly recommended\\n    especially if addon BACKUPMON is used\\n 2. No label\\n"
		while true; do
			printf "\\n Enter selection [1-2] ";read -r continue
			case "$continue" in
				1)	p_e_l
					printf " Label may only:\\n - contain letters, numbers - (dash) or _ (underscore)\\n - be 11 characters or shorter\\n"
					enter_label
					p_e_l
					echo " You entered this label: ${GN_BG} $label ${NC}"
					echo
					printf " 1. Correct, continue\\n 2. Back to label selection\\n"
					while true; do
						printf "\\n Enter selection [1-2] ";read -r continue
						case "$continue" in
							1)	break;;
							2)	label=;select_label;break;;
							*)	printf "\\n input is not an option\\n";;
						esac
					done
					break;;
				2)	label=;break;;
				*)	printf "\\n input is not an option\\n";;
			esac
		done
		case "$1" in
			1)	label1=$label;;
			2)	label2=$label;;
			3)	label3=$label;;
		esac
	}

	enter_partition_size(){
		part1s=
		case "$partitions" in
			2)	deduct=10;;
			3)	deduct=20
				if [ "$1" = 2 ]; then
					deduct=10
					part1s="- $psize1"
				fi
				;;
		esac

		echo " Valid size is: 10 - $((devmbsize-deduct $part1s)) MB"
		while true; do
			printf "\\n Enter size$pn in MB: ";read -r psize
			case $psize in
				''|*[!0-9]*|[1-9]|[!1-9]*) 	printf "\\n input is not an option\\n";;
				*) 							break;;
			esac
		done

		if [ "$psize" -gt "$((devmbsize-deduct $part1s))" ]; then
			printf "\\n input is not an option\\n\\n"
			psize=;enter_partition_size $1
		fi
	}

	set_partition_size(){
		p_e_l
		case "$1" in
			1)	printf " Common size usage info, amtm scripts\\n including these require ext* filesystem:\\n  - Diversion, installs into Entware:   250 MB\\n"
				printf "  - Scribe, installs into Entware:       50 MB\\n  - Entware, installs into partition:    20 MB\\n"
				printf "  - Skynet, installs into partition:     24 MB\\n  - Swapfile, installs into partition:  256 MB\\n"
				printf " Recommended min. size for all above:   600 MB\\n\\n\\n";;
		esac
		printf " Set size$pn on\\n\\n ${GN_BG} $mtddev (${devmbsize} MB) ${NC}\\n\\n"

		case "$partitions" in
			2)	echo " 1. Use 50% ($((devmbsize/2)) MB) of ${devmbsize} MB";;
			3)	case "$1" in
					1)	echo " 1. Use 33% ($((devmbsize/3)) MB) of ${devmbsize} MB";;
					2)	echo " 1. Use 50% ($(((devmbsize-psize1)/2)) MB) of $((devmbsize-psize1)) MB";;
				esac
				;;
		esac
		echo " 2. Set size manually in MB"
		while true; do
			printf "\\n Enter selection [1-2 e=Exit] ";read -r continue
			case "$continue" in
				1)			case "$partitions" in
								2)	psize="$((devmbsize/2))";;
								3)	psize="$((devmbsize/3))"
									[ "$1" = 2 ] && psize="$(((devmbsize-psize1)/2))"
									;;
							esac
							break;;
				2)			p_e_l
							enter_partition_size $1
							break;;
				[Ee])		am=;show_amtm " Exited Format disk function";;
				*)			printf "\\n input is not an option\\n";;
			esac
		done
	}

	confirm_partition_size(){
		p_e_l
		echo " You entered this size: ${GN_BG} $psize MB ${NC}"
		echo
		case "$partitions" in
			2)	echo " Size of Partition ${GN_BG} 1 ${NC} will be: $psize MB"
				echo " Size of Partition ${GN_BG} 2 ${NC} will be: $((devmbsize-psize)) MB";;
			3)	case "$1" in
					1)	echo " Size of Partition ${GN_BG} 1 ${NC} will be: $psize MB"
						echo " Size left for Partition ${GN_BG} 2 ${NC} and ${GN_BG} 3 ${NC} will be: $((devmbsize-psize)) MB";;
					2)	echo " Size of Partition ${GN_BG} 1 ${NC} will be: $psize1 MB"
						echo " Size of Partition ${GN_BG} 2 ${NC} will be: $psize MB"
						echo " Size of Partition ${GN_BG} 3 ${NC} will be: $((devmbsize-psize1-psize)) MB";;
				esac
				;;
		esac

		echo
		printf " 1. Correct, continue\\n 2. Back to size selection\\n"
		while true; do
			printf "\\n Enter selection [1-2] ";read -r continue
			case "$continue" in
				1)	case "$1" in
						1)	psize1=$psize;;
						2)	psize2=$psize;;
					esac
					break;;
				2)	psize=;set_partition_size $1
					confirm_partition_size $1;break;;
				*)	printf "\\n input is not an option\\n";;
			esac
		done
	}

	p_e_l
	unset partitions psize psize1 psize2 nfs1 nfs2 nfs3 label1 label2 label3 journalling1 journalling2 journalling3
	printf " Select partition(s) on device\\n\\n ${GN_BG} $mtddev ${NC}\\n\\n"
	printf " 1. One partition (recommended)\\n    ext* filesystem only\\n 2. Two partitions**\\n 3. Three partitions**\\n\\n"
	printf " *) ext2, ext3 and ext4 for newer routers\\n"
	printf " **) ext*, FAT32, NTFS or no filesystem\\n for 2nd and 3rd partition available\\n"

	while true; do
		printf "\\n Set partitions [1-3 e=Exit] ";read -r partitions
		case "$partitions" in
			1)		pn=" for\\n\\n ${GN_BG} $mtddev ${NC}"
					select_file_system 1
					case "$nfs1" in
						ext*)		select_journalling 1
									select_label 1;;
						FAT32)		select_label 1;;
						NTFS)		select_label 1;;
					esac
					break;;
			2)		devmbsize=$(echo $devtfsize | awk '{ byte=$1/1000000; printf "%d",byte }')
					pn=" for Partition ${GN_BG} 1 ${NC}"
					set_partition_size 1
					confirm_partition_size 1

					select_file_system 1
					case "$nfs1" in
						ext*)		select_journalling 1
									select_label 1;;
						FAT32)		select_label 1;;
						NTFS)		select_label 1;;
					esac

					pn=" for Partition ${GN_BG} 2 ${NC}"
					select_file_system 2
					case "$nfs2" in
						none)		;;
						ext*)		select_journalling 2
									select_label 2;;
						FAT32)		select_label 2;;
						NTFS)		select_label 2;;
					esac
					break;;
			3)		devmbsize=$(echo $devtfsize | awk '{ byte=$1/1000000; printf "%d",byte }')
					pn=" for Partition ${GN_BG} 1 ${NC}"
					set_partition_size 1
					confirm_partition_size 1

					pn=" for Partition ${GN_BG} 2 ${NC}"
					set_partition_size 2
					confirm_partition_size 2

					pn=" for Partition ${GN_BG} 1 ${NC}"
					select_file_system 1
					case "$nfs1" in
						ext*)		select_journalling 1
									select_label 1;;
						FAT32)		select_label 1;;
						NTFS)		select_label 1;;
					esac

					pn=" for Partition ${GN_BG} 2 ${NC}"
					select_file_system 2
					case "$nfs2" in
						none)		;;
						ext*)		select_journalling 2
									select_label 2;;
						FAT32)		select_label 2;;
						NTFS)		select_label 2;;
					esac

					pn=" for Partition ${GN_BG} 3 ${NC}"
					select_file_system 3
					case "$nfs3" in
						none)		;;
						ext*)		select_journalling 3
									select_label 3;;
						FAT32)		select_label 3;;
						NTFS)		select_label 3;;
					esac
					break;;
			[Ee])	am=;show_amtm " Exited Format disk function";;
			*)		printf "\\n input is not an option\\n";;
		esac
	done

	unset j1 l1 j2 l2 j3 l3
	[ "$journalling1" = "on" ] && j1=", journalling ${GN_BG} on ${NC}"
	[ "$label1" ] && l1=", label as ${GN_BG} $label1 ${NC}"

	[ "$nfs2" = none ] && f2=" (no formatting)" || f2=", format as ${GN_BG} $nfs2 ${NC}"
	[ "$journalling2" = "on" ] && j2=", journalling ${GN_BG} on ${NC}"
	[ "$label2" ] && l2=", label as ${GN_BG} $label2 ${NC}"

	[ "$nfs3" = none ] && f3=" (no formatting)" || f3=", format as ${GN_BG} $nfs3 ${NC}"
	[ "$journalling3" = "on" ] && j3=", journalling ${GN_BG} on ${NC}"
	[ "$label3" ] && l3=", label as ${GN_BG} $label3 ${NC}"

	p_e_l
	printf " Confirm formatting job for\\n\\n ${GN_BG} $mtddev ${NC}\\n"
	echo
	case "$partitions" in
		1)	echo " - ${GN_BG} One ${NC} Partition, format as ${GN_BG} $nfs1 ${NC}${j1}$l1";;
		2)	echo " - Partition ${GN_BG} 1 ${NC} $psize1 MB, format as ${GN_BG} $nfs1 ${NC}${j1}$l1"
			echo " - Partition ${GN_BG} 2 ${NC} $((devmbsize-psize1)) MB${f2}${j2}$l2";;
		3)	echo " - Partition ${GN_BG} 1 ${NC} $psize1 MB, format as ${GN_BG} $nfs1 ${NC}${j1}$l1"
			echo " - Partition ${GN_BG} 2 ${NC} $psize2 MB${f2}${j2}$l2"
			echo " - Partition ${GN_BG} 3 ${NC} $((devmbsize-psize1-psize2)) MB${f3}${NC}${j3}$l3";;
	esac

	echo
	printf " 1. Correct, format device now\\n 2. Exit format disk function\\n"
	while true; do
		printf "\\n Enter selection [1-2] ";read -r continue
		case "$continue" in
			1)		break;;
			2|[Ee])	am=;show_amtm " Exited Format disk function";;
			*)		printf "\\n input is not an option\\n";;
		esac
	done

	p_e_l
	echo " Formatting $mtddev now!"
	p_e_l

	echo " Stopping file serving services and swap file"
	service stop_nasapps >/dev/null
	sleep 1
	swapoff -a
	sleep 2
	echo
	echo " Unmounting device(s)"

	rc=0
	for mounted in $(/bin/mount | grep "^$devtf" | cut -d" " -f1); do
		umount "$mounted"
		rc=$((rc+$?))
	done

	if [ "$rc" -eq "0" ]; then
		format_device(){
			echo
			echo " Zeroing disk $mtddev"
			echo "${GY}"

			dd if=/dev/zero of=$devtf count=16065 bs=512 && sync

			sleep 2

			rm /etc/hotplug2.rules; killall hotplug2

			echo
			echo "${NC} Creating partition(s) on $mtddev${GY}"
			echo

			(
			echo o
			echo n
			echo p
			echo 1
			if [ "$partitions" -ge 2 ]; then
				echo
				echo +${psize1}M
				echo n
				echo p
				echo 2
			fi
			if [ "$partitions" = 3 ]; then
				echo
				echo +${psize2}M
				echo n
				echo p
				echo 3
			fi
			echo
			echo
			echo w
			) | fdisk $devtf

			formatting_dev(){
				echo
				case "$3" in
					ext*)		if [ "$3" = "ext2" ]; then
									echo "${NC} Formatting $1 as \"$3\"${GY}"
									echo
									mke2fs -t $3 ${devtf}${2}
								elif [ "$4" = "on" ]; then
									echo "${NC} Formatting $1 as \"$3\", enabling journalling${GY}"
									echo
									mke2fs -t $3 -O has_journal ${devtf}${2}
								else
									echo "${NC} Formatting $1 as \"$3\"${GY}"
									echo
									mke2fs -t $3 -O ^has_journal ${devtf}${2}
								fi

								if [ "$5" ]; then
									echo "${NC} Setting $1 device label \"$5\"${GY}"
									echo
									tune2fs -L "$5" ${devtf}${2}
								fi
								;;
					FAT32)		echo "${NC} Formatting $1 as \"$3\"${GY}"
								if [ "$4" ]; then
									echo "${NC} Setting $1 device label \"$4\"${GY}"
									mkdosfs -n "$4" ${devtf}${2}
								else
									mkdosfs ${devtf}${2}
								fi
								echo
								echo "${NC} Setting $1 type \"$3\"${GY}"
								if [ "$partitions" -gt 1 ]; then
									echo "t
									$2
									b
									w" | fdisk $devtf
								else
									echo "t
									b
									w" | fdisk $devtf
								fi
								;;
					NTFS)		echo "${NC} Formatting $1 as \"$3\"${GY}"
								if [ "$4" ]; then
									echo "${NC} Setting $1 device label \"$4\"${GY}"
									if /usr/sbin/mkntfs 2> /dev/null | grep -q 'v:label'; then
										/usr/sbin/mkntfs -f -v:"$4" ${devtf}${2}
									else
										/usr/sbin/mkntfs -f -L "$4" ${devtf}${2}
									fi
								else
									/usr/sbin/mkntfs -f ${devtf}${2}
								fi
								echo
								echo "${NC} Setting $1 type \"$3\"${GY}"
								if [ "$partitions" -gt 1 ]; then
									echo "t
									$2
									7
									w" | fdisk $devtf
								else
									echo "t
									7
									w" | fdisk $devtf
								fi
								;;
				esac
				echo "${NC}"
			}

			case "$partitions" in
				1)		if [ "$nfs1" != none ]; then
							formatting_dev disk 1 $nfs1 $journalling1 $label1
						else
							echo "${NC} Disk is set to not be formatted${GY}"
						fi
						;;
				2)		if [ "$nfs1" != none ]; then
							formatting_dev "Partition 1" 1 $nfs1 $journalling1 $label1
						else
							echo "${NC} Partition 1 is set to not be formatted${GY}"
						fi

						if [ "$nfs2" != none ]; then
							formatting_dev "Partition 2" 2 $nfs2 $journalling2 $label2
						else
							echo "${NC} Partition 2 is set to not be formatted${GY}"
						fi
						;;
				3)		if [ "$nfs1" != none ]; then
							formatting_dev "Partition 1" 1 $nfs1 $journalling1 $label1
						else
							echo "${NC} Partition 1 is set to not be formatted${GY}"
						fi

						if [ "$nfs2" != none ]; then
							formatting_dev "Partition 2" 2 $nfs2 $journalling2 $label2
						else
							echo "${NC} Partition 2 is set to not be formatted${GY}"
						fi

						if [ "$nfs3" != none ]; then
							formatting_dev "Partition 3" 3 $nfs3 $journalling3 $label3
						else
							echo "${NC} Partition 3 is set to not be formatted${GY}"
						fi
						;;
			esac

			ln -sf /rom/etc/hotplug2.rules /etc/hotplug2.rules; killall hotplug2
		}

		echo "amtm format disk log $(date -R)" >"${add}"/amtm-format-disk.log
		format_device | tee -a "${add}"/amtm-format-disk.log

		trap '' 2
		p_e_l
		printf "${GN_BG} Done formatting device ${NC}\\n\\n"
		echo " The log file can be viewed with ${GN_BG}fdl${NC}"
		printf "\\n${E_BG} Your router will now reboot for the changes ${NC}\\n"
		printf "${E_BG} to take effect. ${NC}\\n"
		sleep 6
		r_m format_disk.mod
		service reboot >/dev/null 2>&1 &
		exit 0
	else
		service start_nasapps >/dev/null
		echo
		echo " ${E_BG} Filesystem(s) did not unmount ${NC}"
		echo " ${E_BG} See error above for reason ${NC}"

		if [ -f /opt/bin/opkg ]; then
			open_procs(){
				echo
				echo " These processes or files are in use:"
				echo
				for mounted in $(/bin/mount | grep "^$devtf" | cut -d" " -f3); do
					lsof | grep $mounted | grep -v 'grep\|lsof'
					echo
				done
			}

			if [ "$(which lsof)" ]; then
				open_procs
			else
				p_e_l
				printf " Do you want to install Entware package lsof\\n"
				printf " to see what processes or files are in use?\\n\\n"
				printf " 1. Install lsof\\n 2. No thanks\\n"
				while true; do
					printf "\\n Enter selection [1-2] ";read -r continue
					case "$continue" in
						1)	echo "${GY}"
							opkg install lsof
							echo "${NC}"
							open_procs;break;;
						2)	echo;break;;
						*)	printf "\\n input is not an option\\n";;
					esac
				done
			fi
		fi

		p_e_t "return to menu"
		am=;show_amtm " Formatting failed:\\n Filesystem(s) did not unmount"
	fi
}
#eof
