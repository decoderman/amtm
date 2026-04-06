#!/bin/sh
#bof
personal_script_installed(){
	[ -z "$su" -a -z "$ss" ] && printf "${GN_BG} p ${NC} %-9s%-21s%${COR}s\\n" "open" "Personal script settings"
	i=1
	[ -z "$su" -a -z "$ss" ] && [ -s "${add}"/personalscript.conf ] && for psi in $(cat "${add}"/personalscript.conf); do
		printf " ${GN_BG}p$i${NC} %-9s%-21s%${COR}s\\n" "run" "$(basename ${psi})"
		eval "psPath$i=$psi"
		i=$((i+1))
	done

	case_p(){
		manage_personal_script
		show_amtm menu
	}
	trap_script(){
		clear
		p_e_l
		echo " amtm is running $1 now"
		p_e_l
		trap_ctrl(){
			show_amtm menu
		}
		trap trap_ctrl 2
		sh "$1"
		trap - 2
		[ "$exitamtm" = 1 ] && exit || sleep 3;show_amtm menu
	}
	case_pr(){
		exitamtm=
		if [ "$(echo $selection | grep 'e')" ]; then
			selection=$(echo $selection | sed 's/e//')
			exitamtm=1
		fi
		case "$selection" in
			[Pp]1) 	psPath=$psPath1;;
			[Pp]2) 	psPath=$psPath2;;
			[Pp]3) 	psPath=$psPath3;;
			[Pp]4) 	psPath=$psPath4;;
		esac

		if [ -f "$psPath" ]; then
			trap_script $psPath
		else
			show_amtm " Personal script '$psPath' not found"
		fi
	}
}

manage_personal_script(){
	p_e_l
	i=0
	if [ -s "${add}"/personalscript.conf ]; then
		printf " Personal script settings

 You can add up to four of your own scripts
 to the amtm menu and run them directly from it.

 All scripts are run using the sh shell, e.g
 ${GN}sh /jffs/scripts/my_script.sh${NC}.
 Change shebang line in script for other shell.

 Options for entering a script command:
 - Entering ${GN_BG}p1${NC} runs script and returns to amtm.
 - Adding 'e' to command like ${GN_BG}p1e${NC} runs the
   script and then exits amtm.\\n\\n"
		printf " Your personal scripts:\\n"
		for psi in $(cat "${add}"/personalscript.conf); do
			i=$((i+1))
			printf " p$i: ${GN}${psi}${NC}\\n"
		done
	else
		printf " Disclaimer from thelonelycoder

 Added scripts will run as-is when its command is
 entered into amtm. No checks are done by it to
 verify validity, malicious content or incomplete
 code. This is your own script and you are
 responsible for what it does on your router.\\n"
	fi
	if [ $i -ge 1 -a $i -le 3 ]; then
		printf "\\n 1. Add script to amtm\\n 2. Remove script from amtm\\n"
		sse1=1;sse2=-3;csse1=1;csse2=2
	elif [ $i -eq 4 ]; then
		printf "\\n 2. Remove script from amtm\\n"
		sse1=2;sse2=-3;csse1=;csse2=2
	else
		printf "\\n 1. Add script to amtm\\n"
		sse1=1;sse2=",3";csse1=1;csse2=
	fi
	printf " 3. Remove personal script addon\\n"

	while true; do
		printf "\\n Enter selection [$sse1$sse2 e=Exit] ";read -r continue
		case "$continue" in
			$csse1)	p_e_l
					printf " Enter the full path to a script and press Enter.\\n Example script path:\\n ${GN}/jffs/scripts/my_script.sh${NC}\\n\\n"
					while true; do
						printf " Enter path and press Enter [e=Exit] ";read -r psPath
						case "$psPath" in
							[Ee])	show_amtm " Exited personal script settings";break;;
							*)		if [ -f "$psPath" ]; then
										psPathName=$(basename ${psPath})
										echo "$psPath" >>"${add}"/personalscript.conf
										show_amtm " Personal script '$psPathName' added"
									else
										printf "\\n Script not found, check exact path and script name.\\n No space(s) in path or name allowed.\\n\\n"
									fi
									;;
						esac
					done
					break;;
			$csse2)	p_e_l
					printf " Remove script from amtm:\\n\\n"
					i=0
					for psi in $(cat "${add}"/personalscript.conf); do
						i=$((i+1))
						printf " $i. ${GN}${psi}${NC}\\n"
						eval "psPath$i=$psi"
					done

					while true; do
						printf "\\n Enter selection [1-$i e=Exit] ";read -r pss
						case "$pss" in
							[Ee])	show_amtm " Exited personal script settings";break;;
							*)		script=$(eval "echo \"\$psPath$pss\"")
									if [ -f "$script" ]; then
										sed -i "\|$script|d" "${add}"/personalscript.conf
										show_amtm " Personal script '$script' removed"
									else
										printf "\\n input is not an option\\n\\n"
									fi
									;;
						esac
					done
					break;;
			3)		p_e_l
					printf " This removes the personal script addon from\\n your router.\\n\\n No personal scripts will be deleted.\\n"
					c_d
					r_m personalscript.conf
					r_m personal_script.mod
					am=;show_amtm " Personal scripts addon removed"
					break;;
			[Ee])	break;;
			*)		printf "\\n input is not an option\\n";;
		esac
	done
}

install_personal_script(){
	p_e_l
	printf " This allows to run personal scripts directly
 from amtm.

 Do you have your own script saved on your router
 but it's not supported by amtm? This will allow you
 to add it to the amtm menu and run it directly from it.

 Author: thelonelycoder
 snbforums.com/forums/asuswrt-merlin-addons.60/?prefix_id=16\\n"
	c_d
	manage_personal_script
	if [ -f "${add}"/personalscript.conf ]; then
		show_amtm " Personal script installed"
	else
		am=;show_amtm " Personal script install failed or aborted"
	fi
}
#eof
