#!/bin/sh
#bof
reboot_scheduler(){
	if [ "$1" = install ]; then
		if [ "$(nvram get reboot_schedule_enable)" = 1 ]; then
			p_e_l
			echo " Reboot scheduler is enabled in the WebUI."
			echo " This needs to be disabled first."
			echo
			while true; do
				printf " Disable scheduler now? [1=Yes e=Exit] ";read -r continue
				case "$continue" in
					1)		nvram set reboot_schedule=00000000000
							nvram set reboot_schedule_enable=0
							nvram commit
							echo
							echo " WebUI Reboot scheduler disabled.";break;;
					[Ee])	am=;show_amtm " Exited reboot scheduler function";break;;
					*)		printf "\\n input is not an option\\n\\n";;
				esac
			done
		fi

		if [ -f /jffs/scripts/init-start ] && grep -qE "ScheduledReboot" /jffs/scripts/init-start; then
			echo " Removing third-party reboot scheduler"
			echo " in /jffs/scripts/init-start."
			cru d ScheduledReboot
			sed -i '\~/jffs/scripts/ScheduledReboot~d' /jffs/scripts/init-start
		fi

		p_e_l
		rsdow=;rsdom=;rsmsg=
		printf " Set the day(s) to reboot the router.\\n"
		printf "\\n${GN} Days examples, multiple choice${NC}:\\n 1   Reboots on Monday\\n 247 Reboots Tuesday, Thursday and Sunday\\n"
		printf "\\n${GN} Preset examples, single choice${NC}:\\n 90 Reboots every day\\n 95 Reboots on the 15th day every Month\\n\\n"
		printf " ${GN}Only set by Days OR by Preset${NC}.\\n\\n"
		printf " Days               Preset                 Expression\\n"
		printf " ------------  OR   ---------------------------------\\n"
		printf " 1. Monday          90. Every day              ${GN_BG}*${NC}\\n"
		printf " 2. Tuesday         91. Even days              ${GN_BG}2-30/2${NC}\\n"
		printf " 3. Wednesday       92. Odd days               ${GN_BG}1-31/2${NC}\\n"
		printf " 4. Thursday        93. Day 1 & 15 every Month ${GN_BG}1,15${NC}\\n"
		printf " 5. Friday          94. Day 1 every Month      ${GN_BG}1${NC}\\n"
		printf " 6. Saturday        95. Day 15 every Month     ${GN_BG}15${NC}\\n"
		printf " 7. Sunday\\n\\n"

		while true; do
			printf " Enter selection [1-7 OR 90-95 e=Exit] ";read -r rsd
			case "$rsd" in
				[Ee])			am=;show_amtm " Exited reboot scheduler function"
								break;;
				9[0-5])			rsdow='*'
								case "$rsd" in
									90)				rsdom='*';;
									91)				rsdom="2-30/2";;
									92)				rsdom="1-31/2";;
									93)				rsdom="1,15";;
									94)				rsdom="1";;
									95)				rsdom="15";;
								esac
								break;;
				''|*[!1-7]*)	printf "\\n input is not an option\\n\\n";;
				*) 				rsdo=$rsd
								rsd=$(echo "$rsd" | grep -o . | sort -un)
								rsdom='*'
								if [ "$(echo $rsd | sed -e 's/ //g')" = 1234567 ]; then
									rsdow='*'
									rsmsg=1
								else
									for day in $(echo "$rsd" | grep -o .); do
										case "$day" in
											1)		rsdow="$rsdow,Mon";;
											2)		rsdow="$rsdow,Tue";;
											3)		rsdow="$rsdow,Wed";;
											4)		rsdow="$rsdow,Thu";;
											5)		rsdow="$rsdow,Fri";;
											6)		rsdow="$rsdow,Sat";;
											7)		rsdow="$rsdow,Sun";;
										esac
									done
									rsdow=$(echo $rsdow | sed -e 's/,/ ,/g' | awk '{for (i=1;i<=NF;i++) if (!a[$i]++) printf("%s%s",$i,FS)}{printf("\n")}' | sed -e 's/ //g;s/^,//')
								fi
								break;;
			esac
		done

		p_e_l
		[ "$rsdow" = '*' ] && rsui=$rsdom || rsui=$rsdow
		[ "$rsmsg" = 1 ] && printf " Note: Every day selected in Days column,\\n simplifying \"$rsdo\" to ${GN_BG} * ${NC}\\n\\n"
		echo " Set the hour to reboot at ${GN_BG} $rsui ${NC}"
		echo
		while true; do
			printf " Enter hour [0-23 e=Exit] ";read -r rsh
			case "$rsh" in
				[Ee])						show_amtm " Exited reboot scheduler function";break;;
				[0-9]|[1][0-9]|[2][0-3]) 	break;;
				*)							printf "\\n input is not an option\\n\\n";;
			esac
		done

		p_e_l
		echo " Set the minute to reboot"
		echo
		while true; do
			printf " Enter minute [0-59 e=Exit] ";read -r rsm
			case "$rsm" in
				[Ee])				am=;show_amtm " Exited reboot scheduler function";break;;
				[0-9]|[1-5][0-9]) 	break;;
				*)					printf "\\n input is not an option\\n\\n";;
			esac
		done

		p_e_l
		echo " Your router will reboot every:"
		echo
		[ "$(echo $rsm | wc -m)" -lt 3 ] && rsmc=$(echo $rsm | sed -e 's/^/0/') || rsmc=$rsm
		echo "${GN_BG} $rsui @ ${rsh}:${rsmc} ${NC}"
		echo
		while true; do
			printf " Is this correct? [1=Yes 2=No] ";read -r continue
			case "$continue" in
				1)		break;;
				2)		echo
						echo " Starting over with reboot scheduler..."
						reboot_scheduler install;break;;
				*)		printf "\\n input is not an option\\n\\n";;
			esac
		done

		c_j_s /jffs/scripts/init-start
		t_f /jffs/scripts/init-start
		if ! grep -q "amtm_RebootScheduler" /jffs/scripts/init-start; then
			echo "cru a amtm_RebootScheduler \"$rsm $rsh $rsdom * $rsdow service reboot\" # Added by amtm" >> /jffs/scripts/init-start
			rsct=enabled
		else
			sed -i '\~amtm_RebootScheduler~d' /jffs/scripts/init-start
			cru d amtm_RebootScheduler
			echo "cru a amtm_RebootScheduler \"$rsm $rsh $rsdom * $rsdow service reboot\" # Added by amtm" >> /jffs/scripts/init-start
			rsct=changed
		fi
		cru a amtm_RebootScheduler "$rsm $rsh $rsdom * $rsdow service reboot"

		show_amtm " Reboot scheduler $rsct"

	elif [ "$1" = "manage" ]; then
		p_e_l
		printf " Reboot scheduler options\\n\\n Reboot scheduler runs as follows:\\n"

		rsui="$(grep -o "amtm_RebootScheduler .*" /jffs/scripts/init-start 2>/dev/null | awk '{print $6}')"
		[ "$rsui" = '*' ] && rsui=$(grep -o "amtm_RebootScheduler .*" /jffs/scripts/init-start 2>/dev/null | awk '{print $4}')

		printf " ${GN_BG} $(grep -o "amtm_RebootScheduler .*" /jffs/scripts/init-start 2>/dev/null | awk '{print "'$rsui'"" @ "$3":"$2}' | sed -e 's/"//') ${NC}\\n\\n"

		printf " 1. Change reboot scheduler\\n 2. Remove reboot scheduler\\n\\n"
		while true; do
			printf " Enter option [1-2 e=Exit] ";read -r continue
			case "$continue" in
				1)			echo
							echo " Starting over with reboot scheduler..."
							reboot_scheduler install;break;;
				2)			sed -i '\~amtm_RebootScheduler~d' /jffs/scripts/init-start
							r_w_e /jffs/scripts/init-start
							cru d amtm_RebootScheduler
							show_amtm " Reboot scheduler removed"
							break;;
				[Ee])		show_amtm " Exited reboot scheduler function";break;;
				*)			printf "\\n input is not an option\\n\\n";;
			esac
		done
	fi
}
reboot_scheduler_installed(){
	[ -z "$su" ] && atii=1
	rsui="$(grep -o "amtm_RebootScheduler .*" /jffs/scripts/init-start 2>/dev/null | awk '{print $6}')"
	[ "$rsui" = '*' ] && rsui=$(grep -o "amtm_RebootScheduler .*" /jffs/scripts/init-start 2>/dev/null | awk '{print $4}')
	rstext=$(grep -o "amtm_RebootScheduler .*" /jffs/scripts/init-start 2>/dev/null | awk '{print "'$rsui'"" @ "$3":"$2}' | sed -e 's/"//')

	if [ "$rsui" != '*' ]; then
		rswc=$(echo $rstext | awk '{print $1}' | wc -m)
		[ "$(echo $rstext | grep -o ':.*' | wc -m)" -lt "4" ] && rstext=$(echo $rstext | sed -e 's/:/:0/')
		if [ "$rswc" = 28 ]; then
			rstext=$(echo $rstext | awk '{print "daily " $2, $3}')
		elif [ "$rswc" -ge 20 ]; then
			dows=$(echo $rstext | awk '{print $1","}')
			dows="${dows//??,/,}"
			rstext=$(echo $rstext | awk '{print "'${dows%,}' " $2, $3}')
		elif [ "$rswc" -gt 8 ]; then
			dows=$(echo $rstext | awk '{print $1","}')
			dows="${dows//?,/,}"
			rstext=$(echo $rstext | awk '{print "'${dows%,}' " $2, $3}')
		fi
	fi
	[ -z "$su" ] && printf "${GN_BG} rs${NC} %-9s%s\\n" "manage" "Reboot scheduler ${GN_BG}${rstext}${NC}"

	case_rs(){
		reboot_scheduler manage
	}
}
install_reboot_scheduler(){
	p_e_l
	printf " This installs reboot scheduler\\n on your router.\\n\\n"
	printf " This scheduler is set with a cron job via\\n init-start, as opposed to the WebUI setting\\n which uses an internal mechanism to reboot.\\n\\n"
	printf " Author: thelonelycoder\\n https://www.snbforums.com/forums/asuswrt-merlin-addons.60/?prefix_id=16&starter_id=25480\\n"
	c_d
	reboot_scheduler install
}
#eof
