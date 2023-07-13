#!/bin/sh
#bof
router_date_installed(){
	atii=1
	if ! grep -qE "^VERSION=$rd_version" "${add}"/routerdate; then
		write_router_date_file
		a_m " - Router date keeper script updated to v$rd_version"
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
	printf "\\n Sort of a nerd mode - or for people with OCD.\\n\\n Lets amtm keep the routers last date when\\n booting or rebooting. The routers system log\\n date entries look more consistent.\\n\\n"
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
		write_router_date_file
		cru a amtm_RouterDate "45 */6 * * * /jffs/addons/amtm/routerdate cron"

	elif [ "$1" = manage ]; then
		p_e_l
		rd=$(grep '^rd=' "${add}"/routerdate | sed 's/rd=//')
		printf " Router date keeper options\\n\\n Current saved date: $rd\\n\\n"
		printf " 1. Remove router date script\\n"
		while true; do
			printf "\\n Enter selection [1-1 e=Exit] ";read -r continue
			case "$continue" in
				1)		cru d amtm_RouterDate
						sed -i "\~routerdate ~d" /jffs/scripts/init-start
						sed -i "\~routerdate ~d" /jffs/scripts/services-stop
						r_w_e /jffs/scripts/init-start
						r_w_e /jffs/scripts/services-stop
						rm -f "${add}"/routerdate "${add}"/router_date.mod
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
	rd='$(date +"%F %H:%M:%S")'

	case \${1} in
	    save)       rd=\$(date +"%F %H:%M:%S")
	                sed -i "/^rd=/c\rd='\$rd'" /jffs/addons/amtm/routerdate
	                logger -t "amtm router date" "Preserving router date before reboot (\$rd)"
	                ;;
	    cron)       sed -i "/^rd=/c\rd='\$(date +"%F %H:%M:%S")'" /jffs/addons/amtm/routerdate
	                ;;
	    restore)    [ "\$(nvram get ntp_ready)" = 0 ] && date -s "\$rd"
	                cru a amtm_RouterDate "45 */6 * * * /jffs/addons/amtm/routerdate cron"
	                ;;
	esac
	exit 0
	EOF
	[ ! -x "${add}"/routerdate ] && chmod 0755 "${add}"/routerdate
}
#eof
