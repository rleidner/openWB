#!/bin/bash
. /var/www/html/openWB/openwb.conf
	if [[ $evsecons1 == "dac" ]]; then
		sudo python /var/www/html/openWB/runs/dac.py 1687 $dacregisters1
	fi

	if [[ $evsecons1 == "modbusevse" ]]; then
		sudo python /var/www/html/openWB/runs/evsewritemodbus.py $evsesources1 $evseids1 13
	fi
	if [[ $evsecons1 == "simpleevsewifi" ]]; then
		output=$(curl --connect-timeout $evsewifitimeoutlp2 -s http://$evsewifiiplp2/getParameters)
		state=$(echo $output | jq '.list[] | .evseState')
		if ((state == false)) ; then
			curl --silent --connect-timeout $evsewifitimeoutlp2 -s http://$evsewifiiplp2/setStatus?active=true > /dev/null
		fi
		current=$(echo $output | jq '.list[] | .actualCurrent')
		if (( current != 13 )) ; then
			curl --silent --connect-timeout $evsewifitimeoutlp2 -s http://$evsewifiiplp2/setCurrent?current=13 > /dev/null
		fi
	fi
echo 13 > /var/www/html/openWB/ramdisk/llsolls1
echo 1 > /var/www/html/openWB/ramdisk/ladestatuss1
