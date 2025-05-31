#!/bin/sh
#bof
led_control_installed(){
	[ -z "$su" ] && atii=1

	. "${add}"/ledcontrol.conf
	if [ "$cleanup" ]; then
		if [ "$locMode" = on ] && grep -q "locCode" "${add}"/ledcontrol.conf; then
			cru d amtm_LEDcontrol_on;cru d amtm_LEDcontrol_off;cru d amtm_LEDcontrol_update
			lcMode=off
			write_ledcontrol_conf
			/bin/sh "${add}"/led_control.mod -set >/dev/null 2>&1
			unset lcMode locMode locLat locLong locLastUpd
			rm -f "${add}"/ledcontrol.conf
			a_m "\\n - Dynamic LED control disabled, run setup again."
		fi
	fi
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
				[ "$(nvram get led_disable)" = 1 -o "$(nvram get AllLED)" = 0 ] && a_m " LEDs are now on, as per schedule"
			elif [ "$setLedsOn" = 0 ]; then
				[ "$(nvram get led_disable)" = 0 -o "$(nvram get AllLED)" = 1 ] && a_m " LEDs are now off, as per schedule"
			fi
			checkLed=
			[ -z "$runSet" ] && /bin/sh "${add}"/led_control.mod -set
			runSet=
		fi
		[ "$(echo $lcOnm | wc -m)" -lt 3 ] && lcOnmc=$(echo $lcOnm | sed -e 's/^/0/') || lcOnmc=$lcOnm
		[ "$(echo $lcOffm | wc -m)" -lt 3 ] && lcOffmc=$(echo $lcOffm | sed -e 's/^/0/') || lcOffmc=$lcOffm
		if [ "$locMode" = on ]; then
			[ -z "$lcReverse" ] && lMode=D || lMode=RD
		else
			lMode=S
		fi
		lcOnOff="${GN_BG}${lcOnh}:${lcOnmc}${NC} ${E_BG}${lcOffh}:${lcOffmc}${NC} $lMode"
	else
		lcOnOff="${E_BG}disabled${NC}"
	fi

	[ "$(nvram get led_disable)" = 1 -o "$(nvram get AllLED)" = 0 ] && ledState="${E_BG}off${NC}" || ledState="${GN_BG}on${NC}"

	[ -z "$su" -a -z "$ss" ] && printf "${GN_BG} lc${NC} %-9s%-19s\\n" "manage" "LED control $lcOnOff LED $ledState"
	case_lc(){
		led_control_manage
		show_amtm menu
	}
}

install_led_control(){
	p_e_l
	printf " This installs LED control - Scheduled router\\n LED control on your router.\\n\\n"
	printf " Authors: thelonelycoder, RMerlin\\n snbforums.com/forums/asuswrt-merlin-addons.60/?prefix_id=16&starter_id=25480\\n"
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

	lcMode=
	write_ledcontrol_conf

	if [ -f "${add}"/ledcontrol.conf ]; then
		a_m " LED control installed"
		led_control_manage
	else
		am=;show_amtm " LED control installation failed"
	fi
}

c_url(){ [ -f /opt/bin/curl ] && curlv=/opt/bin/curl || curlv=/usr/sbin/curl;$curlv -fsNL --connect-timeout 10 --retry 3 --max-time 12 "$@";}
loc_url(){ [ -f /opt/bin/curl ] && curlv=/opt/bin/curl || curlv=/usr/sbin/curl;$curlv -fsN --connect-timeout 10 --retry 3 --max-time 12 "$@";}

