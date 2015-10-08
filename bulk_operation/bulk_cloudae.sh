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


for i in $(ps aux | grep $device_id_prefix | grep -v "grep" | awk '{print $2}') ;do 
	kill $i
done

if [ "$1" = "exit" -o "$1" = "-exit" -o "$1" = "-e" ];then
	exit
fi

echo $mqtt_server
echo $device_id_prefix

for ((i=$loop_start;i<$loop_end;i++));do
	cloudae $mqtt_server $(printf "$device_id_prefix%6d" $i | sed "s/ /0/g") $(printf "host_%6d" $i|sed "s/ /0/g") > /dev/null &
	#sleep 1
	usleep 100000
done
