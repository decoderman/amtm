#!/bin/sh
#bof
setup_Entware(){
	NAME="amtm Entware installer"
	c_e_folder(){
		if [ "$(/opt/bin/find /tmp/mnt/*/ -maxdepth 1 -type d -name "entware*" 2>/dev/null | wc -l)" -gt 1 ]; then
			/opt/bin/find /tmp/mnt/*/ -maxdepth 1 -type d -name "entware*" | while read fdir; do
				if [ "$fdir" != "$(readlink /tmp/opt)" ] && [ -f "$fdir/bin/opkg" ]; then
					mv "$fdir" "$(dirname "$fdir")/old.$(basename "$fdir")"
				fi
			done
		fi
	}

	write_jffsfile(){
		echo " Checking /jffs/scripts entries"

		c_j_s /jffs/scripts/post-mount
		t_f /jffs/scripts/post-mount
		if ! grep -q ". /jffs/addons/diversion/mount-entware.div" /jffs/scripts/post-mount; then
			# remove old entries if found
			sed -i '/post-mount.div/d' /jffs/scripts/post-mount >/dev/null
			sed -i '/mount-entware.div/d' /jffs/scripts/post-mount >/dev/null
			echo ". /jffs/addons/diversion/mount-entware.div # Added by amtm" >>/jffs/scripts/post-mount
			echo " post-mount entry added"
		else
			echo " OK post-mount"
		fi

		c_j_s /jffs/scripts/services-stop
		t_f /jffs/scripts/services-stop
		if ! grep -q "/opt/etc/init.d/rc.unslung stop" /jffs/scripts/services-stop; then
			echo "/opt/etc/init.d/rc.unslung stop # Added by amtm" >>/jffs/scripts/services-stop
			echo " services-stop entry added"
		else
			echo " OK services-stop"
		fi

		mkdir -p /jffs/addons/diversion
		if [ ! -f /jffs/addons/diversion/mount-entware.div ]; then
			g_m mount-entware.div new /jffs/addons/diversion
			echo " mount-entware.div downloaded"
		else
			echo " OK mount-entware.div"
		fi
		[ ! -x /jffs/addons/diversion/mount-entware.div ] && chmod 0755 /jffs/addons/diversion/mount-entware.div
	}

	check_device(){

		check_device_nok(){
		rm -rf "$1/rw_test"
		am=;show_amtm " $1\\n has not passed the device test.\\n Check if device is read and writable"
		}

		mkdir -p $1/rw_test
		if [ -d "$1/rw_test" ]; then
			echo "rwTest=OK" >"$1/rw_test/rw_test.txt"
			if [ -f "$1/rw_test/rw_test.txt" ]; then
				. "$1/rw_test/rw_test.txt"
				if [ "$rwTest" = "OK" ]; then
					rm -rf "$1/rw_test"
				else
					check_device_nok "$1"
				fi
			else
				check_device_nok "$1"
			fi
		else
			check_device_nok "$1"
		fi
	}

	case "$(uname -m)" in
		mips)		PART_TYPES='ext2|ext3'
					INST_URL='http://pkg.entware.net/binaries/mipsel/installer/installer.sh'
					entVer="Entware (mipsel)";;
		armv7l)		PART_TYPES='ext2|ext3|ext4'
					INST_URL='http://bin.entware.net/armv7sf-k2.6/installer/generic.sh'
					entVer="Entware (armv7)";;
		aarch64)	PART_TYPES='ext2|ext3|ext4'
					INST_URL='http://bin.entware.net/aarch64-k3.10/installer/generic.sh'
					entVer="Entware (aarch64)";;
		*)			am=;show_amtm " $(uname -m) is an unsupported platform to install Entware on";;
	esac

	p_e_l
	echo " Running pre-install checks"

	if [ -L /tmp/opt ]; then
		# dl master check
		if [ "$(nvram get apps_mounted_path)" ] && [ -d "$(nvram get apps_mounted_path)/$(nvram get apps_install_folder)" ]; then
			if [ -f /opt/etc/init.d/S50downloadmaster ]; then
				echo "${E_BG} Download Master appears to be installed ${NC}"
				echo " $(nvram get apps_mounted_path)/$(nvram get apps_install_folder)"
				echo " Entware and Download Master cannot be installed at the same time."
				echo " Uninstall Download Master in 'USB Application' first."

				echo
				echo "${E_BG} Correct above error first before installing Entware ${NC}"
				p_e_t acknowledge
				am=;show_amtm " Correct error first before installing Entware"
			else
				echo "${E_BG} Correcting invalid Entware or Download Master settings ${NC}"
				if [ -L "/tmp/opt" ]; then
					rm -f /tmp/opt 2> /dev/null
					rm -f /opt 2> /dev/null
				fi
				if [ -d "$(nvram get apps_mounted_path)/$(nvram get apps_install_folder)" ]; then
					rm -rf "$(nvram get apps_mounted_path)/$(nvram get apps_install_folder)"
				fi
				nvram set apps_mounted_path=
				nvram set apps_dev=
				nvram set apps_state_autorun=
				nvram set apps_state_enable=
				nvram set apps_state_install=
				nvram set apps_state_switch=
				nvram commit
			fi
		else
			if [ -L /tmp/opt ]; then
				rm -f /tmp/opt 2> /dev/null
				rm -f /opt 2> /dev/null
			fi
			echo "${E_BG} Corrected invalid Entware symlink ${NC}"
		fi
	fi

	echo " Pre-install checks passed"

	p_e_l
	echo " Select device to install Entware to"
	echo

	i=1;noad=
	for mounted in $(/bin/mount | grep -E "$PART_TYPES" | cut -d" " -f3); do
		echo " $i. ${GN}$mounted${NC}"
		eval mounts$i="$mounted"
		noad="${noad}${i} "
		i=$((i+1))
	done

	if [ "$i" = 1 ]; then
		r_m entware_setup.mod
		am=;show_amtm " No compatible device(s) found to install\\n Entware on. A USB storage device formatted\\n with one of these file systems is required:\\n $(echo $PART_TYPES | sed -e 's/|/, /g')\\n Use Format disk (fd) to format FAT or NTFS\\n formatted devices to ext*"
	fi

	[ "$i" = 2 ] && devNo=1-1 || devNo="1-$((i-1))"
	while true; do
		printf "\\n Select device [$devNo e=Exit] ";read -r device
		case "$device" in
			[$noad])	break;;
			[Ee])		r_m entware_setup.mod;am=;show_amtm " Exited Entware install function";break;;
			*)			printf "\\n input is not an option\\n";;
		esac
	done

	echo
	eval entDev="\$mounts$device"

	echo " Running device checks on $entDev"

	check_device "$entDev"

	echo " Device checks passed"

	if [ "$(uname -m)" = "aarch64" ]; then
		p_e_l
		printf " Select Entware version\\n\\n"
		printf " This router can run 32-bit or 64-bit Entware.\\n\\n"
		printf " 1. install 64-bit Entware (recommended)\\n"
		printf " 2. install 32-bit Entware\\n"
		while true; do
			printf "\\n Enter your selection [1-2] ";read -r eversion
			case "$eversion" in
				1)	INST_URL='http://bin.entware.net/aarch64-k3.10/installer/generic.sh'
					entVer="Entware (aarch64)";break;;
				2)	INST_URL='http://bin.entware.net/armv7sf-k3.2/installer/generic.sh'
					entVer="Entware (armv7)";break;;
				*) 	printf "\\n input is not an option\\n";;
			esac
		done
	fi

	p_e_l
	echo " amtm is now ready to install Entware to"
	echo
	echo " ${GN_BG} $entDev ${NC}"
	echo
	printf " 1. Continue\\n 2. Return to device selection\\n"
	while true; do
		printf "\\n Enter selection [1-2 e=Exit] ";read -r continue
		case "$continue" in
			1)			break;;
			2)			echo;setup_Entware;break;;
			[Ee])		r_m entware_setup.mod;am=;show_amtm " Exited Entware install function";;
			*)			printf "\\n input is not an option\\n";;
		esac
	done

	p_e_l
	cd /tmp

	entPath="$entDev/entware"
	[ -d "$entPath" ] && rm -rf "$entPath"

	echo " Creating install directory at $entPath"

	mkdir -p "$entPath"

	ln -sf "$entPath" /tmp/opt

	echo
	echo " Installing $entVer, using external script"
	echo "${GY}"
	wget --timeout=10 --tries=3 --retry-connrefused -qO - "$INST_URL" | sh
	echo "${NC}"

	if [ -f /opt/bin/opkg ]; then
		ENTURL="$(awk 'NR == 1 {print $3}' /opt/etc/opkg.conf)"
		[ "$(echo $ENTURL | grep 'aarch64\|armv7\|mipsel')" ] && entVersion="Entware (${ENTURL##*/})"
		[ -z "$entVersion" ] && entVersion=$entVer
		c_e_folder
		cd
		write_jffsfile
		sleep 2
		r_m entware_setup.mod
		am=;show_amtm " $entVersion install successful"
	else
		cd
		r_m entware_setup.mod
		am=;show_amtm " $entVer install failed"
	fi
}


install_Entware(){
	p_e_l
	echo " This installs Entware - the ultimate Software repository"
	echo " on this router."
	echo
	echo " If you plan to install Diversion on this"
	echo " router, install Diversion first."
	echo " It includes the installation of Entware."
	echo
	echo " Author: thelonelycoder"
	p_e_l;while true;do printf " Continue? [1=Yes e=Exit] ";read -r continue;case "$continue" in 1)setup_Entware;break;;[Ee])r_m entware_setup.mod;am=;show_amtm menu;break;;*)printf "\\n input is not an option\\n\\n";;esac done;
}
#eof
