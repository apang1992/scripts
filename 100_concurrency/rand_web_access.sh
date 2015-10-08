#!/bin/bash

source ../profile

if [ "$#" -eq 1 ];then
	server="$proxy_server"
	echo server $server
	max_num=$1
else
	echo $# $1 $2
	echo $0  error
	exit
fi



trap "killall -9 child.sh ; exit" 0 2


j=0

for i in `./search_service.tcl | grep '"port"' | awk '{print $2}' | sed 's/"//g'` ; do
	array[j]=$i
	((j++))
done


for ((i=0;i<$max_num;i++));do
	./child.sh $server ${array[$i]} &
	#echo ${array[$i]}
done

wait

exit