led_control_manage(){
	p_e_l
	printf " This controls the router LEDs\\n\\n"
	printf " Manually setting the LEDs is preserved\\n between reboots, same as the WebUI setting.\\n"
	printf " However, the LED scheduler has precedence\\n over the manual setting.\\n\\n"
	printf " Time can be set statically with a set time\\n or dynamically using sunset/sunrise\\n time for your location.\\n\\n"
	if [ "$lcMode" = on -a "$locMode" = on ]; then
		[ -z "$lcReverse" ] && lModeR=  || lModeR=' reverse'
		printf " Your$lModeR dynamic time coordinate ($lMode) is:\\n $locLat,$locLong\\n The time zone is: $locTimezone\\n The location is: $locName.\\n\\n"
		printf " Last update on: $locLastUpd\\n Next update on: $locNextUpdate\\n\\n"
	fi

	if [ "$lcMode" = on ]; then
		if [ "$(nvram get ledg_scheme)" ]; then
			ledg_text=" Aura RGB theme set in WebUI:"
			case "$(nvram get ledg_scheme)" in
				0)		echo "$ledg_text Off";;
				1)		echo "$ledg_text Gradient";;
				2)		echo "$ledg_text Static";;
				3)		echo "$ledg_text Breathing";;
				4)		echo "$ledg_text Evolution";;
				5)		echo "$ledg_text Rainbow";;
				6)		echo "$ledg_text Wave";;
				7)		echo "$ledg_text Marquee";;
				*)		echo "$ledg_text Custom";;
			esac
			if [ "$(nvram get ledg_night_mode)" -a "$(nvram get ledg_scheme)" != 0 ]; then
				ledg_nm_text=" Aura Night Mode set in WebUI:"
				case "$(nvram get ledg_night_mode)" in
					0)		echo "$ledg_nm_text Off";;
					1)		echo "$ledg_nm_text On";;
				esac
			fi
			echo
		fi
		if [ -z "$lcOnh" -o -z "$lcOnm" -o -z "$lcOffh" -o -z "$lcOffm" ]; then
			printf " Warning: ${R}One or more LED on/off times are incomplete!${NC}\\n\\n"
		fi
		printf " 1. Edit LED scheduler $lcOnOff\\n"
	elif [ "$lcMode" = off ]; then
		printf " 1. ${GN}Enable${NC} LED scheduler\\n"
	else
		printf " 1. Set daily LED ${GN_BG}on${NC} ${E_BG}off${NC} schedule\\n"
	fi
	if [ "$(nvram get led_disable)" = 1 -o "$(nvram get AllLED)" = 0 ]; then
		printf " 2. Manually ${GN}Enable${NC} LEDs now (volatile)\\n"
	else
		printf " 2. Manually ${R}Disable${NC} LEDs now (volatile)\\n"
	fi
	printf " 3. Remove LED control script\\n"
	eok=3;unset noad
	if [ "$lcMode" = on ]; then
		printf " 4. ${R}Disable${NC} LED scheduler\\n"
		eok=4;noad=4
	fi

	while true; do
		printf "\\n Enter option [1-$eok e=Exit] ";read -r continue
		case "$continue" in
			1)		if [ "$lcMode" = on ]; then
						led_control_schedule
					elif [ "$lcMode" = off ]; then
						if [ "$lcOnh" -a "$lcOnm" -a "$lcOffh" -a "$lcOffm" ]; then
							check_services_start
							lcMode=on
							write_ledcontrol_conf
							runSet=0
							/bin/sh "${add}"/led_control.mod -set
							. "${add}"/ledcontrol.conf
							if [ "$lcMode" = on ]; then
								if [ "$(nvram get ledg_scheme_old)" -a "$(nvram get ledg_scheme_old)" != 0 ]; then
									service restart_ledg
									nvram set ledg_scheme=$(nvram get ledg_scheme_old)
								fi

								nvram commit
								service restart_leds

								checkLed=1
								show_amtm " LED control scheduler enabled"
							else
								show_amtm " LED control scheduler could not be enabled"
							fi
						else
							led_control_schedule
						fi
					else
						led_control_schedule
					fi
					break;;
			2)		if [ "$(nvram get led_disable)" = 1 -o "$(nvram get AllLED)" = 0 ]; then
						/bin/sh "${add}"/led_control.mod -on -p >/dev/null 2>&1
						show_amtm " LEDs are now on"
					else
						/bin/sh "${add}"/led_control.mod -off -p >/dev/null 2>&1
						show_amtm " LEDs are now off"
					fi
					break;;
			3)		p_e_l
					echo " This removes the scheduled LED control"
					c_d
					/bin/sh "${add}"/led_control.mod -on -p
					if [ -f /jffs/scripts/services-start ] && grep -q "led_control.mod" /jffs/scripts/services-start; then
						sed -i "\~${add}/led_control.mod.*~d" /jffs/scripts/services-start
						r_w_e /jffs/scripts/services-start
					fi
					if [ -f /jffs/scripts/post-mount ] && grep -q "led_control.mod" /jffs/scripts/post-mount; then
						sed -i "\~${add}/led_control.mod.*~d" /jffs/scripts/post-mount
						r_w_e /jffs/scripts/post-mount
					fi
					cru d amtm_LEDcontrol_on
					cru d amtm_LEDcontrol_off
					cru d amtm_LEDcontrol_update
					cru d amtm_LEDcontrol_set
					rm "${add}"/led*
					unset lcMode locMode locLat locLong locLastUpd
					show_amtm " LED scheduler removed\\n LEDs are now on"
					break;;
			$noad)	lcMode=off
					write_ledcontrol_conf
					[ "$(nvram get led_disable)" = 1 -o "$(nvram get AllLED)" = 0 ] && a_m " LEDs are now on"
					/bin/sh "${add}"/led_control.mod -set >/dev/null 2>&1
					show_amtm " LED control scheduler disabled"
					break;;
			[Ee])	show_amtm menu;break;;
			*)		printf "\\n input is not an option\\n";;
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
	rDynEdit=Use
	if [ "$lcMode" = on ]; then
		if [ -z "$locMode" -o "$locMode" = off ]; then
			lcMan=$lcOnOff
			manEdit=Edit
		fi
		[ "$locMode" = on ] && lcDyn=$lcOnOff
		if [ -z "$lcOnh" -o -z "$lcOnm" -o -z "$lcOffh" -o -z "$lcOffm" ]; then
			printf " Warning: ${R}One or more LED on/off times are incomplete!${NC}\\n\\n"
		fi
	fi



	printf " 1. $manEdit Static time $lcMan\\n"
	eok=3;noad=2;noadv=3
	if [ -f /opt/bin/opkg ]; then
		if [ -z "$lcReverse" ]; then
			[ "$locMode" = on ] && dynEdit=Edit
			lcDynNR=$lcDyn
			lcDynR=
		else
			[ "$locMode" = on ] && rDynEdit=Edit
			lcDynNR=
			lcDynR=$lcDyn
		fi
		printf " 2. $dynEdit Dynamic time $lcDynNR\\n    This uses the sunset/sunrise time\\n    from sunrisesunset.io for your coordinates\\n"
		printf " 3. $rDynEdit reverse Dynamic time $lcDynR\\n    Same as above but with reversed time.\\n    LEDs are on at night and off during the day.\n"
	else
		eok=1;noad=;noadv=
		printf " ${GY}2. Use Dynamic time\\n    Feature requires Entware installed${NC}\\n"
	fi

	while true; do
		printf "\\n Enter option [1-$eok e=Exit] ";read -r lcOnh
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
									unset locName lcReverse
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
			$noad)	if [ "$locLat" -a "$locLong" ]; then
						p_e_l
						printf " Your coordinates are: $locLat,$locLong\\n\\n Sunset/Sunrise time update is automatic.\\n Last update on: $locLastUpd\\n Next update on: $locNextUpdate\\n\\n"
						printf " 1. Manually update with existing coordinates\\n"
						printf " 2. Set new coordinates\\n\\n"
						while true; do
							printf " Enter option [1-2 e=Exit] ";read -r continue
							case "$continue" in
								1)		lcReverse=
										get_dynamic_schedule
										break;;
								2)		lcReverse=
										set_dynamic_schedule
										break;;
								[Ee])	show_amtm menu;break;;
								*)		printf "\\n input is not an option\\n\\n";;
							esac
						done
					else
						lcReverse=
						set_dynamic_schedule
					fi
					break;;
			$noadv)	if [ "$locLat" -a "$locLong" ]; then
						p_e_l
						printf " Your coordinates are: $locLat,$locLong\\n\\n Sunset/Sunrise time update is automatic.\\n Last update on: $locLastUpd\\n Next update on: $locNextUpdate\\n\\n"
						printf " 1. Manually update with existing coordinates\\n"
						printf " 2. Set new coordinates\\n\\n"
						while true; do
							printf " Enter option [1-2 e=Exit] ";read -r continue
							case "$continue" in
								1)		lcReverse=on
										get_dynamic_schedule
										break;;
								2)		lcReverse=on
										set_dynamic_schedule
										break;;
								[Ee])	show_amtm menu;break;;
								*)		printf "\\n input is not an option\\n\\n";;
							esac
						done
					else
						lcReverse=on
						set_dynamic_schedule
					fi
					break;;
			[Ee])	show_amtm " Exited LED control function";break;;
				*)	printf "\\n input is not an option\\n";;
		esac
	done
}

