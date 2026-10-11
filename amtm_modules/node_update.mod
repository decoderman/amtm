#!/bin/sh
#bof

find_nodes(){
	[ "$1" = Reset ] && rm -f "${add}"/nodeUpdate
	[ "$1" = Silent ] && noshow=1 || noshow=
	[ ! -f "${add}"/nodeUpdate ] && touch "${add}"/nodeUpdate
	read_node_vars
	[ -z "$noshow" ] && p_e_l
	[ "$1" = 'Scanning' ] && am=
	[ -z "$noshow" ] && printf " $1 Nodes..."
	if [ "$AIMESH_NODES" ]; then
		for node in $AIMESH_NODES; do
			NodeModel="${node%%|*}"
			NodeIP="${node#*|}"
			grepNode="$NodeModel|$(echo $NodeIP | sed -e 's/\./\\./g')"
			if /usr/bin/ssh -p "$SSH_PORT" -i "$SSH_KEY" -o StrictHostKeyChecking=no -o BatchMode=yes "${NODE_USER}@${NodeIP}" 2>&1 >/dev/null \
				"[ -f /usr/sbin/amtm ] && echo MerlinOK || echo MerlinNOK;[ -f /jffs/addons/amtm/a_fw/amtm.mod ] && echo amtmOK || echo amtmNOK" \
				2>&1 >/dev/null >> /tmp/amtmNodecheck; then
				if grep 'MerlinOK' /tmp/amtmNodecheck >/dev/null && grep 'amtmOK' /tmp/amtmNodecheck >/dev/null; then
					if ! grep "$grepNode$\|#$grepNode$" "${add}"/nodeUpdate >/dev/null; then
						echo "$node" >>"${add}"/nodeUpdate
					fi
				elif grep 'MerlinOK' /tmp/amtmNodecheck >/dev/null && grep 'amtmNOK' /tmp/amtmNodecheck >/dev/null; then
					[ -z "$noshow" ] && a_m " AiMesh Node ${R}$NodeModel${NC} @ $NodeIP:\\n amtm is not initialized on the Node.\\n"
					sed -i "/$grepNode/d" "${add}"/nodeUpdate
				elif grep 'MerlinNOK' /tmp/amtmNodecheck >/dev/null; then
					[ -z "$noshow" ] && a_m " AiMesh Node ${R}$NodeModel${NC} @ $NodeIP:\\n Not a (newer) Asuswrt-Merlin Node.\\n"
					sed -i "/$grepNode/d" "${add}"/nodeUpdate
				else
					[ -z "$noshow" ] && a_m " AiMesh Node ${R}$NodeModel${NC} @ $NodeIP:\\n Has an unspecified problem.\\n"
					sed -i "/$grepNode/d" "${add}"/nodeUpdate
				fi
			else
				[ -z "$noshow" ] && a_m " AiMesh Node $NodeModel @ $NodeIP\\n not found.\\n"
			fi
			rm -f /tmp/amtmNodecheck
		done



		if [ -s "${add}"/nodeUpdate ]; then
			[ -z "$noshow" ] && printf " found ${GN}$(wc -l < "${add}"/nodeUpdate)${NC} supported Node(s)\\n\\n$am"
			am=
		else
			[ -z "$noshow" ] && show_amtm " No AiMesh Nodes detected!"
		fi
		[ ! -f "${add}"/nodeUpdate.conf ] && echo updateNodes=enabled >>"${add}"/nodeUpdate.conf
		nodesCount=$(echo "$AIMESH_NODES" | grep -o "|" | wc -l)
		if [ -z "$knownNodesCount" ]; then
			echo "knownNodesCount=$nodesCount" >>"${add}"/nodeUpdate.conf
		elif [ "$nodesCount" != "$knownNodesCount" ]; then
			sed -i "s/knownNodesCount.*/knownNodesCount=$nodesCount/g" "${add}"/nodeUpdate.conf
		fi
		knownNodesCount=$nodesCount
		[ -z "$noshow" ] && show_node_options
	else
		[ -z "$noshow" ] && show_amtm " No AiMesh Nodes detected"
	fi
}

