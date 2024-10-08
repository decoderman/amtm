#!/bin/sh
#bof
check_swap(){
	writeswaploc(){
		if ! grep -q 'do-not-check-swap' /jffs/scripts/post-mount 2> /dev/null; then
			[ -f /jffs/scripts/post-mount ] && sed -i '\~swapon ~d' /jffs/scripts/post-mount
			c_j_s /jffs/scripts/post-mount
			sed -i "1a swapon $swl # Added by amtm" /jffs/scripts/post-mount
			swapon "$swl" 2> /dev/null
			swsize=$(du -h "$swl" | awk '{print $1}')
		fi
	}

	remove_swap_entries(){
		if grep -q 'swapon.*\.' /jffs/scripts/post-mount && ! grep -q 'do-not-check-swap' /jffs/scripts/post-mount; then
			sed -i '\~swapon ~d' /jffs/scripts/post-mount
			swtxt=" No swap file found, reference removed in\\n /jffs/scripts/post-mount"
			am=;r_m swap.mod
		fi
	}

	if [ "$(echo "$swl" | wc -l)" -gt 1 ]; then
		mpsw=1
		swtxt=" Multiple swap files found, only one file is\\n supported. Enter sw to delete."
	elif [ -f "$swl" ]; then
		if ! grep -qF "$swl" /proc/swaps; then
			swapon "$swl" 2> /dev/null
			swtxt=" Swap file re-enabled"
		fi
		swsize=$(du -h "$swl" | awk '{print $1}')
	elif [ "$swl" ] && [ "$swl" = "$(sed -n '2p' /proc/swaps | awk '{print $1}')" ]; then
		swpsize="$((($(sed -n '2p' /proc/swaps | awk '{print $3}') + (1024 + 1)) / 1024))"
	elif [ -f /jffs/configs/fstab ] && grep -qF "swap" /jffs/configs/fstab && [ "$(wc -l < /proc/swaps)" -eq 2 ]; then
		swpsize="$((($(sed -n '2p' /proc/swaps | awk '{print $3}') + (1024 + 1)) / 1024))"
		swl="$(sed -n '2p' /proc/swaps | awk '{print $1}')"
	elif [ "$swl" ]; then
		swl="$(find /tmp/mnt/*/$(basename $swl) 2> /dev/null)"
		if [ -f "$swl" ]; then
			writeswaploc
			swtxt=" Swap file path corrected in\\n /jffs/scripts/post-mount"
		else
			swl="$(find /tmp/mnt/*/myswap.swp 2> /dev/null)"
			if [ -f "$swl" ]; then
				writeswaploc
				swtxt=" Added missing swap file entry to\\n /jffs/scripts/post-mount"
			elif [ "$(wc -l < /proc/swaps)" -eq 2 ]; then
				swl="$(sed -n '2p' /proc/swaps | awk '{print $1}')"
				if [ -f "$swl" ]; then
					writeswaploc
					swtxt=" Added missing swap file entry to\\n /jffs/scripts/post-mount"
				else
					remove_swap_entries
				fi
			else
				remove_swap_entries
			fi
		fi
	else
		swl="$(find /tmp/mnt/*/myswap.swp 2> /dev/null)"
		if [ "$(echo "$swl" | wc -l)" -gt 1 ]; then
			mpsw=1
			swtxt=" Multiple swap files found, only one file is\\n supported. Enter sw to delete."
		elif [ -f "$swl" ]; then
			writeswaploc
			swtxt=" Added missing swap file entry to\\n /jffs/scripts/post-mount"
		elif [ "$(wc -l < /proc/swaps)" -eq 2 ]; then
			swl="$(sed -n '2p' /proc/swaps | awk '{print $1}')"
			if [ -f "$swl" ]; then
				writeswaploc
				swtxt=" Added missing swap file entry to\\n /jffs/scripts/post-mount"
			else
				remove_swap_entries
			fi
		elif [ "$swl" ] || [ "$(wc -l < /proc/swaps)" -gt 2 ]; then
			mpsw=1
			swtxt=" Multiple swap files found, only one file is\\n supported. Enter sw to delete."
		fi
	fi
}

