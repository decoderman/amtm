#!/bin/sh
#bof
router_date_installed(){
	atii=1
	if ! grep -qE "^VERSION=$rd_version" "${add}"/routerdate; then
		write_router_date_file
		a_m " - Router date keeper script updated to $rd_version"
	fi
	[ -z "$su" ] && printf "${GN_BG} rd${NC} %-9s%-19s\\n" "manage" "Router date keeper"
	case_rd(){
		router_date manage
		show_amtm menu
	}
}
install_router_date(){
	p_e_l
	echo " This installs router date keeper"
	echo " on this router."
	printf "\\n Sort of a nerd mode - or for people with OCD.\\n\\n amtm will keep the routers last date when\\n booting or rebooting. The routers system log\\n date entries look more consistent.\\n\\n"
	printf " Author: thelonelycoder\\n"
	c_d

	router_date install
	if [ -f "${add}"/routerdate ]; then
		show_amtm " Router date keeper installed"
	else
		am=;show_amtm " Router date keeper installation failed"
	fi
}
router_date(){
	if [ "$1" = install ]; then
		c_j_s /jffs/scripts/init-start
		t_f /jffs/scripts/init-start
		if ! grep -q "^${add}/routerdate" /jffs/scripts/init-start; then
			sed -i "\~routerdate ~d" /jffs/scripts/init-start
			echo "${add}/routerdate restore # Added by amtm" >> /jffs/scripts/init-start
		fi
		c_j_s /jffs/scripts/services-stop
		t_f /jffs/scripts/services-stop
		if ! grep -q "^${add}/routerdate" /jffs/scripts/services-stop; then
			sed -i "\~routerdate ~d" /jffs/scripts/services-stop
			echo "${add}/routerdate save # Added by amtm" >> /jffs/scripts/services-stop
		fi
		if [ "$(/bin/nvram get time_zone_x)" ]; then
			printf "%s" "\$(/bin/nvram get time_zone_x)" > "${add}"/TZ
		elif [ -f /etc/TZ ]; then
			cp /etc/TZ "${add}"/TZ
		fi
		write_router_date_file
		cru a amtm_RouterDate "45 */6 * * * /jffs/addons/amtm/routerdate cron"

	elif [ "$1" = manage ]; then
		p_e_l
		rd="$(/bin/date -u -r "${add}"/routerdate '+%Y-%m-%d %H:%M:%S')"
		printf " Router date keeper options\\n\\n"
		printf " The saved date auto-updates at 45 minutes\\n past every 6th hour and when rebooting.\\n\\n Saved date: $rd UTC time\\n\\n"
		printf " 1. Update saved date manually\\n"
		printf " 2. Remove router date script\\n"
		while true; do
			printf "\\n Enter selection [1-2 e=Exit] ";read -r continue
			case "$continue" in
				1)		/bin/sh /jffs/addons/amtm/routerdate cron
						rd="$(/bin/date -u -r "${add}"/routerdate '+%Y-%m-%d %H:%M:%S')"
						show_amtm " Router date saved as\\n $rd UTC time"
						break;;
				2)		cru d amtm_RouterDate
						sed -i "\~routerdate ~d" /jffs/scripts/init-start
						sed -i "\~routerdate ~d" /jffs/scripts/services-stop
						r_w_e /jffs/scripts/init-start
						r_w_e /jffs/scripts/services-stop
						rm -f "${add}"/routerdate "${add}"/router_date.mod "${add}"/TZ
						show_amtm " Router date keeper script removed"
						break;;
				[Ee])	show_amtm menu;break;;
				*)		printf "\\n input is not an option\\n";;
			esac
		done
	fi
}

write_router_date_file(){
	cat <<-EOF > "${add}"/routerdate
	#!/bin/sh
	# Router date keeper. Coded by thelonelycoder
	# Script created by amtm $version
	VERSION=$rd_version
	NAME="amtm \$(basename "\$0")[\$\$]"
	[ -f "/jffs/addons/amtm/TZ" ] && export TZ="\$(cat /jffs/addons/amtm/TZ)" || export TZ="\$(/bin/nvram get time_zone_x)"
	SCRIPT_LOC="\$(/usr/bin/readlink -f "\$0")"
	rd='/bin/date -u -r "\$SCRIPT_LOC" '\''+%Y-%m-%d %H:%M:%S'\'''

	case \${1} in
	    save|cron)  /bin/touch "\$SCRIPT_LOC"
	                printf "%s" "\$(/bin/nvram get time_zone_x)" > /jffs/addons/amtm/TZ
	                [ "\$1" = "save" ] && rdtxt='before reboot' || rdtxt='via cron'
	                logger -t "\$NAME" "Preserving router date \$rdtxt (\$(eval "\$rd")) UTC time."
	                ;;
	    restore)    if [ "\$(/bin/nvram get ntp_ready)" = 0 ]; then
	                    /bin/date -u -s "\$(eval "\$rd")"
	                fi
	                if ! cru l | grep -q "amtm_RouterDate"; then
	                    cru a amtm_RouterDate "45 */6 * * * /jffs/addons/amtm/routerdate cron"
	                fi
	                ;;
	esac
	exit 0
	EOF
	[ ! -x "${add}"/routerdate ] && chmod 0755 "${add}"/routerdate
}
#eof
