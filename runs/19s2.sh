#!/bin/bash
. /var/www/html/openWB/openwb.conf

	if [[ $evsecons2 == "dac" ]]; then
		sudo python /var/www/html/openWB/runs/dac.py 2466 $dacregisters2
	fi

	if [[ $evsecons2 == "modbusevse" ]]; then
		sudo python /var/www/html/openWB/runs/evsewritemodbus.py $evsesources2 $evseids2 19
	fi
	if [[ $evsecons2 == "simpleevsewifi" ]]; then
		output=$(curl --connect-timeout $evsewifitimeoutlp3 -s http://$evsewifiiplp3/getParameters)
		state=$(echo $output | jq '.list[] | .evseState')
		if ((state == false)) ; then
			curl --silent --connect-timeout $evsewifitimeoutlp3 -s http://$evsewifiiplp3/setStatus?active=true > /dev/null
		fi
		current=$(echo $output | jq '.list[] | .actualCurrent')
		if (( current != 19 )) ; then
			curl --silent --connect-timeout $evsewifitimeoutlp3 -s http://$evsewifiiplp3/setCurrent?current=19 > /dev/null
		fi
	fi
echo 19 > /var/www/html/openWB/ramdisk/llsolls2
echo 1 > /var/www/html/openWB/ramdisk/ladestatuss2
