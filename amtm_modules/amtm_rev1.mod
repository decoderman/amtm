#!/bin/sh
#bof
c_url(){ /usr/sbin/curl -fsNL --connect-timeout 10 --retry 3 --max-time 12 "$@";}
f_b_url(){ a_m " ! using ${R}fallback server${NC} diversion.ch";amtmURL=https://diversion.ch/amtm_fw;dfc=1;g_m "$@";}
g_m(){
	[ "$1" = amtm.mod ] && set -- "$1" "$2" "${add}/a_fw"
	[ "$3" ] || set -- "$1" "$2" "${add}"
	if [ "$2" = new ]; then
		[ ! -f /tmp/amtm-dl ] && a_m "\\n Getting from $(echo $amtmURL | awk -F[/:] '{print $4}')"
		touch /tmp/amtm-dl
		c_url "$amtmURL/$1" -o "$3/${1}.new"
		if [ -s "$3/${1}.new" ]; then
			if grep -wq '^#bof' "$3/${1}.new" && grep -wq '^#eof' "$3/${1}.new"; then
				mv -f "$3/${1}.new" "$3/$1"
				a_m " - Module ${GN}$1${NC} ${rdl}downloaded"
				sfp=1;dlok=1;dfc=
			else
				rm -f "$3/${1}.new"
				a_m " ! Module ${R}$1${NC} is not an amtm file"
				dlok=0
				[ -z "$dfc" ] && f_b_url "$@"
			fi
		elif [ -f "$3/$1" ]; then
			rm -f "$3/${1}.new"
			a_m " ! Module ${R}$1${NC} ${rdl}download failed, using existing file"
			dlok=0
			[ -z "$dfc" ] && f_b_url "$@"
		else
			rm -f "$3/${1}.new"
			a_m " ! Module ${R}$1${NC} ${rdl}download failed"
			dlok=0
			[ -z "$dfc" ] && f_b_url "$@"
		fi
	fi
	if [ "$2" = include ]; then
		if [ -f "$3/$1" ]; then
			. "$3/$1"
			dlok=1
		else
			g_m "$1" new "$3"
			[ -f "$3/$1" ] && . "$3/$1" || dlok=0
		fi
	fi
}
#eof
