#!/bin/sh
#bof
run_amtm(){
	if [ ! -f "${add}"/a_fw/amtm.mod ] || [ -f /jffs/scripts/amtm ]; then
		init_amtm
	elif [ -z "$1" ]; then
		[ "$am" ] && show_amtm "$am" || show_amtm menu
	elif [ "$1" = tpu ]; then
		su=1;suUpd=0;updErr=;tpu=1
		> /tmp/amtm-tpu-check
		show_amtm >/dev/null 2>&1
	elif [ "$1" = updcheck ]; then
		su=1;suUpd=0;updErr=;tpu=1;updcheck=1
		echo "Available updates:" > /tmp/amtm-tpu-check
		update_firmware
		update_amtm
		show_amtm >/dev/null 2>&1
	else
		show_amtm "$1"
	fi
}
#eof
