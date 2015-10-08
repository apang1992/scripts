#!/bin/bash

if [ $# -eq 1 ];then
	max_num=$1
else
	max_num=10
fi

exec 16>&1
exec 1>tmp$$
exec 2>tmp$$

j=0

for i in `./search_service.tcl | grep '"port"' | awk '{print $2}' | sed 's/"//g'` ; do
	ab -n 1 -c 1 http://121.40.54.78:$i/ | grep -E "(Time taken for tests:)|(Complete requests:)|(Failed requests:)|(Total transferred:)" &
	#ab -n 1 -c 1 http://121.40.54.78:$i/ &
	((j++))
	if [ "$j" -eq "$max_num" ];then
		break
	fi

done

wait 

file=tmp$$

min_time=`cat $file | grep "Time taken for tests:" | awk '{print $5}' | head -1`
max_time=`cat $file | grep "Time taken for tests:" | awk '{print $5}' | tail -1`
numbers=`cat $file | grep "Time taken for tests:" | awk '{print $5}' | wc -l`
success_numbers=`cat $file | grep "Complete requests:" |grep 1 | wc -l`
fail_numbers=$[$max_num-$success_numbers]
avg_time=`cat $file | grep "Time taken for tests:" | awk '{print $5}' | awk 'BEGIN{sum=0}{sum+=$1}END{print sum/'"$success_numbers}"`
total_data=`cat $file | grep "Total transferred:" | awk '{print $3}' | awk 'BEGIN{sum=0}{sum+=$1}END{print sum/1000}'`
avg_speed=`cat $file | grep "Total transferred:" | awk '{print $3}' | awk 'BEGIN{sum=0}{sum+=$1}END{print sum/'"$max_time}"`

exec 1>&16

echo -e "min time :\t" $min_time
echo -e "max time :\t" $max_time
echo -e "total numbers:\t" $max_num
echo -e "succ numbers:\t" $success_numbers
echo -e "fail numbers:\t" $fail_numbers
echo -e "avg time:\t" $avg_time
echo -e "total data:\t" $total_data KB
echo -e "avg speed:\t" `echo "$avg_speed/1000"| bc -l | cut -b 1-5` KB/s

rm -f tmp$$
