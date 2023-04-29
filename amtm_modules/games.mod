#!/bin/sh
#bof
games_installed(){
	if [ "$more" = "more" ]; then sgs=hide;echo;else sgs=show;fi
	printf "${GN_BG} g ${NC} %-9s%-21s%${COR}s\\n" "$sgs" "router Games" "${GN_BG} gr${NC} remove"

	case_g(){

		trap_game(){
			clear
			trap_ctrl(){
				show_amtm menu
			}
			trap trap_ctrl 2
			$1
			trap - 2
			show_amtm menu
		}

		rm_game(){
			echo
			opkg remove	$1
			echo
			sed -i "/^$1/d" "${add}"/games/games.conf
			sleep 2
			show_amtm " $1 removed"
		}

		[ -z "$ss" ] && printf "\\n To exit a game, press CTRL+C or q or ESC.\\n To remove a game, add r to option, e.g. ${GN_BG}g2r${NC}\\n"
		games='spacer
		/opt/bin/shtris shtris g1 shtris¦-¦Tetris¦by¦user¦DDD
		/opt/bin/angband angband g2 Angband¦-¦Text¦based¦Dungeon
		/opt/bin/phear cavezofphear g3 cavezofphear¦-¦CAVEZ¦of¦PHEAR
		/opt/bin/crawl crawl g4 crawl¦-¦Dungeon¦Crawl¦Stone¦Soup
		/opt/bin/gnuchess gnuchess g5 gnuchess¦-¦GNU¦Chess
		spacer
		/opt/bin/nethack nethack g6 nethack¦-¦Dungeons¦and¦Dragons
		/opt/bin/sst superstartrek g7 superstartrek¦-¦Super¦Star¦Trek
		/opt/bin/ttysolitaire tty-solitaire g8 tty-solitaire¦-¦klondlike¦solitaire
		/opt/bin/vitetris vitetris g9 vitetris¦-¦Tetris¦by¦Victor¦Nilsson
		/opt/bin/dungeon zork g10 zork¦-¦Text¦adventure¦game'

		IFS='
		'
		set -f
		for i in $games; do
			if [ "$i" = spacer ]; then
				echo
			else
				scriptloc=$(echo $i | awk '{print $1}')
				if [ -f "$scriptloc" ]; then
					if ! grep -q "$(echo $i | awk '{print $2}' | sed 's/¦/ /g')" "${add}"/games/games.conf; then
						echo "$(echo $i | awk '{print $2}' | sed 's/¦/ /g')" >>"${add}"/games/games.conf
					fi
					f3="$(echo $i | awk '{print $3}')"
					[ "$(echo $f3 | wc -m)" -gt 3 ] && ssp= || ssp=' '
					printf " ${GN_BG}${f3}$ssp${NC} %-9s%s\\n" "play" "$(echo $i | awk '{print $4}' | sed 's/¦/ /g')"
					case $f3 in
						[Gg]1|[Gg]1r)	case_g1(){ if [ "$(echo $selection | grep r)" ]; then rm -f /opt/bin/shtris;sed -i "/^shtris/d" "${add}"/games/games.conf;show_amtm " shtris removed";else trap_game '/bin/sh /opt/bin/shtris';fi;};;
						[Gg]2|[Gg]2r)	case_g2(){ [ "$(echo $selection | grep r)" ] && rm_game angband || trap_game /opt/bin/angband;};;
						[Gg]3|[Gg]3r)	case_g3(){ [ "$(echo $selection | grep r)" ] && rm_game cavezofphear || trap_game /opt/bin/phear;};;
						[Gg]4|[Gg]4r)	case_g4(){ [ "$(echo $selection | grep r)" ] && rm_game crawl || trap_game /opt/bin/crawl;};;
						[Gg]5|[Gg]5r)	case_g5(){ [ "$(echo $selection | grep r)" ] && rm_game gnuchess || trap_game /opt/bin/gnuchess;};;
						[Gg]6|[Gg]6r)	case_g6(){ [ "$(echo $selection | grep r)" ] && rm_game nethack || trap_game /opt/bin/nethack;};;
						[Gg]7|[Gg]7r)	case_g7(){ [ "$(echo $selection | grep r)" ] && rm_game superstartrek || trap_game /opt/bin/sst;};;
						[Gg]8|[Gg]8r)	case_g8(){ [ "$(echo $selection | grep r)" ] && rm_game tty-solitaire || trap_game /opt/bin/ttysolitaire;show_amtm menu;};;
						[Gg]9|[Gg]9r)	case_g9(){ [ "$(echo $selection | grep r)" ] && rm_game vitetris || trap_game /opt/bin/vitetris;};;
						[Gg]10|[Gg]10r)	case_g10(){ [ "$(echo $selection | grep r)" ] && rm_game zork || trap_game /opt/bin/dungeon;};;
					esac
				else
					f3="$(echo $i | awk '{print $3}')"
					[ "$(echo $i | awk '{print $2}')" = shtris ] && sed -i "/^shtris/d" "${add}"/games/games.conf
					[ "$(echo $f3 | wc -m)" -gt 3 ] && ssp= || ssp=' '
					printf " ${E_BG}${f3}$ssp${NC} %-9s%s\\n" "install" "$(echo $i | awk '{print $4}' | sed 's/¦/ /g')"
					case $f3 in
						[Gg]1)		case_g1(){ c_e shtris; p_e_l;printf " This installs shtris - Tetris optimized for Asuswrt-Merlin\\n on your router.\\n\\n Author: DDD\\n https://www.snbforums.com/threads/i-may-be-the-first-person-to-play-games-on-asus-router.79319/\\n"
									printf "\\n Source: https://github.com/l11/router-tetris\\n";c_d
									c_url https://raw.githubusercontent.com/l11/router-tetris/main/shtris -o /opt/bin/shtris;[ -f /opt/bin/shtris ] && show_amtm " shtris installed" || show_amtm " shtris install failed";};;
						[Gg]2)		case_g2(){ c_e Angband; p_e_l;echo " This installs";opkg list | grep ^angband | sed -e 's/^/ /';printf " on your router.\\n\\n Source: Entware package\\n";c_d
									opkg install angband;[ -f /opt/bin/angband ] && show_amtm " angband installed" || show_amtm " angband install failed";};;
						[Gg]3)		case_g3(){ c_e cavezofphear; p_e_l;echo " This installs";opkg list | grep ^cavezofphear | sed -e 's/^/ /';printf " on your router.\\n\\n Source: Entware package\\n";c_d
									opkg install cavezofphear;[ -f /opt/bin/phear ] && show_amtm " cavezofphear installed" || show_amtm " cavezofphear install failed";};;
						[Gg]4)		case_g4(){ c_e crawl; p_e_l;echo " This installs";opkg list | grep ^crawl | sed -e 's/^/ /';printf " on your router.\\n\\n Source: Entware package\\n";c_d
									opkg install crawl;[ -f /opt/bin/crawl ] && show_amtm " crawl installed" || show_amtm " crawl install failed";};;
						[Gg]5)		case_g5(){ c_e gnuchess; p_e_l;echo " This installs";opkg list | grep ^gnuchess | sed -e 's/^/ /';printf " on your router.\\n\\n Source: Entware package\\n";c_d
									opkg install gnuchess;[ -f /opt/bin/gnuchess ] && show_amtm " gnuchess installed" || show_amtm " gnuchess install failed";};;
						[Gg]6)		case_g6(){ c_e nethack; p_e_l;echo " This installs";opkg list | grep ^nethack | sed -e 's/^/ /';printf " on your router.\\n\\n Source: Entware package\\n";c_d
									opkg install nethack;[ -f /opt/bin/nethack ] && show_amtm " nethack installed" || show_amtm " nethack install failed";};;
						[Gg]7)		case_g7(){ c_e superstartrek; p_e_l;echo " This installs";opkg list | grep ^superstartrek | sed -e 's/^/ /';printf " on your router.\\n\\n Source: Entware package\\n";c_d
									opkg install superstartrek;[ -f /opt/bin/sst ] && show_amtm " superstartrek installed" || show_amtm " superstartrek install failed";};;
						[Gg]8)		case_g8(){ c_e tty-solitaire; p_e_l;echo " This installs";opkg list | grep ^tty-solitaire | sed -e 's/^/ /';printf " on your router.\\n\\n Source: Entware package\\n";c_d
									opkg install tty-solitaire;[ -f /opt/bin/ttysolitaire ] && show_amtm " tty-solitaire installed" || show_amtm " tty-solitaire install failed";};;
						[Gg]9)		case_g9(){ c_e vitetris; p_e_l;echo " This installs";opkg list | grep ^vitetris | sed -e 's/^/ /';printf " on your router.\\n\\n Source: Entware package\\n";c_d
									opkg install vitetris;[ -f /opt/bin/vitetris ] && show_amtm " vitetris installed" || show_amtm " vitetris install failed";};;
						[Gg]10)		case_g10(){ c_e zork; p_e_l;echo " This installs";opkg list | grep ^zork | sed -e 's/^/ /';printf " on your router.\\n\\n Source: Entware package\\n";c_d
									opkg install zork;[ -f /opt/bin/dungeon ] && show_amtm " zork installed" || show_amtm " zork install failed";};;
					esac
				fi
			fi
		done
		set +f
		unset IFS
	}
	[ "$more" = "more" ] &&	case_g

	case_gr(){
		p_e_l
		if [ -s "${add}"/games/games.conf ]; then
			printf " The following game(s) are still installed on\\n this router:\\n"
			cat "${add}"/games/games.conf | sed -e 's/^/ - /'
			printf "\\n All games have to be removed before the game\\n section can be removed.\\n\\n To remove a game, add r to option, e.g. ${GN_BG}g2r${NC}\\n"
			p_e_t "return to menu"
			show_amtm menu
		fi
		printf " This removes the game section from your router\\n"
		c_d
		r_m games.mod
		rm -rf "${add}"/games
		show_amtm " Games section removed"
	}
}
install_Games(){
	p_e_l
	printf " This provides a list of games to install and\\n play on your router.\\n Fun for the adventurous!\\n\\n Games play directly in the terminal, slower\\n or older routers may come to their limit.\\n You have been warned!\\n"
	echo
	echo " Author: thelonelycoder"
	echo " https://www.snbforums.com/forums/asuswrt-merlin-addons.60/?prefix_id=16"
	c_d

	mkdir -p "${add}"/games
	touch "${add}"/games/games.conf

	sleep 2
	if [ -f "${add}"/games/games.conf ]; then
		more=more
		show_amtm " Games section installed"
	else
		am=;show_amtm " Games section install failed"
	fi
}
#eof