manage_swap(){
	if [ -f /jffs/scripts/post-mount ] && grep -q 'do-not-check-swap' /jffs/scripts/post-mount; then
		p_e_l
		printf " Found \"do-not-check-swap\" entry in\\n /jffs/scripts/post-mount. Diversion and amtm\\n will not auto-correct paths.\\n"
	fi
	if [ "$1" = create ]; then
		p_e_l
		printf " This creates a Swap file.\\n\\n A Swap file helps when the router runs\\n out of memory (RAM).\\n\\n"
		printf " Skynet requires a 2GB swap file while\\n Diversion highly recommends to create one\\n for large(er) blocking lists.\\n\\n Author: thelonelycoder\\n"
		if [ ! -f /opt/bin/opkg ]; then
			printf "\\n Note: If you plan to install the\\n Entware ${GN_BG} ep${NC} repository on this router\\n"
			printf " install it first, this will allow to\\n show progress on the swap file creation.\\n"
		fi
		p_e_l;while true;do printf " Continue? [1=Yes e=Exit] ";read -r continue;case "$continue" in 1)echo;break;;[Ee])r_m swap.mod;am=;show_amtm menu;break;;*)printf "\\n input is not an option\\n\\n";;esac done;

		while true; do
			case "$continue" in
				1)	p_e_l
					if [ -f "$swl" -a "$deleteSwap" ]; then
						sync; echo 3 > /proc/sys/vm/drop_caches
						swapoff "$swl"
						rm "$swl"
					fi
					deleteSwap=

					echo " Listing compatible device(s) for a Swap file"
					echo
					i=1;noad=
					for mounted in $(/bin/mount | grep -E "ext2|ext3|ext4" | cut -d" " -f3); do
						echo " $i. ${GN_BG}$mounted${NC}"
						eval mounts$i=\"$mounted\"
						noad="${noad}${i} "
						i=$((i+1))
					done

					if [ "$i" = 1 ]; then
						r_m swap.mod
						am=;show_amtm " No compatible device available to create\\n a swap file"
					fi

					[ "$i" = 2 ] && devNo=1-1 || devNo="1-$((i-1))"
					while true; do
						printf "\\n Select device [$devNo e=Exit] ";read -r device
						case "$device" in
							[$noad])	break;;
							[Ee])		r_m swap.mod
										am=;show_amtm " Exited Swap file function";break;;
							*)			printf "\\n input is not an option\\n";;
						esac
					done

					eval swapDevice="\$mounts$device"

					p_e_l
					echo " creating Swap file on ${GN_BG}${swapDevice}${NC}"
					while true; do
						printf "\\n Continue? [1=Yes e=Exit] ";read -r swaps
						case "$swaps" in
							1)		p_e_l
									echo " Select a Swap file size"
									echo
									echo " 1. 250 MB"
									echo " 2. 500 MB"
									echo " 3.   1 GB"
									echo " 4.   2 GB (recommended, required for Skynet)"
									echo " 5.   5 GB"
									echo " 6.  10 GB"

									while true; do
										printf "\\n Enter size [1-6 e=Exit] ";read -r size
										case "$size" in
											1)	swsize=256000; swtext="250 MB"; break;;
											2)	swsize=512000; swtext="500 MB"; break;;
											3)	swsize=1048576; swtext="1 GB"; break;;
											4)	swsize=2097152; swtext="2 GB"; break;;
											5)	swsize=5242880; swtext="5 GB"; break;;
											6)	swsize=10485760; swtext="10 GB"; break;;
										[Ee])	show_amtm menu;break;;
											*)	printf "\\n input is not an option\\n";;
										esac
									done

									if [ "$(df "$swapDevice" | xargs | awk '{print $11}')" -le "$swsize" ]; then
										p_e_l
										echo " Not enough free space available on:"
										echo " $swapDevice"
										p_e_t "select another device or smaller swap file size"
										manage_swap create
									fi

									if [ -f /opt/bin/opkg ] && [ ! -f /opt/bin/dd ]; then
										echo
										echo " Installing Entware package 'coreutils-dd'"
										echo " for swap file creation progress."
										echo "${GY}"
										opkg update
										opkg install coreutils-dd
										echo "${NC}"
									fi

									p_e_l
									echo " Creating ${GN_BG} $swtext ${NC} Swap file,"
									echo " this will take some time..."
									echo
									if [ -f /opt/bin/dd ]; then
										/opt/bin/dd if=/dev/zero of="$swapDevice/myswap.swp" bs=1k count="$swsize" status=progress
									else
										/bin/dd if=/dev/zero of="$swapDevice/myswap.swp" bs=1k count="$swsize"
									fi
									mkswap "$swapDevice/myswap.swp"
									swapon "$swapDevice/myswap.swp"
									nvram set usb_idle_timeout=0
									nvram commit

									c_j_s /jffs/scripts/post-mount
									if grep -q '^swapon.*\.' /jffs/scripts/post-mount; then
										sed -i '/swapon/d' /jffs/scripts/post-mount >/dev/null
									fi
									sed -i "1a swapon $swapDevice/myswap.swp # Added by amtm" /jffs/scripts/post-mount

									c_j_s /jffs/scripts/unmount
									if ! grep -q "^swapoff -a" /jffs/scripts/unmount; then
										sed -i '/swapoff/d' /jffs/scripts/unmount >/dev/null
										echo "swapoff -a 2>/dev/null # Added by amtm" >> /jffs/scripts/unmount
									fi

									show_amtm " Swap file created and is active at\\n $(echo "${swapDevice#/tmp}")/myswap.swp";break;;
							[Ee])	show_amtm menu;break;;
							*)		printf "\\n input is not an option\\n";;
						esac
					done;break;;
			 [Ee])	show_amtm menu;break;;
				*)	printf "\\n input is not an option\\n";;
			esac
		done

	elif [ "$1" = manage ]; then
		p_e_l
		printf " Swap file options\\n\\n"
		printf " A $swsize Swap file was found at:\\n ${GN}$swl${NC}\\n"
		if ! grep -q "^swapoff -a" /jffs/scripts/unmount; then
			sed -i '/swapoff/d' /jffs/scripts/unmount >/dev/null
			echo "swapoff -a 2>/dev/null # Added by amtm" >> /jffs/scripts/unmount
			printf "\\n Entry in /jffs/scripts/unmount corrected.\\n"
		fi
		printf "\\n 1. Delete the Swap file\\n 2. Change Swap file size\\n"

		while true; do
			printf "\\n Enter selection [1-2 e=Exit] ";read -r continue
			case "$continue" in
				1)		sed -i '/swapoff/d' /jffs/scripts/unmount >/dev/null
						if [ -f "$swl" ]; then
							sync; echo 3 > /proc/sys/vm/drop_caches
							swapoff "$swl"
							rm "$swl"
							sed -i '\~swapon ~d' /jffs/scripts/post-mount
							r_m swap.mod
							show_amtm " Swap file deleted:\\n $swl"
						else
							sed -i '\~swapon ~d' /jffs/scripts/post-mount
							show_amtm " No Swap file found at\\n $swl"
						fi
						break;;
				2)		deleteSwap=1
						manage_swap create
						break;;
				[Ee])	show_amtm menu;break;;
				*)		printf "\\n input is not an option\\n";;
			esac
		done

	elif [ "$1" = multidelete ]; then
		p_e_l
		echo " Multiple swap files found, only one file is"
		echo " supported."
		echo

		findswap=$(find /tmp/mnt/*/*.swp 2> /dev/null)
		i=1
		if [ "$findswap" ]; then
			for swapfile in $findswap; do
				echo " $i. ${GN}$swapfile${NC} $(du -h "$swapfile" | awk '{print $1}')"
				eval swapfile$i="$swapfile"
				noad="${noad}${i} "
				i=$((i+1))
			done
			echo
		fi
		if [ "$(wc -l < /proc/swaps)" -ge 2 ]; then
			echo " Found in /proc/swaps, delete manually:"
			echo
			cat /proc/swaps
		fi
		if [ "$i" -gt 1 ]; then
			while true; do
				printf "\\n Enter swap file to delete [1-$((i-1)) e=Exit] ";read -r continue
				case "$continue" in
					[$noad])	sync; echo 3 > /proc/sys/vm/drop_caches
								swapoff -a
								eval rmswap="\$swapfile$continue"
								rm "$rmswap"
								show_amtm menu
								break;;
					[Ee])		show_amtm menu;break;;
					*)			printf "\\n input is not an option\\n";;
				esac
			done
		else
			p_e_t "return to menu"
			show_amtm menu
		fi
	fi
}
#eof