read_node_vars(){
    SSH_KEY="/root/.ssh/id_dropbear"
	NODE_USER=$(nvram get http_username)
	SSH_PORT=$(nvram get sshd_port)
	SSH_PORT=${SSH_PORT:-22}
	AIMESH_NODES=$(nvram get asus_device_list | sed 's/</\n/g' | grep '>2$' | awk -F '>' '{print $2 "|" $3}' |  sort -t . -k 4,4n)
}

update_nodes(){
	if [ -f "/root/.ssh/id_dropbear" ]; then
		read_node_vars
		nv_lan_ipaddr=$(nvram get lan_ipaddr)
		AIMESH_LOG="${add}"/nodeUpdate.log
		trim_file "$AIMESH_LOG"

		nodesCount=$(echo "$AIMESH_NODES" | grep -o "|" | wc -l)
		if [ -s /tmp/amtmNodeUpdate ]; then
			AIMESH_NODES="$(grep "^[^#]" /tmp/amtmNodeUpdate)"
		elif [ "$nodesCount" != "$knownNodesCount" ]; then
			find_nodes Silent
			AIMESH_NODES="$(grep "^[^#]" "${add}"/nodeUpdate)"
		else
			AIMESH_NODES="$(grep "^[^#]" "${add}"/nodeUpdate)"
		fi

		rm -f /tmp/amtmNodeUpdate
		if [ -z "$AIMESH_NODES" ] || [ ! -s "${add}"/nodeUpdate ]; then
			logger -s -t "amtm autoupdate" "No AiMesh Nodes detected, aborting AiMesh Nodes update"
		else
			[ "$onlyCheckNodes" ] && chktxt=check || chktxt=
			printf "${GN}Start AiMesh Nodes update $chktxt${NC}\\n\\n"
			TOTAL_NODES=$(echo "$AIMESH_NODES" | grep -o "|" | wc -l)
			node_count=1;nodeUpd=
			for node in $AIMESH_NODES; do
				NodeModel="${node%%|*}"
				NodeIP="${node#*|}"
				thisDate=$(date +"%b %d %Y %T")
				grepNode="$NodeModel|$(echo $NodeIP | sed -e 's/\./\\./g')"


				if ping -c2 -W2 $NodeIP >/dev/null; then

					if /usr/bin/ssh -p "$SSH_PORT" -i "$SSH_KEY" -o BatchMode=yes "${NODE_USER}@${NodeIP}" \
						"[ -f /jffs/addons/amtm/a_fw/amtm.mod ] && echo found" 2>/dev/null | grep -q found; then
						printf "Node $node_count/${TOTAL_NODES}: ${GN}$NodeModel${NC} @ ${GN}$NodeIP${NC}\\n"
						echo "$thisDate --> update check Node $NodeModel @ $NodeIP:" >>"$AIMESH_LOG"
						if [ "$onlyCheckNodes" ]; then
							/usr/bin/ssh -p "$SSH_PORT" -i "$SSH_KEY" -o BatchMode=yes "${NODE_USER}@${NodeIP}" "amtm updcheck" | tee -a /tmp/amtmNodecheck
							if [ "$(grep '\->' /tmp/amtmNodecheck)" ]; then
								nodeUpd=1;suUpd=1
								echo "$node" >>/tmp/amtmNodeUpdate
							fi
							rm -f /tmp/amtmNodecheck
						else
							logger -t "amtm autoupdate" "update check of Node $node_count/${TOTAL_NODES} $NodeModel @ $NodeIP"
							/usr/bin/ssh -p "$SSH_PORT" -i "$SSH_KEY" -o BatchMode=yes "${NODE_USER}@${NodeIP}" \
								"echo $thisDate Remote automatic update by $model @ $nv_lan_ipaddr: >>$ASU_LOG;amtm autoupdate;sed -i '/^[[:space:]]*$/d' $ASU_LOG;awk \"/$thisDate/{found=1; next} found\" $ASU_LOG" \
								>>"$AIMESH_LOG"
							sed -e "1,/$thisDate/d" "$AIMESH_LOG"
							logger -t "amtm autoupdate" "update check of Node $node_count/${TOTAL_NODES} $NodeModel @ $NodeIP done"
						fi
						if ! grep "$grepNode$\|#$grepNode$" "${add}"/nodeUpdate >/dev/null; then
							echo "$node" >>"${add}"/nodeUpdate
						fi
					else
						logger -t "amtm autoupdate" "Node $node_count/${TOTAL_NODES} $NodeModel @ $NodeIP is not online"
						printf "Node $node_count/${TOTAL_NODES} $NodeModel @ $NodeIP ${R}is not online${NC}\\n"
					fi
					[ "$node_count" -lt "$TOTAL_NODES" ] && echo

				else
					logger -t "amtm autoupdate" "Node $node_count/${TOTAL_NODES} $NodeModel @ $NodeIP is not online"
					printf "Node $node_count/${TOTAL_NODES} $NodeModel @ $NodeIP ${R}is not online${NC}\\n"
				fi
				node_count=$((node_count+1))
			done
			printf "\\n${GN}End of AiMesh Nodes update $chktxt${NC}\\n\\n"
		fi
	else
		logger -s -t "amtm autoupdate" "No SSH-Key found, aborting AiMesh Nodes update"
	fi
	unset allowUpdateNodes onlyCheckNodes
}

show_node_options(){
	p_e_l
	if [ -s "${add}/nodeUpdate" ]; then
		. "${add}"/nodeUpdate.conf
		printf " Automatic ${GN}Node update${NC} settings

 The Node list below shows AiMesh Nodes
 that this router can check for and update
 all amtm supported scripts.

 It allows to directly update all scripts if
 a version change is detected when the ${GN}u${NC}
 update command is executed or Automatic Script
 updates are scheduled in ${GN}au${NC}.\n\n"

		printf " Supported AiMesh Nodes and current status:\n"
		for node in $(cat "${add}"/nodeUpdate); do
			NodeModel="${node%%|*}"
			NodeIP="${node#*|}"
			if [ "$(echo $node | grep "^[^#]")" ]; then
				if [ "$updateNodes" = enabled ]; then
					printf " - ${GN}$NodeModel${NC} @ $NodeIP, enabled\\n"
				else
					printf " ${GY}- $NodeModel$ @ $NodeIP, enabled${NC}\\n"
				fi
			elif [ "$(echo $node | grep "^#[^#]")" ]; then
				NodeModel="${NodeModel#\#}"
				if [ "$updateNodes" = enabled ]; then
					printf " - ${R}${NodeModel#\#}${NC} @ $NodeIP, disabled from this router\\n"
				else
					printf " ${GY}- ${NodeModel#\#} @ $NodeIP, disabled from this router${NC}\\n"
				fi
			else
				if [ "$updateNodes" = enabled ]; then
					printf " - ${R}${NodeModel#\#\#}${NC} @ $NodeIP, disabled, not Asuswrt-Merlin\\n"
				else
					printf " ${GY}- ${NodeModel#\#\#} @ $NodeIP, disabled from this router${NC}\\n"
				fi
			fi
		done
		[ "$updateNodes" = disabled ] && nodeUpdate="${R}disabled${NC}" || nodeUpdate=
		printf "\\n 1. Disable/Enable update for Nodes $nodeUpdate\\n 2. Reset Nodes list\\n"
		printf " 3. View nodeUpdate log\\n 4. Remove AiMesh Nodes update feature\\n\\n"
		while true; do
			printf " Enter selection [1-4 e=Exit] ";read -r continue
			case "$continue" in
				1)		p_e_l
						printf " Disable/Enable automatic Nodes update\\n\\n"
						printf " When enabled, this setting allows amtm to\\n update AiMesh Nodes automatically.\\n If you prefer instead to keep an AiMesh\\n"
						printf " Node at its current script version level,\\n you may disable the Node.\n\n"
						i=0
						for node in $(cat "${add}"/nodeUpdate); do
							i="$((i+1))"
							[ "$i" -ge 10 ] && spce= || spce=" "
							NodeModel="${node%%|*}"
							NodeIP="${node#*|}"
							if [ "$(echo $node | grep "^[^#]")" ]; then
								if [ "$updateNodes" = enabled ]; then
									printf " $spce$i. ${GN}$NodeModel${NC} @ $NodeIP, enabled\\n"
								else
									printf "   $spce ${GY}$NodeModel @ $NodeIP, enabled${NC}\\n"
								fi
							elif [ "$(echo $node | grep "^#[^#]")" ]; then
								NodeModel="${NodeModel#\#}"
								if [ "$updateNodes" = enabled ]; then
									printf " $spce$i. ${R}$NodeModel${NC} @ $NodeIP, disabled from this router\\n"
								else
									printf "   $spce ${GY}$NodeModel @ $NodeIP, disabled from this router${NC}\\n"
								fi
							fi
							eval "nodeSel$i=$i" "nodeModel$i=$NodeModel"
						done
						i="$((i+1))"
						[ "$i" -ge 10 ] && spce= || spce=" "
						if [ "$updateNodes" = enabled ]; then
							nodeUpdate="${R}Disable${NC}"
						else
							nodeUpdate="${GN}Enable${NC}"
							i=1
						fi
						printf " $spce$i. $nodeUpdate all AiMesh Nodes \\n\\n"

						while true; do
							printf " Disable/Enable Node [1-$i e=Exit] ";read -r node
							case "$node" in
										 [Ee]) 	show_node_options;;
								  ''|*[!0-9]*) 	printf "\\n input is not a number\\n";;
							[1-9]|[1-9][0-9]*) 	if [ "$node" -gt "$i" ]; then
													printf "\\n input is outside selection\\n"
												elif [ "$node" -eq "$i" ]; then
													if [ "$updateNodes" = enabled ]; then
														sed -i "/updateNodes/d" "${add}"/nodeUpdate.conf
														echo updateNodes=disabled >>"${add}"/nodeUpdate.conf
													else
														sed -i "/updateNodes/d" "${add}"/nodeUpdate.conf
														echo updateNodes=enabled >>"${add}"/nodeUpdate.conf
													fi
													. "${add}"/nodeUpdate.conf
													unset updateNodes allowUpdateNodes onlyCheckNodes
													show_node_options
												else
													nodeModel=$(eval "echo \"\$nodeModel$node\"")
													if [ "$(sed -n "${node}p" "${add}"/nodeUpdate | grep "#")" ]; then
														sed -i "${node}s/^#//g" "${add}"/nodeUpdate
														nodeChange=enabled
													else
														sed -i "${node}s/^/#/" "${add}"/nodeUpdate
														nodeChange=disabled
													fi
													show_node_options
												fi
												;;
											*)	printf "\\n input is not an option\\n";;
							esac
						done
						break;;
				2)		find_nodes Reset
						break;;
				3)		s_l_f nodeUpdate.log
						break;;
				4)		p_e_l
						printf " This removes the AiMesh Nodes update\\n feature in amtm.\\n"
						c_d
						rm -f "${add}"/node_update.mod "${add}"/nodeUpdate "${add}"/nodeUpdate.log "${add}"/nodeUpdate.conf
						unset updateNodes allowUpdateNodes onlyCheckNodes
						show_amtm " AiMesh Nodes update removed"
						break;;
				[Ee])	show_amtm menu;break;;
				*)		printf "\\n input is not an option\\n\\n";;
			esac
		done
	else
		[ ! -f /jffs/addons/AutoSSHKey/autosshkey.sh ] && show_amtm " Install addon 'Auto SSH-Key' with ${R}as${NC} first.\\n Then Generate RSA Keys for AiMesh Nodes."
	fi
}