check_services_start(){
	if [ "$locMode" = on ]; then
		if [ -f /jffs/scripts/services-start ] && grep -q "led_control.mod" /jffs/scripts/services-start; then
			sed -i "\~${add}/led_control.mod.*~d" /jffs/scripts/services-start
			r_w_e /jffs/scripts/services-start
		fi
		c_j_s /jffs/scripts/post-mount
		if ! grep -q "^/bin/sh ${add}/led_control.mod -set # Added by amtm" /jffs/scripts/post-mount; then
			sed -i "\~${add}/led.*~d" /jffs/scripts/post-mount
			echo "/bin/sh ${add}/led_control.mod -set # Added by amtm" >> /jffs/scripts/post-mount
		fi
	else
		if [ -f /jffs/scripts/post-mount ] && grep -q "led_control.mod" /jffs/scripts/post-mount; then
			sed -i "\~${add}/led_control.mod.*~d" /jffs/scripts/post-mount
			r_w_e /jffs/scripts/post-mount
		fi
		c_j_s /jffs/scripts/services-start
		if ! grep -q "^/bin/sh ${add}/led_control.mod -set # Added by amtm" /jffs/scripts/services-start; then
			sed -i "\~${add}/led.*~d" /jffs/scripts/services-start
			echo "/bin/sh ${add}/led_control.mod -set # Added by amtm" >> /jffs/scripts/services-start
		fi
	fi
}

