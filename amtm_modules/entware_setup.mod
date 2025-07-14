#!/bin/sh
#bof
setup_Entware(){

	check_device(){

		check_device_nok(){
		rm -rf "$1/rw_test"
		r_m entware_setup.mod;am=;show_amtm " $1\\n has not passed the device test.\\n Check if device is read and writable"
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

	check_device_free(){
		minsize=71680
		maxsize=102400
		free="$(df $1 | xargs | awk '{print $11}')"
		if [ "$free" -le "$minsize" ]; then
			echo " Not enough free space available on"
			echo " $1"
			echo
			echo " Required Entware: $(( ${minsize} / 1024)) - $(( ${maxsize} / 1024)) MB"
			echo " Free space on $1: $(( ${free} / 1024)) MB"
			echo
			p_e_t aknowledge
			r_m entware_setup.mod;am=;show_amtm " Not enough free space available on\\n $1."

		elif [ "$free" -gt "$minsize" ] && [ "$free" -le "$maxsize" ]; then
			echo " Device $1"
			echo " has low free space available."
			echo
			echo " Required Entware: $(( ${minsize} / 1024)) - $(( ${maxsize} / 1024)) MB"
			echo " Free space on $1: $(( ${free} / 1024)) MB"
			echo
			echo " Entware will work if the free space is"
			echo " close to $(( ${maxsize} / 1024)) MB, but might not if it is"
			echo " closer to $(( ${minsize} / 1024)) MB."
			echo
			p_e_t aknowledge
		fi
	}

	useBackport=
	case "$(uname -m)" in
		mips)		PART_TYPES='ext2|ext3'
					INST_URL='https://pkg.entware.net/binaries/mipsel/installer/installer.sh'
					entVer="Entware (mipsel)"
					availEntVer='pkg\.entware\.net\/binaries\/mipsel\|maurerr\.github\.io'
					useBackport=on;;
		armv7l)		PART_TYPES='ext2|ext3|ext4'
					if [ "$(v_c $(uname -r))" -ge "$(v_c 3.2)" ]; then
						INST_URL='armv7sf-k3.2/installer/generic.sh'
						entVer="Entware (armv7sf-k3.2)"
						availEntVer=armv7
					else
						INST_URL='armv7sf-k2.6/installer/generic.sh'
						entVer="Entware (armv7sf-k2.6)"
						availEntVer=armv7
						useBackport=on
					fi;;
		aarch64)	PART_TYPES='ext2|ext3|ext4'
					INST_URL='aarch64-k3.10/installer/generic.sh'
					entVer="Entware (aarch64)"
					availEntVer='armv8\|aarch64';;
		*)			r_m entware_setup.mod;am=;show_amtm " $(uname -m) is an unsupported platform to install Entware on";;
	esac

	p_e_l
	echo " Running pre-install checks"

	if [ -L /tmp/opt ]; then
		# dl master check, installs into asusware.arm folder
		if [ "$(nvram get apps_mounted_path)" ] && [ -d "$(nvram get apps_mounted_path)/$(nvram get apps_install_folder)" ]; then
			if [ -f /opt/etc/init.d/S50downloadmaster ]; then
				echo "${E_BG} Download Master appears to be installed ${NC}"
				echo " $(nvram get apps_mounted_path)/$(nvram get apps_install_folder)"
				echo " Entware and Download Master cannot be installed at the same time."
				echo " Uninstall Download Master in 'USB Application' first."

				echo
				echo "${E_BG} Correct above error first before installing Entware ${NC}"
				p_e_t acknowledge
				r_m entware_setup.mod;am=;show_amtm " Correct error first before installing Entware"
			else
				echo "${E_BG} Correcting invalid Download Master settings ${NC}"
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
				nvram set apps_swap_enable=
				nvram commit
			fi
		else
			if [ -L /tmp/opt ]; then
				rm -f /tmp/opt 2> /dev/null
				rm -f /opt 2> /dev/null
			fi
			echo "${E_BG} Corrected orphaned Entware symlink ${NC}"
		fi
	fi

	echo " Pre-install checks passed"

	if [ "$useBackport" ]; then
		p_e_l
		printf " The Entware repository for your router no\\n longer receives updates from the Entware team.\\n\\n"
		case "$(uname -m)" in
			mips)	printf " However, there's an Entware backports repository available\\n by @maurer with updates for some packages.\\n For more info see here:\\n"
					printf " snbforums.com/threads/mips-entware-backports-repo-entware-ng-reloaded.49468/\\n\\n";;
			armv7l)	printf " However, there's an Entware backports repository available\\n by @garycnew with updates for some packages.\\n For more info see here:\\n"
					printf " snbforums.com/threads/entware-armv7sf-k2-6-eos.89032/\\n\\n";;
		esac
		printf " Be aware that some of these backported packages\\n may not be compatible or functional on your router.\\n\\n"
		printf " The use of the Entware backports repository can be\\n enabled at any time after installation.\\n\\n"
		printf " 1. Use original Entware repository only.\\n"
		printf " 2. Use Entware backports repository in parallel.\\n"

		while true; do
			printf "\\n Enter selection [1-2 e=Exit] ";read -r continue
			case "$continue" in
				1)			useBackport=;break;;
				2)			break;;
				[Ee])		r_m entware_setup.mod;am=;show_amtm " Exited Entware install function";;
				*)			printf "\\n input is not an option\\n";;
			esac
		done
	fi

	p_e_l
	echo " Select device to install Entware to"
	echo

	i=1;unset noad usePreviousEntware
	for mounted in $(/bin/mount | grep -E "$PART_TYPES" | cut -d" " -f3); do
		echo " $i. ${GN}$mounted${NC}"
		if [ -f "$mounted/entware/bin/opkg" ] && grep -q "$availEntVer" "$mounted/entware/etc/opkg.conf"; then
			usePrevOK=1
			if grep -q 'maurerr.github.io\|garycnew.github.io' "$mounted/entware/etc/opkg.conf" && [ -z "$useBackport" ]; then
				usePrevOK=
			fi
			[ "$usePrevOK" ] && printf "    Found compatible previous Entware\\n    installation on this device.\\n"
		fi
		eval mounts$i="$mounted"
		noad="${noad}${i} "
		i=$((i+1))
	done

	if [ "$i" = 1 ]; then
		r_m entware_setup.mod
		am=;show_amtm " No compatible device(s) found to install\\n Entware on.\\n\\n A USB storage device formatted with one of\\n these file systems is required:\\n $(echo $PART_TYPES | sed -e 's/|/, /g')\\n\\n Use Format disk (fd) in amtm to format\\n devices to ext*"
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

	check_device_free "$entDev"

	echo " Device checks passed"


	if [ -f "$entDev/entware/bin/opkg" -a "$usePrevOK" ] && grep -q "$availEntVer" "$entDev/entware/etc/opkg.conf"; then
		p_e_l
		echo " ${GN_BG} $entDev ${NC}"
		printf "\\n The above device contains a compatible\\n previous $entVer\\n installation, select what to do.\\n\\n"
		printf " 1. Reuse compatible Entware installation.\\n    This requires rebooting this router\\n    after completion.\\n"
		printf "    Entware will be reinstalled to ensure\\n    all core files are present.\\n\\n"
		printf " 2. New Entware installation\\n"
		printf " 3. Return to device selection\\n"
		while true; do
			printf "\\n Enter selection [1-3 e=Exit] ";read -r continue
			case "$continue" in
				1)			usePreviousEntware=1;break;;
				2)			break;;
				3)			echo;setup_Entware;break;;
				[Ee])		r_m entware_setup.mod;am=;show_amtm " Exited Entware install function";;
				*)			printf "\\n input is not an option\\n";;
			esac
		done
	fi

	if [ -z "$usePreviousEntware" ] && [ "$(uname -m)" = "aarch64" ]; then
		p_e_l
		printf " Select Entware version\\n\\n"
		printf " This router can run 32-bit or 64-bit Entware.\\n\\n"
		printf " 1. install 64-bit Entware (recommended)\\n"
		printf " 2. install 32-bit Entware\\n"
		while true; do
			printf "\\n Enter selection [1-2] ";read -r eversion
			case "$eversion" in
				1)	INST_URL='aarch64-k3.10/installer/generic.sh'
					entVer="Entware (aarch64)";break;;
				2)	INST_URL='armv7sf-k3.2/installer/generic.sh'
					entVer="Entware (armv7sf-k3.2)";break;;
				*) 	printf "\\n input is not an option\\n";;
			esac
		done
	fi

	testEntwareServer() {
		p_e_l
		printf " Testing Entware servers availability\\n\\n"
		es=
		entServer='bin.entware.net Primary¦server¦by¦Entware¦team¦(recommended) primary¦server
		entware.diversion.ch Mirror¦by¦thelonelycoder mirror¦by¦thelonelycoder
		mirrors.cernet.edu.cn/entware Multiple¦mirrors¦by¦CERNET¦(China¦Education¦and¦Research¦Network) mirrors¦by¦CERNET'
		IFS='
		'
		set -f
		for i in $entServer; do
			i1=$(echo $i | awk '{print $1}')
			if curl -IsL https://$i1 | head -n 1 | grep 'OK\|Found' >/dev/null; then

				c_url https://$i1/$(echo $INST_URL | cut -d/ -f1)/Packages.gz -o /tmp/Packages.gz
				if [ -s /tmp/Packages.gz ]; then
					es=$((es+1))
					printf " ${es}. %-$(( 22 + $COR ))s%s\\n" "${GN}$i1${NC}" "- $(echo $i | awk '{print $2}' | sed 's/¦/ /g')"
					eval entServers$es="$i1"
				else
					printf "    %-$(( 22 + $COR ))s%s\\n" "${R}$i1${NC}" "Packages.gz download failed, $(echo $i | awk '{print $3}' | sed 's/¦/ /g')"
				fi
				rm -f /tmp/Packages.gz
			else
				printf "    %-$(( 22 + $COR ))s%s\\n" "${R}$i1${NC}" "failed, $(echo $i | awk '{print $3}' | sed 's/¦/ /g')"
			fi
		done
		set +f
		IFS=

		selectServer() {
			if [ -z "$es" ]; then
				printf "\\n Sorry, no Entware servers responded.\\n"
				p_e_t return
				show_amtm " Sorry, no Entware servers responded."
			else
				printf "\\n Select Entware server to use [1-$es e=Exit] ";read -r selection
				case "$selection" in
					1|2|3) 	if [ "$selection" -ge 1 ] && [ "$selection" -le "$es" ]; then
								eval entServer="\$entServers$selection"
								INST_URL="https://$entServer/$INST_URL"
							else
								printf "\\n input is not an option\\n"
								selectServer
							fi
							;;
					[Ee])	r_m entware_setup.mod;am=;show_amtm " Exited Entware install function";;
					*)		printf "\\n input is not an option\\n"
							selectServer
							;;
				esac
			fi
		}
		selectServer
	}

	if [ "$(uname -m)" != mips ] ; then
		testEntwareServer
	else
		p_e_l
		printf " Testing Entware server availability\\n\\n"
		entServer=pkg.entware.net
		if curl -IsL https://$entServer | head -n 1 | grep 'OK\|Found' >/dev/null; then
			c_url https://$entServer/binaries/mipsel/Packages.gz -o /tmp/Packages.gz
			if [ -s /tmp/Packages.gz ]; then
				echo " ${GN}$entServer${NC} responded"
			else
				r_m entware_setup.mod
				am=;show_amtm " Entware ${R}$entServer${NC} failed"
			fi
			rm -f /tmp/Packages.gz
		else
			r_m entware_setup.mod
				am=;show_amtm " Entware ${R}$entServer${NC} failed"
		fi
	fi

	p_e_l
	if [ "$usePreviousEntware" ]; then
		printf " amtm is now ready to reuse the previous\\n $entVer installation on\\n"
		instN="Reuse previous Entware installation"
	else
		printf " amtm is now ready to install ${GN}$entVer${NC}\\n from server ${GN}$entServer${NC} to\\n"
		instN="Install Entware now"
	fi
	printf "\\n ${GN_BG} $entDev ${NC}\\n\\n"

	printf " 1. $instN\\n"
	printf " 2. Return to device/server selection\\n"
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
	[ -z "$usePreviousEntware" ] && [ -d "$entPath" ] && rm -rf "$entPath"

	if [ "$usePreviousEntware" ]; then
		echo " Relinking Entware symlink to $entPath"
	else
		echo " Creating install directory at $entPath"
	fi

	mkdir -p "$entPath"

	ln -sf "$entPath" /tmp/opt

	[ -z "$usePreviousEntware" ] && instP=Installing || instP=Reinstalling
	echo
	echo " $instP $entVer, using external script"
	[ "$useBackport" ] && echo " additionally using Entware backports repository)"
	echo "${GY}"
	case "$(uname -m)" in
		armv7l)	if [ "$useBackport" ]; then
					c_url "$INST_URL" | sed "s#URL=http://bin.entware.net/#URL=https://$entServer/#g" | sed -e "41 i sed -i 's#http://bin.entware.net/#https://$entServer/#g' /opt/etc/opkg.conf" \
					| sed -e "42 i sed -i '2isrc/gz entware-backports-garycnew https://garycnew.github.io/Entware/armv7sf-k2.6/' /opt/etc/opkg.conf" | sh
					echo "${NC}"
					echo " Installing required $entVer packages: wget-ssl ca-certificates"
					echo " for use with Entware backports repository"
					echo "${GY}"
					opkg install wget-ssl ca-certificates
					echo "${NC}"
				else
					c_url "$INST_URL" | sed "s#URL=http://bin.entware.net/#URL=https://$entServer/#g" | sed -e "41 i sed -i 's#http://bin.entware.net/#https://$entServer/#g' /opt/etc/opkg.conf" | sh
				fi
				;;
		mips)	if [ "$useBackport" ]; then
					c_url "$INST_URL" | sed 's/http:/https:/g' | sed -e "41 i sed -i 's/http:/https:/g' /opt/etc/opkg.conf" \
					| sed -e "42 i sed -i '2isrc/gz entware-backports-maurerr https://maurerr.github.io/packages' /opt/etc/opkg.conf" | sh
				else
					c_url "$INST_URL" | sed 's/http:/https:/g' | sed -e "41 i sed -i 's/http:/https:/g' /opt/etc/opkg.conf" | sh
				fi
				;;
		*)		c_url "$INST_URL" | sed "s#URL=http://bin.entware.net/#URL=https://$entServer/#g" | sed -e "41 i sed -i 's#http://bin.entware.net/#https://$entServer/#g' /opt/etc/opkg.conf" | sh
				;;
	esac
	echo "${NC}"

	if [ -f /opt/bin/opkg ]; then
		ENTURL="$(awk 'NR == 1 {print $3}' /opt/etc/opkg.conf)"
		[ "$(echo $ENTURL | grep 'aarch64\|armv7\|mipsel')" ] && entVersion="Entware (${ENTURL##*/})"
		[ -z "$entVersion" ] && entVersion=$entVer
		if [ -f /opt/etc/opkg.conf ] && /usr/sbin/openssl version | awk '$2 ~ /(^0\.)|(^1\.(0\.|1\.0))/ { exit 1 }' && grep -q 'http:' /opt/etc/opkg.conf; then
			sed -i 's/http:/https:/g' /opt/etc/opkg.conf
		fi

		if [ "$(/opt/bin/find /tmp/mnt/*/ -maxdepth 1 -type d -name "entware*" 2>/dev/null | wc -l)" -gt 1 ]; then
			/opt/bin/find /tmp/mnt/*/ -maxdepth 1 -type d -name "entware*" | while read fdir; do
				if [ "$fdir" != "$(readlink /tmp/opt)" ] && [ -f "$fdir/bin/opkg" ]; then
					mv "$fdir" "$(dirname "$fdir")/old.$(basename "$fdir")"
				fi
			done
		fi

		cd

		echo " Checking /jffs/scripts entries"

		c_j_s /jffs/scripts/post-mount
		if grep -q "post-mount.div\|mount-entware.div" /jffs/scripts/post-mount; then
			sed -i '/post-mount.div/d' /jffs/scripts/post-mount >/dev/null
			sed -i '/mount-entware.div/d' /jffs/scripts/post-mount >/dev/null
		fi
		if ! grep -q ". /jffs/addons/amtm/mount-entware.mod" /jffs/scripts/post-mount; then
			c_nl /jffs/scripts/post-mount
			sed -i "2s~^~. /jffs/addons/amtm/mount-entware.mod # Added by amtm\n~" /jffs/scripts/post-mount
			echo " post-mount entry added"
		else
			echo " OK post-mount"
		fi

		c_j_s /jffs/scripts/services-stop
		if ! grep -q "/opt/etc/init.d/rc.unslung stop" /jffs/scripts/services-stop; then
			echo "/opt/etc/init.d/rc.unslung stop # Added by amtm" >>/jffs/scripts/services-stop
			echo " services-stop entry added"
		else
			echo " OK services-stop"
		fi

		if [ ! -f /jffs/addons/amtm/mount-entware.mod ]; then
			g_m mount-entware.mod new
			echo " mount-entware.mod downloaded"
		else
			echo " OK mount-entware.mod"
		fi
		[ ! -x /jffs/addons/amtm/mount-entware.mod ] && chmod 0755 /jffs/addons/amtm/mount-entware.mod
		sleep 2

		r_m entware_setup.mod

		if [ "$usePreviousEntware" ]; then
			p_e_l
			echo " This router needs to reboot now so it can use"
			echo " the previous Entware installation."
			echo
			echo " Note that you may have to reinstall already"
			echo " installed third-party scripts that reside"
			echo " in Entware after the reboot."
			echo " In the case of Diversion, all you need to do is open"
			echo " Diversion in amtm so it can do a self check."
			p_e_t "continue"
			clear
			ascii_logo '  Goodbye!'
			echo
			printf " amtm reboots this router now\\n\\n"
			sleep 1
			service reboot >/dev/null 2>&1 &
			exit 0
		else
			am=;show_amtm " $entVersion install successful"
		fi
	else
		cd
		r_m entware_setup.mod
		am=;show_amtm " $entVer install failed"
	fi
}

install_Entware(){
	p_e_l
	printf " This installs Entware - the ultimate Software\\n repository for embedded devices on your router.\\n\\n Visit https://entware.net to learn more about\\n Entware.\\n\\n"
	printf " Author: thelonelycoder\\n"
	p_e_l;while true;do printf " Continue? [1=Yes e=Exit] ";read -r continue;case "$continue" in 1)setup_Entware;break;;[Ee])r_m entware_setup.mod;am=;show_amtm menu;break;;*)printf "\\n input is not an option\\n\\n";;esac done;
}
#eof
