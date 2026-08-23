#!/bin/sh
#bof
c_url(){ [ -f /opt/bin/curl ] && curlv=/opt/bin/curl || curlv=/usr/sbin/curl;$curlv -fsNL --connect-timeout 10 --retry 3 --max-time 12 "$@";}
run_amtm(){
	if [ ! -f "${add}"/a_fw/amtm.mod ] || [ -f /jffs/scripts/amtm ]; then
		init_amtm
	else
		case "$1" in
			"") 		[ "$am" ] && show_amtm "$am" || show_amtm menu;;
			tpu) 		tpu_check;;
			updcheck) 	upd_check;;
			autoupdate)	auto_script_update;;
			*)			show_amtm "$1";;
		esac
	fi
}
#eof