get_dynamic_schedule(){
	lcMode=on
	locMode=on
	check_services_start
	write_ledcontrol_conf
	rm -f "${add}"/ledcontrol.json
	/bin/sh "${add}"/led_control.mod -set
	checkLed=1
	. "${add}"/ledcontrol.conf
	locName=$(loc_url "https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=$locLat&lon=$locLong&zoom=10" | jq '.display_name' | sed 's/"//g')
	[ "$locName" = null ] && locName=Unknown
	write_ledcontrol_conf
	show_amtm " Dynamic LED control set for coordinates\\n $locLat,$locLong\\n in $locName."
}

get_json_file(){
	getCount=$((getCount+1))
	if [ "$getCount" -lt 4 ]; then
		[ "$getCount" -gt 1 ] && sleep 1
		c_url "https://api.sunrisesunset.io/json?lat=$locLat&lng=$locLong&time_format=24&date_start=$todayDate&date_end=$nextMonthDate" -o "$jsonFile"

		if grep -q "OK" "$jsonFile"; then
			sunrise=$(jq ".results[] | select(.date == \"$todayDate\") | ".sunrise"" $jsonFile | sed 's/"//g')
			sunset=$(jq ".results[] | select(.date == \"$todayDate\") | ".sunset"" $jsonFile | sed 's/"//g')
			if [ "$sunrise" = null -o "$sunset" = null ]; then
				logger -s -t "$caller" "failed to extract sunrise or sunset time"
				get_json_file
			else
				locTimezone=$(jq ".results[] | select(.date == \"$todayDate\") | ".timezone"" $jsonFile | sed 's/"//g')
				set_dynamic_led
				locNextUpdate=$(/opt/bin/date -d "next month" +'%B %d, %Y')
				locLastUpd="$(date +"%B %d %T")"
				write_ledcontrol_conf
				logger -s -t "$caller" "updated sunset/sunrise time file"
				/bin/sh "${add}"/led_control.mod -set
			fi
		else
			logger -s -t "$caller" "failed to get location file"
		fi
	else
		logger -s -t "$caller" "failed to extract sunrise or sunset time after three attempts, dynamic LEDs set to OFF"
		getCount=
		lcMode=off
		write_ledcontrol_conf
		/bin/sh "${add}"/led_control.mod -set
	fi
}