install_node_update(){
	p_e_l
	printf " This installs Automatic Node updates\\n on this router.\\n\\n Automatically update scripts on Asuswrt-Merlin\\n AiMesh Nodes from this router.\\n\\n"
	printf " Author: thelonelycoder\\n"
	c_d node_update.mod

	if [ "$nv_sw_mode" != 1 ];then
		r_m node_update.mod
		am=
		show_amtm " Operation Mode is not Wireless router.\\n Automatic Node updates is not available."
	elif [ -z "$(nvram get asus_device_list | sed 's/</\n/g' | grep '>2$' | awk -F '>' '{print $2 "|" $3}' |  sort -t . -k 4,4n)" ]; then
		r_m node_update.mod
		am=
		show_amtm " This router has no AiMesh Nodes attached.\\n Automatic Node updates is not available."
	elif [ ! -f "/root/.ssh/id_dropbear" ]; then
		if [ ! -f /jffs/addons/AutoSSHKey/autosshkey.sh ]; then
			show_amtm " Install addon 'Auto SSH-Key' with ${R}as${NC} first.\\n Then Generate RSA Keys for AiMesh Nodes."
		else
			show_amtm " Run ${R}as${NC} 'Auto SSH-Key' and\\n Generate RSA Keys for AiMesh Nodes."
		fi
	fi
	find_nodes Scanning
}
#eof
