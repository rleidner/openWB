#!/bin/bash
. /var/www/html/openWB/openwb.conf
re='^-?[0-9]+$'
rekwh='^[-+]?[0-9]+\.?[0-9]*$'

output=$(curl --connect-timeout $evsewifitimeoutlp3 -s http://$evsewifiiplp3/getParameters)
watt=$(echo $output | jq '.list[] | .actualPower')
lla1=$(echo $output | jq '.list[] | .currentP1')
lla2=$(echo $output | jq '.list[] | .currentP2')
lla3=$(echo $output | jq '.list[] | .currentP3')
llkwh=$(echo $output | jq '.list[] | .meterReading')
watt=$(printf %.$2f $(echo "$watt * 1000" |bc))
if [[ $watt =~ $re ]] ; then
	echo $watt > /var/www/html/openWB/ramdisk/llaktuells2
fi
if [[ $lla1 =~ $re ]] ; then
	echo $lla1 > /var/www/html/openWB/ramdisk/llas21
fi
if [[ $lla2 =~ $re ]] ; then
	echo $lla2 > /var/www/html/openWB/ramdisk/llas22
fi
if [[ $lla3 =~ $re ]] ; then
	echo $lla3 > /var/www/html/openWB/ramdisk/llas23
fi
if [[ $llkwh =~ $rekwh ]] ; then
	echo $llkwh > /var/www/html/openWB/ramdisk/llkwhs2
fi