set_dynamic_schedule(){
	p_e_l
	printf " To set a dynamic LED schedule enter the complete\\n longitude and latitude coordinates for your location.\\n\\n"
	printf " Using Google maps, tap or click on desired\\n location and copy the complete coordinates.\\n\\n"
	printf " Or get your coordinates from https://sunrisesunset.io\\n Search for your City and copy the complete\\n"
	printf " longitude and latitude coordinates shown\\n below your City name.\\n\\n"
	printf " For example, the complete latitude and longitude\\n coordinates for Luzern, Switzerland are\\n 47.05048, 8.30635\\n\\n"
	while true; do
		printf " Ready to enter coordinates? [1=Yes e=Exit] ";read -r continue
		case "$continue" in
			1)		p_e_l
					if [ ! -f /opt/bin/grep ]; then
						logger -s -t "$caller" "Installing required Entware package grep"
						opkg install grep
					fi
					coords_loop(){
						while true; do
							printf " Enter complete coordinates and press Enter: ";read -r coordinate
							case "$coordinate" in
								[Ee])	show_amtm menu;break;;
								*)		coordinate=$(echo $coordinate | sed 's/ //g')
										if echo "$coordinate" | /opt/bin/grep -P -q '^[-+]?([1-8]?\d(\.\d+)?|90(\.0+)?),\s*[-+]?(180(\.0+)?|((1[0-7]\d)|([1-9]?\d))(\.\d+)?)$'; then
											locLat=$(echo $coordinate | cut -d',' -f1)
											locLong=$(echo $coordinate | cut -d',' -f2)
											get_dynamic_schedule
										else
											p_e_l
											printf " Entry is not a valid coordinate.\\n\\n"
											coords_loop
										fi
										break;;
							esac
						done
					}
					coords_loop
					break;;
			[Ee])	show_amtm menu;break;;
			*)		printf "\\n input is not an option\\n\\n";;
		esac
	done
}

set_dynamic_led(){
	if [ -z "$lcReverse" ]; then
		lcOnh=$(echo ${sunrise:0:2} | sed 's/^0//')
		lcOnm=$(echo ${sunrise:3:2} | sed 's/^0//')
		lcOffh=$(echo ${sunset:0:2} | sed 's/^0//')
		lcOffm=$(echo ${sunset:3:2} | sed 's/^0//')
	else
		lcOnh=$(echo ${sunset:0:2} | sed 's/^0//')
		lcOnm=$(echo ${sunset:3:2} | sed 's/^0//')
		lcOffh=$(echo ${sunrise:0:2} | sed 's/^0//')
		lcOffm=$(echo ${sunrise:3:2} | sed 's/^0//')
	fi
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
	locLat=$locLat
	locLong=$locLong
	lcReverse=$lcReverse
	locName="$locName"
	locTimezone="$locTimezone"
	locLastUpd="$locLastUpd"
	locNextUpdate="$locNextUpdate"
	EOF
}

set_lc_def(){
	add=/jffs/addons/amtm
	caller="amtm LED control"
	v_c(){ echo "$@" | awk -F. '{ printf("%d%03d%03d%03d\n", $1,$2,$3,$4); }';}
	if [ -f "${add}"/ledcontrol.conf ]; then
		. "${add}"/ledcontrol.conf
		if [ "$locMode" = on ]; then
			if [ -f /opt/bin/opkg ]; then
				if [ ! -f /opt/bin/date ]; then
					logger -s -t "$caller" "Installing required Entware package coreutils-date"
					opkg install coreutils-date
				fi
				if [ ! -f /opt/bin/grep ]; then
					logger -s -t "$caller" "Installing required Entware package grep"
					opkg install grep
				fi
				if [ ! -f /opt/bin/jq ]; then
					logger -s -t "$caller" "Installing required Entware package jq, a JSON processor"
					opkg install jq
				fi
				jsonFile="${add}"/ledcontrol.json
				todayDate=$(date +'%Y-%m-%d')
				nextMonthDate=$(/opt/bin/date -d "next month" +'%Y-%m-%d')
			else
				logger -s -t "$caller" "Entware is missing, disabling LED control"
				lcMode=off
				locMode=off
				write_ledcontrol_conf
				/bin/sh "${add}"/led_control.mod -set
			fi
		fi
	else
		logger -s -t "$caller" "No LED control config file found"
	fi
	[ "${2}" = -p ] && state="preserved setting" || state="volatile setting"
}

