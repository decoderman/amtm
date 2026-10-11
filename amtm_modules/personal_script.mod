#!/bin/sh
#bof
personal_script_installed(){
	[ -z "$su" -a -z "$ss" ] && printf "${GN_BG} p ${NC} %-9s%-21s%${COR}s\\n" "open" "Personal script settings"
	if [ -z "$su" -a -z "$ss" ] && [ -s "${add}"/personalscript.conf ]; then
		# I know column could do that, but it's an Entware package.
		i=1;i2=2
		longestOddLN=$(grep -Eo "[^/]*( |$)" < "${add}"/personalscript.conf | awk 'NR % 2 == 1 { print length() | "sort -rn" }' | head -n 1)
		for psi in $(grep "^" "${add}"/personalscript.conf); do
			if [ "$i" -eq  "$((i2-1))" ]; then
				printf " ${GN_BG}p$i${NC} %-$((${longestOddLN%% *}+1))s" "$(basename ${psi%% *})$(echo $psi | awk '{$1 = ""; print $0;}')"
			else
				printf "${GN_BG}p$i${NC} $(basename ${psi%% *})$(echo $psi | awk '{$1 = ""; print $0;}')\\n"
				i2=$((i2+2))
			fi
			i=$((i+1))
		done
		[[ $((i % 2)) -eq 0 ]] && printf "\\n\\n" || printf "\\n"
	fi

	case_p(){
		manage_personal_script
		show_amtm menu
	}

	trap_script(){
		clear
		p_e_l
		echo " amtm now runs $@"
		p_e_l
		trap_ctrl(){
			show_amtm menu
		}
		trap trap_ctrl 2
		sh "$@"
		trap - 2
		[ "$exitamtm" = 1 ] && exit || sleep 3;show_amtm menu
	}

	case_pr(){
		case "${1:1:1}" in
			[1-$(wc -l < ${add}/personalscript.conf)])
				pScript=$(sed "${1:1:1}!d" "${add}"/personalscript.conf)
				[ "${1:2}" ] && exitamtm=1 || exitamtm=
				if [ -f "${pScript%% *}" ]; then
					trap_script $pScript
				else
					show_amtm " Personal script '${pScript%% *}' not found"
				fi
				;;
			*)	show_amtm " input $1 is not an option";;
		esac
	}
}

