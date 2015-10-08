#!/bin/bash

. ../profile

if [ $# -lt 1 ];then
	echo "usage:$0 numbers"
	exit 1
fi

if [ "$#" -eq 1 ];then
	loop_start=0
	loop_end=$1
fi

if [ "$#" -eq 2 ];then
	loop_start=$1
	loop_end=$2
fi


for ((i=$loop_start;i<$loop_end;i++));do
	device_id=$(genId -m $(printf "$device_id_prefix%6d" $i | sed "s/ /0/g"))



	device_key=$(echo -e -n "POST /v1/devices/$device_id/actions/activate HTTP/1.1\n\
Content-Type:application/x-www-form-urlencoded;charset=UTF-8\n\
Connection:close\n\
Authorization:Bearer $active_token\n\
Content-Length:0\n\n" | nc $nc_flag $api_site $api_port | grep "device_key" | sed 's/^.*:.*"\(.*\)".*$/\1/g')



        token=$(echo -n "$device_key:x-auth-device"|base64 -w 0)
	echo -e -n "POST /v1/devices/authcodes?device_id=$device_id HTTP/1.1\n\
Content-Type:application/x-www-form-urlencoded;charset=UTF-8\n\
Connection:close\n\
Authorization:Basic $token\n\
Content-Length:0\n\n" | nc $nc_flag $api_site $api_port
	usleep 100000	
done

exit 0