case "${1}" in
	"")   	set_lc_def
			printf "\\namtm LED control - Scheduled router LED control\\nusage, use full file path: sh ${add}/led_control.mod\\n\\n"
			printf "led_control.mod -set        Sets cron jobs and LEDs as per schedule\\nled_control.mod -on         Turn LEDs on\\n"
			printf "led_control.mod -off        Turn LEDs off\\n"
			printf "led_control.mod -on -p      Turn LEDs on, preserved between reboots\\nled_control.mod -off -p     Turn LEDs off, preserved between reboots\\n\\n"
			;;
	-set)   set_lc_def $@
			if [ "$lcMode" = on ]; then
				ntptimer=0
				ntptsync=0
				ntptimeout=10

				while [ "$(nvram get ntp_ready)" = 0 ] && [ "$ntptimer" -lt "$ntptimeout" ]; do
					ntptimer=$((ntptimer+1))
					sleep 1
					if [ "$ntptsync" -lt "$ntptimeout" ]; then
						logger -t "$TAG" "trying force-sync of NTP, restarting service, sync counter at $ntptsync"
						service restart_ntpc
						ntptsync=$((ntptsync+1))
						sleep 5
					fi
				done

				if [ "$locMode" = on ]; then
					cru a amtm_LEDcontrol_set "10 0 * * * /bin/sh ${add}/led_control.mod -set"
					if [ "$(nvram get ntp_ready)" = 1 ]; then
						if [ -f "$jsonFile" ] && grep -q "$todayDate" $jsonFile; then
							sunrise=$(jq ".results[] | select(.date == \"$todayDate\") | ".sunrise"" $jsonFile | sed 's/"//g')
							sunset=$(jq ".results[] | select(.date == \"$todayDate\") | ".sunset"" $jsonFile | sed 's/"//g')

							if [ "$sunrise" = null -o "$sunset" = null ]; then
								get_json_file
							else
								set_dynamic_led
								if [ "$lcOnh" -a "$lcOnm" -a "$lcOffh" -a "$lcOffm" ]; then
									write_ledcontrol_conf

									cru a amtm_LEDcontrol_on "$lcOnm $lcOnh * * * /bin/sh ${add}/led_control.mod -on"
									cru a amtm_LEDcontrol_off "$lcOffm $lcOffh * * * /bin/sh ${add}/led_control.mod -off"

									logger -s -t "$caller" "cron jobs set for today"

									ledsOn="$(date --date="$lcOnh:$lcOnm" +%s)"
									ledsOff="$(date --date="$lcOffh:$lcOffm" +%s)"
									now="$(date +%s)"
									if [ "$ledsOn" -le "$ledsOff" ]; then
										[ "$ledsOn" -le "$now" -a "$now" -lt "$ledsOff" ] && setLedsOn=1 || setLedsOn=0
									else
										[ "$ledsOn" -gt "$now" -a "$now" -ge "$ledsOff" ] && setLedsOn=0 || setLedsOn=1
									fi
									if [ "$setLedsOn" = 1 ]; then
										if [ "$(nvram get led_disable)" = 1 -o "$(nvram get AllLED)" = 0 ]; then
											/bin/sh "${add}"/led_control.mod -on >/dev/null 2>&1
										fi
									elif [ "$setLedsOn" = 0 ]; then
										if [ "$(nvram get led_disable)" = 0 -o "$(nvram get AllLED)" = 1 ]; then
											/bin/sh "${add}"/led_control.mod -off >/dev/null 2>&1
										fi
									fi
								else
									get_json_file
								fi
							fi
						else
							get_json_file
						fi
					else
						logger -s -t "$caller" "NTP not ready after 20s timeout, LEDs will switch state with cron"
					fi
				else
					if [ "$lcOnh" -a "$lcOnm" -a "$lcOffh" -a "$lcOffm" ]; then
						cru a amtm_LEDcontrol_on "$lcOnm $lcOnh * * * /bin/sh ${add}/led_control.mod -on"
						cru a amtm_LEDcontrol_off "$lcOffm $lcOffh * * * /bin/sh ${add}/led_control.mod -off"
						logger -s -t "$caller" "cron jobs set"
						if [ "$(nvram get ntp_ready)" = 1 ]; then
							ledsOn="$(date --date="$lcOnh:$lcOnm" +%s)"
							ledsOff="$(date --date="$lcOffh:$lcOffm" +%s)"
							now="$(date +%s)"
							if [ "$ledsOn" -le "$ledsOff" ]; then
								[ "$ledsOn" -le "$now" -a "$now" -lt "$ledsOff" ] && setLedsOn=1 || setLedsOn=0
							else
								[ "$ledsOn" -gt "$now" -a "$now" -ge "$ledsOff" ] && setLedsOn=0 || setLedsOn=1
							fi
							if [ "$setLedsOn" = 1 ]; then
								if [ "$(nvram get led_disable)" = 1 -o "$(nvram get AllLED)" = 0 ]; then
									/bin/sh "${add}"/led_control.mod -on >/dev/null 2>&1
								fi
							elif [ "$setLedsOn" = 0 ]; then
								if [ "$(nvram get led_disable)" = 0 -o "$(nvram get AllLED)" = 1 ]; then
									/bin/sh "${add}"/led_control.mod -off >/dev/null 2>&1
								fi
							fi
						else
							logger -s -t "$caller" "NTP not ready after 20s timeout, LEDs will switch state with cron"
						fi
					else
						logger -s -t "$caller" "Unable to set LED jobs, missing one or more on/off times, disablind LED control"
						lcMode=off
						write_ledcontrol_conf
						/bin/sh "${add}"/led_control.mod -set
					fi
				fi
			elif [ "$lcMode" = off ]; then
				cru d amtm_LEDcontrol_on
				cru d amtm_LEDcontrol_off
				cru d amtm_LEDcontrol_set
				/bin/sh "${add}"/led_control.mod -on -p
				if [ -f /jffs/scripts/services-start ] && grep -q "led_control.mod" /jffs/scripts/services-start; then
					sed -i "\~${add}/led_control.mod.*~d" /jffs/scripts/services-start
					r_w_e /jffs/scripts/services-start
				fi
				if [ -f /jffs/scripts/post-mount ] && grep -q "led_control.mod" /jffs/scripts/post-mount; then
					sed -i "\~${add}/led_control.mod.*~d" /jffs/scripts/post-mount
					r_w_e /jffs/scripts/post-mount
				fi
			fi
			;;
	 -on)   set_lc_def $@
			if [ "$(v_c $(nvram get firmver))" -ge "$(v_c 3.0.0.6)" ] && [ "$(nvram get rc_support | grep wifi7)" ]; then
				# wifi7 routers
				nvram set led_disable=0
				nvram set AllLED=1
				service restart_leds

				if [ "$(nvram get ledg_scheme_old)" -a "$(nvram get ledg_scheme_old)" = 0 ]; then
					service restart_ledg
					nvram set ledg_scheme=$(nvram get ledg_scheme_old)
				fi
				[ "${2}" = "-p" ] && nvram commit
			elif [ "$(v_c $(nvram get firmver))" -ge "$(v_c 3.0.0.6)" ]; then
				#wifi6 routers
				nvram set led_disable=0
				nvram set AllLED=1
				service restart_leds
				if [ "$(nvram get ledg_scheme)" -a "$(nvram get ledg_scheme_old)" ]; then
					service restart_ledg
					nvram set ledg_scheme=$(nvram get ledg_scheme_old)
				fi
				[ "${2}" = "-p" ] && nvram commit
			else
				# older routers
				nvram set led_disable=0
				[ "${2}" = "-p" ] && nvram commit
				service restart_leds
			fi
			logger -s -t "$caller" "LEDs are now on ($state)"
			;;
	-off)   set_lc_def $@
			if [ "$(v_c $(nvram get firmver))" -ge "$(v_c 3.0.0.6)" ]; then
				#wifi6 and wifi7 routers
				nvram set led_disable=1
				nvram set AllLED=0
				[ "$(nvram get ledg_scheme)" ] && nvram set ledg_scheme_old=$(nvram get ledg_scheme)
			else
				# older routers
				nvram set led_disable=1
			fi
			[ "${2}" = "-p" ] && nvram commit
			service restart_leds
			logger -s -t "$caller" "LEDs are now off ($state)"
			;;
esac
#eof