manage_personal_script(){
	p_e_l
	i=0
	if [ -s "${add}"/personalscript.conf ]; then
		sed -i '/^[[:space:]]*$/d' "${add}"/personalscript.conf
		printf " Personal script settings

 You can add up to eight of your own scripts
 to the amtm menu and run them directly from it.

 Scripts are run using the sh shell, arguments
 are supported, e.g
 ${GN}sh /jffs/scripts/my_script.sh${NC}
 ${GN}sh /jffs/scripts/my_script.sh param1 param2${NC}
 Change shebang line in script for other shell.

 Options for entering a script command:
 - Entering ${GN_BG}p1${NC} runs script and returns to amtm.
 - Adding 'e' to command like ${GN_BG}p1e${NC} runs the
   script and then exits amtm.\\n\\n"
		printf " Your personal scripts:\\n"
		while read -r psi ; do
			i=$((i+1))
			printf " ${GN_BG}p$i${NC} $(dirname ${psi%% *})/${GN}$(basename ${psi%% *})${NC}$(echo $psi | awk '{$1 = ""; print $0;}')\\n"
		done < "${add}"/personalscript.conf
	else
		printf " Disclaimer from thelonelycoder

 Added scripts will run as-is when its command is
 entered into amtm. No checks are done by it to
 verify validity, malicious content or incomplete
 code. This is your own script and you are
 responsible for what it does on your router.\\n"
	fi
	if [ $i -ge 1 -a $i -le 7 ]; then
		printf "\\n 1. Add script to amtm ($i/8)\\n 2. Edit script path\\n 3. Remove script from amtm\\n"
		sse1=1;sse2=-4;csse1=1;csse2=2;csse3=3
	elif [ $i -eq 8 -o $i -gt 7 ]; then
		printf "\\n 2. Edit script path\\n 3. Remove script from amtm\\n"
		sse1=2;sse2=-4;csse1=;csse2=2;csse3=3
	else
		printf "\\n 1. Add script to amtm\\n"
		sse1=1;sse2=",4";csse1=1;csse2=;csse3=
	fi
	printf " 4. Remove personal script addon\\n"

	while true; do
		printf "\\n Enter selection [$sse1$sse2 e=Exit] ";read -r continue
		case "$continue" in
			$csse1)	p_e_l
					printf " Enter the full path to a script including\\n arguments (if any) and press Enter.\\n Examples:\\n"
					printf " ${GN}/jffs/scripts/my_script.sh${NC}\\n ${GN}/jffs/scripts/my_script.sh param1 param2${NC}\\n\\n"
					while true; do
						printf " Enter path and press Enter [e=Exit] ";read -r psPath
						case "$psPath" in
							[Ee])	manage_personal_script;break;;
							*)		[ ! -f "${add}"/personalscript.conf ] && touch "${add}"/personalscript.conf
									if grep -q "^$psPath$" "${add}"/personalscript.conf; then
										printf "\\n Script $R$psPath$NC\\n is already in your list.\\n\\n"
									elif [ -f "${psPath%% *}" ]; then
										echo "$psPath" >>"${add}"/personalscript.conf
										manage_personal_script
									else
										printf "\\n Script not found, check exact path and script name.\\n No space(s) in path or name allowed.\\n\\n"
									fi
									;;
						esac
					done
					break;;
			$csse2)	p_e_l
					printf " Edit script path:\\n\\n"
					i=0
					while read -r psi ; do
						i=$((i+1))
						printf " $i. $(dirname ${psi%% *})/${GN}$(basename ${psi%% *})${NC}$(echo $psi | awk '{$1 = ""; print $0;}')\\n"
					done < "${add}"/personalscript.conf

					while true; do
						printf "\\n Enter selection [1-$i e=Exit] ";read -r pss
						case "$pss" in
							[Ee])	manage_personal_script;break;;
							[1-$i])	p_e_l
									printf " Enter the full new path for this script\\n including arguments (if any) and press Enter.\\n\\n"
									while true; do
										printf " Enter path and press Enter [e=Exit] ";read -r psPath
										case "$psPath" in
											[Ee])	manage_personal_script;break;;
											*)		if grep -q "^$psPath$" "${add}"/personalscript.conf; then
														printf "\\n Script $R$psPath$NC\\n is already in your list.\\n\\n"
													elif [ -f "${psPath%% *}" ]; then
														sed -i "${pss} c$psPath" "${add}"/personalscript.conf
														manage_personal_script
													else
														printf "\\n Script not found, check exact path and script name.\\n No space(s) in path or name allowed.\\n\\n"
													fi
													;;
										esac
									done
									;;
								*)	printf "\\n input is not an option\\n";;
						esac
					done
					break;;
			$csse3)	p_e_l
					printf " Remove script from amtm:\\n\\n"
					i=0
					while read -r psi ; do
						i=$((i+1))
						printf " $i. $(dirname ${psi%% *})/${GN}$(basename ${psi%% *})${NC}$(echo $psi | awk '{$1 = ""; print $0;}')\\n"
					done < "${add}"/personalscript.conf

					while true; do
						printf "\\n Enter selection [1-$i e=Exit] ";read -r pss
						case "$pss" in
							[Ee])	manage_personal_script;break;;
							[1-$i])	sed -i "${pss}d" "${add}"/personalscript.conf
									manage_personal_script
									;;
								*)	printf "\\n input is not an option\\n";;
						esac
					done
					break;;
			4)		p_e_l
					printf " This removes the personal script addon from\\n your router.\\n\\n No personal scripts will be deleted.\\n"
					c_d
					r_m personalscript.conf
					r_m personal_script.mod
					am=;show_amtm " Personal scripts addon removed"
					break;;
			[Ee])	show_amtm menu;break;;
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
