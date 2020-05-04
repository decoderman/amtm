#!/bin/sh
#bof
theme_solarized(){ R='[38;2;220;50;47m';R_BG='[48;2;220;50;47m';E_BG='[48;2;220;50;47m';GN='[38;2;133;153;0m';GN_BG='[48;2;7;54;66m';B='[38;2;38;139;210m';GY='[38;2;88;110;117m';NC='[0m';COR=32;}
theme_amtm(){
	p_e_l
	if [ -z "$1" ]; then
		printf " All colors in use are shown.\\n Your current theme is: ${R_BG} $theme ${NC}\\n\\n"
	else
		printf " Select a theme that works best in your\\n SSH client. All colors in use are shown.\\n\\n"
	fi
	themes='standard green blue blue_on_white solarized high_contrast reduced reduced_w reduced_cw reduced_b reduced_cb'
	i=1
	for theme in $themes; do
		ncorr=' '
		case $theme in
			blue)			corr1=-1;corr2=-1;;
			blue_on_white)	corr2=-1;;
			solarized)		corr3=-2;;
			reduced)		corr2=-1;;
			reduced_w)		corr2=-3;;
			reduced_cw)		corr2=-3;;
			reduced_b)		corr2=+5;ncorr=;;
			reduced_cb)		corr1=-2;corr2=+3;ncorr=;;
		esac
		theme_$theme
		printf "%-$((COR+2$corr1))s %-$((COR+4$corr3))s %-$((COR-6))s\\n" "${R_BG}$ncorr$i. $theme" "${NC}${GN_BG} $theme" "${NC}${B} ${theme:0:10}${NC}"
		printf "   %-$((COR-1))s %-$((COR+4$corr2))s %-s\\n" "${E_BG} $theme" "${NC}${GN} $theme" "${NC}${GY} ${theme:0:10}${NC}"
		p_e_l
		i=$((i+1))
		unset corr3 corr2 corr1 ncorr
	done
	theme_basic
	printf "${R_BG}12. basic         ${NC}${GN_BG} basic${NC}\\n"
	p_r_l
	ton=12;noad=
	if [ -f "$divconf" ]; then
		printf "\\n13. Let Diversion set theme ($(grep "THEME=" "$divconf" | sed -e 's/THEME=//'))\\n"
		p_r_l
		ton=13;noad=13
	fi
	printf "\\n The basic and reduced themes use no or fewer\\n colors, service states may not be visible.\\n"
	theme_standard
	while true; do
		if [ -z "$1" ]; then
			printf "\\n Set new amtm theme: [1-$ton e=Exit] ";read -r continue
		else
			printf "\\n Select amtm theme: [1-$ton] ";read -r continue
		fi
		case "$continue" in
			1) theme=standard;break;;
			2) theme=green;break;;
			3) theme=blue;break;;
			4) theme=blue_on_white;break;;
			5) theme=solarized;break;;
			6) theme=high_contrast;break;;
			7) theme=reduced;break;;
			8) theme=reduced_w;break;;
			9) theme=reduced_cw;break;;
			10) theme=reduced_b;break;;
			11) theme=reduced_cb;break;;
			12) theme=basic;break;;
		$noad)	[ -f "${add}"/.amtm_theme ] && rm "${add}"/.amtm_theme
				theme=
				show_amtm " amtm now uses the Diversion theme"
				break;;
		 [Ee]) 	show_amtm menu;;
			*)	printf "\\n input is not an option\\n";;
		esac
	done
	echo "theme=$theme" >"${add}"/.amtm_theme
	[ "$1" ] || show_amtm " changed theme to $theme"
}
#eof
