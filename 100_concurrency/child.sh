#!/bin/bash

period="30"
concurrence="50"

if [  $# != 2 ];then
	echo  $0 error
	exit
fi

quit=0
trap "exit" 1 2 3 9


sleep_rand=$[$(date +%N | cut -b 6-7 | sed 's/^0//')%$concurrence]

sleep $sleep_rand

for ((;;));do
	if [ "$quit" = "1" ];then
		break
	fi


	response=`./read_1KB_data.tcl $1 $2 | md5sum`
	if [ "$response" = "63ddd69bc7bd9d5ad40a5cbde0991ee5  -" ];then
		echo -n -
	else
		echo -n 1
	fi
	sleep $period
	#ab -n 1 -c 1 http://121.40.54.78:$1/ | grep -E "(Time taken for tests:)|(Complete requests:)|(Failed requests:)|(Total transferred:)"  #>/dev/null 2>&1

done
