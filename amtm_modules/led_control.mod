#!/bin/sh
#bof
led_control_installed(){
	atii=1
	if ! grep -qE "^VERSION=$led_version" "${add}"/ledcontrol; then
		write_ledcontrol_file
		a_m " - LED control script updated to v$led_version"
	fi
	if [ -f "${add}"/ledcontrol.conf ]; then
		. "${add}"/ledcontrol.conf
		if [ "$lcMode" = on ]; then
			if [ "$checkLed" = 1 ]; then
				ledsOn="$(date --date="$lcOnh:$lcOnm" +%s)"
				ledsOff="$(date --date="$lcOffh:$lcOffm" +%s)"
				now="$(date +%s)"
				if [ "$ledsOn" -le "$ledsOff" ]; then
					[ "$ledsOn" -le "$now" -a "$now" -lt "$ledsOff" ] && setLedsOn=1 || setLedsOn=0
				else
					[ "$ledsOn" -gt "$now" -a "$now" -ge "$ledsOff" ] && setLedsOn=0 || setLedsOn=1
				fi
				if [ "$setLedsOn" = 1 ]; then
					[ "$(nvram get led_disable)" = 1 ] && a_m " LEDs are now on, as per schedule"
				elif [ "$setLedsOn" = 0 ]; then
					[ "$(nvram get led_disable)" = 0 ] && a_m " LEDs are now off, as per schedule"
				fi
				checkLed=
				"${add}"/ledcontrol -set >/dev/null 2>&1
			fi
			[ "$(echo $lcOnm | wc -m)" -lt 3 ] && lcOnmc=$(echo $lcOnm | sed -e 's/^/0/') || lcOnmc=$lcOnm
			[ "$(echo $lcOffm | wc -m)" -lt 3 ] && lcOffmc=$(echo $lcOffm | sed -e 's/^/0/') || lcOffmc=$lcOffm
			[ "$locMode" = on ] && lMode=D || lMode=S
			lcOnOff="${GN_BG}${lcOnh}:${lcOnmc}${NC} ${E_BG}${lcOffh}:${lcOffmc}${NC} $lMode"
		elif [ "$lcMode" = off ]; then
			lcOnOff="${E_BG}disabled${NC}"
		fi
	fi
	[ "$(nvram get led_disable)" = 1 ] && ledState="${E_BG}off${NC}" || ledState="${GN_BG}on${NC}"

	[ -z "$su" ] && printf "${GN_BG} lc${NC} %-9s%-19s\\n" "manage" "LED control $lcOnOff LED $ledState"
	case_lc(){
		led_control_manage
		show_amtm menu
	}
}
install_led_control(){
	p_e_l
	echo " This installs LED control - Scheduled router LED control"
	echo " on your router."
	echo
	echo " Authors: thelonelycoder, RMerlin"
	echo " https://www.snbforums.com/forums/asuswrt-merlin-addons.60/?prefix_id=16&starter_id=25480"
	c_d

	tpLED=
	if [ -f /jffs/scripts/services-start ]; then
		if grep -q "lightsoff\|ledsoff\|ledcontrol" /jffs/scripts/services-start && ! grep -q "ledcontrol -set # Added by amtm" /jffs/scripts/services-start; then
			am=;tpLED=" - LED entrie(s) found in services-start\\n"
		fi
	fi
	if [ -f /jffs/scripts/ledsoff.sh ] || [ -f /jffs/scripts/ledson.sh ] || [ -f /jffs/scripts/ledcontrol ]; then
		am=;tpLED="$tpLED - LED file(s) found in /jffs/scripts/"
	fi
	[ "$tpLED" ] && show_amtm  " LED control install failed, incompatible:\\n$tpLED"

	write_ledcontrol_file

	if [ -f "${add}"/ledcontrol ]; then
		a_m " LED control installed"
		led_control_manage
	else
		am=;show_amtm " LED control installation failed"
	fi
}
led_control_manage(){
	p_e_l
	printf " This controls the router LEDs\\n\\n"
	printf " Manually setting the LEDs is preserved\\n between reboots, same as the WebUI setting.\\n"
	printf " However, the LED scheduler has precedence\\n over the manual setting.\\n\\n"
	printf " Time can be set statically with a set time\\n or dynamically using sunset/sunrise\\n time for your location.\\n\\n"
	if [ -f "${add}"/ledcontrol.conf ] && [ "$lcMode" = on ]; then
		printf " 1. Edit LED scheduler $lcOnOff\\n"
	elif [ -f "${add}"/ledcontrol.conf ] && [ "$lcMode" = off ]; then
		printf " 1. ${GN}Enable${NC} LED scheduler\\n"
	else
		printf " 1. Set daily LED ${GN_BG}on${NC} ${E_BG}off${NC} schedule\\n"
	fi
	if [ "$(nvram get led_disable)" = 1 ]; then
		printf " 2. Manually ${GN}Enable${NC} LEDs now\\n"
	else
		printf " 2. Manually ${R}Disable${NC} LEDs now\\n"
	fi
	printf " 3. Remove LED control script\\n"
	eok=3;noad=
	if [ -f "${add}"/ledcontrol.conf ] && [ "$lcMode" = on ]; then
		printf " 4. ${R}Disable${NC} LED scheduler\\n\\n"
		eok=4;noad=4
	fi
	echo

	while true; do
		printf " Enter option [1-$eok e=Exit] ";read -r continue
		case "$continue" in
			1)		if [ -f "${add}"/ledcontrol.conf ] && [ "$lcMode" = on ]; then
						led_control_schedule
					elif [ -f "${add}"/ledcontrol.conf ] && [ "$lcMode" = off ]; then
						check_services_start
						lcMode=on
						write_ledcontrol_conf
						write_ledcontrol_file
						checkLed=1
						show_amtm " LED control scheduler enabled"
					else
						led_control_schedule
					fi
					break;;
			2)		if [ "$(nvram get led_disable)" = 1 ]; then
						"${add}"/ledcontrol -on -p >/dev/null 2>&1
						show_amtm " LEDs are now on"
					else
						"${add}"/ledcontrol -off -p >/dev/null 2>&1
						show_amtm " LEDs are now off"
					fi
					break;;
			3)		p_e_l
					echo " This removes the scheduled LED control"
					c_d
					"${add}"/ledcontrol -on -p >/dev/null 2>&1
					if [ -f /jffs/scripts/services-start ]; then
						sed -i "\~${add}/ledcontrol.*~d" /jffs/scripts/services-start
						r_w_e /jffs/scripts/services-start
					fi
					cru d amtm_LEDcontrol_on
					cru d amtm_LEDcontrol_off
					cru d amtm_LEDcontrol_update
					rm "${add}"/ledcontrol*
					unset lcMode locMode locCode locLastUpd
					show_amtm " LED scheduler removed"
					break;;
			$noad)	lcMode=off
					write_ledcontrol_conf
					[ "$(nvram get led_disable)" = 1 ] && a_m " LEDs are now on"
					"${add}"/ledcontrol -set >/dev/null 2>&1
					show_amtm " LED control scheduler disabled"
					break;;
			[Ee])	show_amtm menu;break;;
			*)		printf "\\n input is not an option\\n\\n";;
		esac
	done
}
led_control_schedule(){
	p_e_l
	echo " Select how LEDs are controlled"
	echo
	unset lcMan lcDyn
	manEdit=Use
	dynEdit=Use
	if [ "$lcMode" = on ] && [ -z "$locMode" -o "$locMode" = off ]; then
		lcMan=$lcOnOff
		manEdit=Edit
	fi
	if [ "$lcMode" = on ] && [ "$locMode" = on ]; then
		lcDyn=$lcOnOff
		dynEdit=Edit
	fi
	printf " 1. $manEdit Static time $lcMan\\n"
	eok=2;noad=2
	if [ -f /opt/bin/opkg ]; then
		printf " 2. $dynEdit Dynamic time $lcDyn\\n    This uses the sunset/sunrise time\\n    from weather.com for your location\\n"
	else
		eok=1;noad=
		printf " ${GY}2. Use Dynamic time\\n    Feature requires Entware installed${NC}\\n"
	fi
	echo
	while true; do
		printf " Enter option [1-$eok e=Exit] ";read -r lcOnh
		case "$lcOnh" in
				1)	p_e_l
					echo " The router date is ${GN}$(date +"%b %d %Y %R")${NC}"
					echo
					echo " Set the ${GN}hour${NC} to turn LEDs ${GN_BG}on${NC} (step 1/4)"
					echo
					while true; do
						printf " Enter hour [0-23 e=Exit] ";read -r lcOnh
						case "$lcOnh" in
							[Ee])						show_amtm " Exited LED control function";break;;
							[0-9]|[1][0-9]|[2][0-3]) 	break;;
							*)							printf "\\n input is not an option\\n\\n";;
						esac
					done

					p_e_l
					echo " Set the ${GN}minute${NC} to turn LEDs ${GN_BG}on${NC} (2/4)"
					echo
					while true; do
						printf " Enter minute [0-59 e=Exit] ";read -r lcOnm
						case "$lcOnm" in
							[Ee])				am=;show_amtm " Exited LED control function";break;;
							[0-9]|[1-5][0-9]) 	break;;
							*)					printf "\\n input is not an option\\n\\n";;
						esac
					done

					p_e_l
					echo " Set the ${GN}hour${NC} to turn LEDs ${E_BG}off${NC} (3/4)"
					echo
					while true; do
						printf " Enter hour [0-23 e=Exit] ";read -r lcOffh
						case "$lcOffh" in
							[Ee])						show_amtm " Exited LED control function";break;;
							[0-9]|[1][0-9]|[2][0-3]) 	break;;
							*)							printf "\\n input is not an option\\n\\n";;
						esac
					done

					p_e_l
					echo " Set the ${GN}minute${NC} to turn LEDs ${E_BG}off${NC} (4/4)"
					echo
					while true; do
						printf " Enter minute [0-59 e=Exit] ";read -r lcOffm
						case "$lcOffm" in
							[Ee])				am=;show_amtm " Exited LED control function";break;;
							[0-9]|[1-5][0-9]) 	if [ "$lcOnh$lcOnm" -eq "$lcOffh$lcOffm" ]; then
													p_e_l
													echo " LED ${GN}on${NC} and ${R}off${NC} times cannot be the same."
													p_e_t "start over with LED control"
													led_control_schedule
												fi
												break;;
							*)					printf "\\n input is not an option\\n\\n";;
						esac
					done
					p_e_l
					echo " Your routers LED will:"
					echo
					[ "$(echo $lcOnm | wc -m)" -lt 3 ] && lcOnmc=$(echo $lcOnm | sed -e 's/^/0/') || lcOnmc=$lcOnm
					[ "$(echo $lcOffm | wc -m)" -lt 3 ] && lcOffmc=$(echo $lcOffm | sed -e 's/^/0/') || lcOffmc=$lcOffm
					echo " Turn ${GN_BG}on${NC} at  ${GN_BG}${lcOnh}:${lcOnmc}${NC}"
					echo " Turn ${E_BG}off${NC} at ${E_BG}${lcOffh}:${lcOffmc}${NC}"
					echo
					while true; do
						printf " Is this correct? [1=Yes 2=No] ";read -r continue
						case "$continue" in
							1)		check_services_start
									lcMode=on
									locMode=off
									write_ledcontrol_file
									write_ledcontrol_conf
									checkLed=1
									show_amtm " Static LED control scheduler set"
									break;;
							2)		echo
									echo " Starting over with LED control..."
									led_control_schedule;break;;
							*)		printf "\\n input is not an option\\n\\n";;
						esac
					done
					break;;
			$noad)	if [ "$locCode" ]; then
						p_e_l
						printf " Your weather.com location code is: $locCode\\n Sunset/Sunrise time update every Saturday and Tuesday.\\n Last update on: $locLastUpd\\n\\n"
						printf " 1. Manually update with existing location code\\n"
						printf " 2. Set new location code\\n\\n"
						while true; do
							printf " Enter option [1-2 e=Exit] ";read -r continue
							case "$continue" in
								1)		get_dynamic_schedule
										break;;
								2)		set_dynamic_schedule
										break;;
								[Ee])	show_amtm menu;break;;
								*)		printf "\\n input is not an option\\n\\n";;
							esac
						done
					else
						set_dynamic_schedule
					fi
					break;;
			[Ee])	show_amtm " Exited LED control function";break;;
				*)	printf "\\n input is not an option\\n\\n";;
		esac
	done
}
check_services_start(){
	c_j_s /jffs/scripts/services-start
	t_f /jffs/scripts/services-start
	if ! grep -q "^${add}/ledcontrol -set # Added by amtm" /jffs/scripts/services-start; then
		echo "${add}/ledcontrol -set # Added by amtm" >> /jffs/scripts/services-start
	fi
}
get_dynamic_schedule(){
	if [ ! -f /opt/bin/date ]; then
		echo "Installing required Entware module coreutils-date"
		opkg install coreutils-date
	fi
	tmpfile=/tmp/$locCode.out
	c_url "https://weather.com/weather/today/l/$locCode" -o "$tmpfile"

	if grep -q "SunriseSunset" "$tmpfile"; then
		srise=$(grep SunriseSunset "$tmpfile" | grep -oE '((1[0-2]|0?[1-9]):([0-5][0-9]) ?([AaPp][Mm]))' | head -1)
		sset=$(grep SunriseSunset "$tmpfile" | grep -oE '((1[0-2]|0?[1-9]):([0-5][0-9]) ?([AaPp][Mm]))' | tail -1)
		sunrise=$(/opt/bin/date --date="$srise" +%R)
		sunset=$(/opt/bin/date --date="$sset" +%R)

		lcOnh=$(echo ${sunrise:0:2} | sed 's/^0//')
		lcOnm=$(echo ${sunrise:3:2} | sed 's/^0//')
		lcOffh=$(echo ${sunset:0:2} | sed 's/^0//')
		lcOffm=$(echo ${sunset:3:2} | sed 's/^0//')

		rm -f $tmpfile

		check_services_start
		lcMode=on
		locMode=on
		locLastUpd="$(date +"%b %d %T")"
		write_ledcontrol_file
		write_ledcontrol_conf
		checkLed=1
		show_amtm " Dynamic LED control scheduler set"
	else
		show_amtm " Failed to get location code"
	fi
}
set_dynamic_schedule(){
	p_e_l
	printf " To set a dynamic LED schedule go to\\n https://weather.codes/search/\\n and search for your City or ZIP code.\\n"
	printf " The dynamic time will be updated every\\n Saturday and Tuesday.\\n\\n"
	printf " For example, the location code for Luzern,\\n Switzerland is SZXX0021\\n\\n"
	while true; do
		printf " Ready to enter code? [1=Yes e=Exit] ";read -r continue
		case "$continue" in
			1)		p_e_l
					while true; do
						printf " Enter your location code and press Enter ";read -r locCode
						case "$continue" in
							1)		get_dynamic_schedule
									break;;
							[Ee])	show_amtm menu;break;;
							*)		printf "\\n input is not an option\\n\\n";;
						esac
					done
					break;;
			[Ee])	show_amtm menu;break;;
			*)		printf "\\n input is not an option\\n\\n";;
		esac
	done
}
write_ledcontrol_conf(){
	cat <<-EOF > "${add}"/ledcontrol.conf
	# LED control settings file
	lcMode=$lcMode
	lcOnh=$lcOnh
	lcOnm=$lcOnm
	lcOffh=$lcOffh
	lcOffm=$lcOffm
	locMode=$locMode
	locCode=$locCode
	locLastUpd="$locLastUpd"
	EOF
}
write_ledcontrol_file(){
	cat <<-EOF > "${add}"/ledcontrol
	#!/bin/sh
	# ledcontrol, router LED control
	# generated by amtm $version

	# Proudly coded by thelonelycoder and RMerlin
	# Copyright (c) 2016-2066 thelonelycoder - All Rights Reserved
	# https://www.snbforums.com/members/thelonelycoder.25480/
	# With enhanced code from https://github.com/RMerl/asuswrt-merlin.ng/wiki/Scheduled-LED-control

	# amtm is free to use under the GNU General Public License version 3 (GPL-3.0)
	# https://opensource.org/licenses/GPL-3.0
	VERSION=$led_version
	caller="amtm ledcontrol"

	show_help(){
	    echo
	    echo "amtm ledcontrol v\$VERSION, router LED control"
	    echo "path to this file: ${add}/ledcontrol"
	    echo "usage, use full path:"
	    echo "ledcontrol -set        Sets cron jobs and LEDs as per schedule"
	    echo "ledcontrol -on         Turn LEDs on"
	    echo "ledcontrol -off        Turn LEDs off"
	    echo "ledcontrol -upd        Update dynamic location time"
	    echo "ledcontrol -on -p      Turn LEDs on, preserved between reboots"
	    echo "ledcontrol -off -p     Turn LEDs off, preserved between reboots"
	    echo
	}

	[ "\${2}" = -p ] && state="preserved setting" || state="volatile setting"
	case \${1} in
	    -upd)   if [ -f ${add}/ledcontrol.conf ]; then
	                . ${add}/ledcontrol.conf
	                if [ "\$lcMode" = on ] && [ "\$locMode" = on ]; then
	                    tmpfile=/tmp/\$locCode.out
	                    /usr/sbin/curl -fsNL --connect-timeout 10 --retry 3 --max-time 12 "https://weather.com/weather/today/l/\$locCode" -o "\$tmpfile"
	                    if grep -q "SunriseSunset" "\$tmpfile"; then
	                        srise=\$(grep SunriseSunset "\$tmpfile" | grep -oE '((1[0-2]|0?[1-9]):([0-5][0-9]) ?([AaPp][Mm]))' | head -1)
	                        sset=\$(grep SunriseSunset "\$tmpfile" | grep -oE '((1[0-2]|0?[1-9]):([0-5][0-9]) ?([AaPp][Mm]))' | tail -1)
	                        sunrise=\$(/opt/bin/date --date="\$srise" +%R)
	                        sunset=\$(/opt/bin/date --date="\$sset" +%R)
	                        lcOnh=\$(echo \${sunrise:0:2} | sed 's/^0//')
	                        lcOnm=\$(echo \${sunrise:3:2} | sed 's/^0//')
	                        lcOffh=\$(echo \${sunset:0:2} | sed 's/^0//')
	                        lcOffm=\$(echo \${sunset:3:2} | sed 's/^0//')
	                        rm -f \$tmpfile
	                        locLastUpd=\$(date +"%b %d %T")
	                        {
	                        echo "# LED control settings file"
	                        echo "lcMode=\$lcMode"
	                        echo "lcOnh=\$lcOnh"
	                        echo "lcOnm=\$lcOnm"
	                        echo "lcOffh=\$lcOffh"
	                        echo "lcOffm=\$lcOffm"
	                        echo "locMode=\$locMode"
	                        echo "locCode=\$locCode"
	                        echo "locLastUpd=\"\$locLastUpd\""
	                        } >${add}/ledcontrol.conf
	                        logger -s -t "\$caller" "scheduled update of sunset/sunrise time"
	                    else
	                        logger -s -t "\$caller" "failed to get location code"
	                    fi
	                else
	                    logger -s -t "\$caller" "dynamic location not enabled"
	                fi
	            else
	                logger -s -t "\$caller" "No LED control conf file found"
	            fi
	            ;;
	    -set)   if [ -f ${add}/ledcontrol.conf ]; then
	                . ${add}/ledcontrol.conf
	                if [ "\$lcMode" = on ]; then
	                    cru a amtm_LEDcontrol_on "\$lcOnm \$lcOnh * * * ${add}/ledcontrol -on"
	                    cru a amtm_LEDcontrol_off "\$lcOffm \$lcOffh * * * ${add}/ledcontrol -off"
	                    [ "\$locMode" = on ] && cru a amtm_LEDcontrol_update "15 3 * * SAT,TUE /jffs/addons/amtm/ledcontrol -upd"
	                    logger -s -t "\$caller" "cron jobs set"
	                    ntptimer=0
	                    ntptimeout=20
	                    while [ "\$(nvram get ntp_ready)" = 0 ] && [ "\$ntptimer" -lt "\$ntptimeout" ]; do
	                        ntptimer=\$((ntptimer+1))
	                        sleep 1
	                    done
	                    if [ "\$(nvram get ntp_ready)" = 1 ]; then
	                        ledsOn="\$(date --date="\$lcOnh:\$lcOnm" +%s)"
	                        ledsOff="\$(date --date="\$lcOffh:\$lcOffm" +%s)"
	                        now="\$(date +%s)"
	                        if [ "\$ledsOn" -le "\$ledsOff" ]; then
	                            [ "\$ledsOn" -le "\$now" -a "\$now" -lt "\$ledsOff" ] && setLedsOn=1 || setLedsOn=0
	                        else
	                            [ "\$ledsOn" -gt "\$now" -a "\$now" -ge "\$ledsOff" ] && setLedsOn=0 || setLedsOn=1
	                        fi
	                        if [ "\$setLedsOn" = 1 ]; then
	                            if [ "\$(nvram get led_disable)" = 1 ]; then
	                                nvram set led_disable=0
	                                service restart_leds
	                                logger -s -t "\$caller" "LEDs are now on, as per schedule"
	                            fi
	                        elif [ "\$setLedsOn" = 0 ]; then
	                            if [ "\$(nvram get led_disable)" = 0 ]; then
	                                nvram set led_disable=1
	                                service restart_leds
	                                logger -s -t "\$caller" "LEDs are now off, as per schedule"
	                            fi
	                        fi
	                    else
	                        logger -s -t "\$caller" "NTP not ready after 20s timeout, LEDs will switch state with cron"
	                    fi
	                elif [ "\$lcMode" = off ]; then
	                    cru d amtm_LEDcontrol_on
	                    cru d amtm_LEDcontrol_off
	                    cru d amtm_LEDcontrol_update
	                    if [ "\$(nvram get led_disable)" = 1 ]; then
	                        nvram set led_disable=0
	                        nvram commit
	                        service restart_leds
	                        logger -s -t "\$caller" "LED control is off, LEDs are now on"
	                    else
	                        logger -s -t "\$caller" "LED control is off, nothing to do"
	                    fi
	                fi
	            else
	                logger -s -t "\$caller" "No LED control schedule is set, nothing to do"
	            fi
	            ;;
	     -on)   nvram set led_disable=0
	            [ "\${2}" = "-p" ] && nvram commit
	            service restart_leds
	            logger -s -t "\$caller" "LEDs are now on (\$state)"
	            ;;
	    -off)   nvram set led_disable=1
	            [ "\${2}" = "-p" ] && nvram commit
	            service restart_leds
	            logger -s -t "\$caller" "LEDs are now off (\$state)"
	            ;;
	       *)   show_help
	            exit 0
	            ;;
	esac
	EOF
	[ ! -x "${add}"/ledcontrol ] && chmod 0755 "${add}"/ledcontrol
}
#eof
