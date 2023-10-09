#!/bin/sh
#bof
shell_history_installed(){
	if ! grep -q "^${add}/shellhistory" /jffs/scripts/services-start 2> /dev/null; then
		shell_history install
	fi

	if ! grep -qE "^VERSION=$sh_version" "${add}"/shellhistory; then
		write_shell_history_file
		a_m " - shell history script updated to $sh_version"
	fi

	[ -z "$su" ] && printf "${GN_BG} sh${NC} %-9s%-19s\\n" "manage" "shell history"
	case_sh(){
		shell_history manage
		show_amtm menu
	}
}
install_shell_history(){
	p_e_l
	echo " This installs shell history"
	echo " on this router."
	printf "\\n It lets amtm keep a persistent history of\\n shell commands entered on this router.\\n\\n"
	printf " Use up and down arrow keys to scroll\\n through previous commands.\\n\\n Author: thelonelycoder\\n"
	c_d

	shell_history install
	if [ -f "${add}"/shellhistory ]; then
		show_amtm " shell histroy installed"
	else
		am=;show_amtm " shell histroy installation failed"
	fi
}
shell_history(){
	if [ -f /jffs/addons/diversion/mount-entware.div ] && grep -q "ash-history.div" /jffs/addons/diversion/mount-entware.div; then
		am=;show_amtm " To install shell history, you need to update\\n Diversion to its latest version."
	else
		if [ "$1" = install ]; then
			c_j_s /jffs/scripts/services-start
			t_f /jffs/scripts/services-start
			if ! grep -q "^${add}/shellhistory" /jffs/scripts/services-start; then
				sed -i "\~shellhistory ~d" /jffs/scripts/services-start
				echo "${add}/shellhistory # Added by amtm" >> /jffs/scripts/services-start
			fi
			write_shell_history_file

		elif [ "$1" = manage ]; then
			p_e_l
			printf " shell history options\\n\\n 1. Reset shell history\\n 2. View shell history content\\n 3. Remove shell history script\\n"
			while true; do
				printf "\\n Enter selection [1-3 e=Exit] ";read -r continue
				case "$continue" in
				1)		p_e_l
						printf " This resets the shell history commands.\\n"
						printf "\\n When resetting the shell history, log out and back\\n in with your SSH client to clear its history.\\n"
						c_d
						rm -f /jffs/addons/amtm/.ash_history /home/root/.ash_history /tmp/amtm_sort_s_h
						"${add}"/shellhistory &
						show_amtm " shell history reset"
						break;;
				2)		s_l_f .ash_history;break;;
				3)		p_e_l
						printf " This removes the shell history script.\\n"
						c_d
						sed -i "\~shellhistory ~d" /jffs/scripts/services-start
						r_w_e /jffs/scripts/services-start
						rm -f /jffs/addons/amtm/.ash_history /home/root/.ash_history /tmp/amtm_sort_s_h
						rm -f "${add}"/shellhistory "${add}"/shell_history.mod
						show_amtm " shell history script removed"
						break;;
				[Ee])	show_amtm menu;break;;
				*)		printf "\\n input is not an option\\n";;
				esac
			done
		fi
	fi
}

write_shell_history_file(){
	cat <<-EOF > "${add}"/shellhistory
	#!/bin/sh
	# Keep a shell history of entered commands. Coded by thelonelycoder
	# Script created by amtm $version

	VERSION=$sh_version
	alh=0
	while [ -f /tmp/amtm_l_s_h ] && [ "\$alh" -lt 10 ]; do
	    alh=\$((alh+1))
	    sleep 1
	done

	if [ -f /tmp/amtm_l_s_h ]; then
	    kill "\$(sed -n '1p' /tmp/amtm_l_s_h)" 2> /dev/null
	    rm -f /jffs/addons/amtm/.ash_history  /home/root/.ash_history /tmp/amtm_sort_s_h
	    echo "\$$" >/tmp/amtm_l_s_h
	else
	    echo "\$$" >/tmp/amtm_l_s_h
	fi
	if [ -f /jffs/addons/amtm/.ash_history ]; then
	    [ "\$(wc -l < /jffs/addons/amtm/.ash_history  )" -gt 300 ] && sed -i '1,50d' /jffs/addons/amtm/.ash_history
	    cat /jffs/addons/amtm/.ash_history  | sed '/diversion\$/d; /amtm/d; /^ *\$/d' | sort -urb >/tmp/amtm_sort_s_h
	else
	    >/tmp/amtm_sort_s_h
	fi
	[ -f /jffs/addons/diversion/mount-entware.div ] && grep -q "Entware and Diversion" /jffs/addons/diversion/mount-entware.div && echo 'diversion' >>/tmp/amtm_sort_s_h
	echo 'amtm' >>/tmp/amtm_sort_s_h
	mv -f /tmp/amtm_sort_s_h /jffs/addons/amtm/.ash_history
	ln -sf /jffs/addons/amtm/.ash_history  /home/root/
	rm -f /tmp/amtm_l_s_h
	exit 0
	EOF
	[ ! -x "${add}"/shellhistory ] && chmod 0755 "${add}"/shellhistory
	"${add}"/shellhistory &
}
#eof
