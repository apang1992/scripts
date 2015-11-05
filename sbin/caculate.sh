#!/bin/sh

start="2015-10-30 00:00:00"
end="2015-11-02 23:59:59" 

if [ "$#" = 0 ];then
	echo usage : ./caculate.sh jsonfile.json "[test|aws]"
	exit 
fi

if [ ! -f $1 ];then
	tmpraw=rawfile$$
	tmpjson=tmpjson$$
	if [ "$2" = aws ];then
		sshdest=ec2-user@$master_ip
	else
		sshdest=hadoop@192.168.20.120
	fi
        echo "echo \"scan 'device'\" | hbase shell"  | ssh $sshdest 2>/dev/null | sed -n '/ROW  COLUMN+CELL/,$p' |\
		grep '^ [0-9a-zA-Z-]\{20\}' | \
		grep -v device_name  |\
		grep -v send_deviceid | \
		grep -v agent_version | \
		grep -v cloud_control > $tmpraw

	cp $tmpraw tmp.txt$$
	for devid in `cat tmp.txt$$ | grep "^ [0-9a-zA-Z-]\{20\}"   | grep -v geoip | grep -v agent_version  | grep -v device_name | awk '{print $1}' | uniq` ;do
       		i=`cat tmp.txt$$ | grep $devid | grep geoip | cut -b 90-1000 | sed "s/ /-/g"`
        	sed -i "/$devid.*geoip/s#\(.*value=\).*#\1`/usr/bin/printf \"$i\"`#g"  $tmpraw
	done
	rm -f tmp.txt$$

	./ipToAddr.py $tmpraw

	exec 8>&1
	exec 1>$tmpjson

	printf '{"devices":['

	lines=`cat $tmpraw | grep "^ [0-9a-zA-Z-]\{20\}"   | grep -v geoip | grep -v agent_version| grep -v device_name | awk '{print $1}' | uniq | wc -l`
	j=0
	for i in `cat $tmpraw | grep "^ [0-9a-zA-Z-]\{20\}"   | grep -v geoip | grep -v agent_version  | grep -v device_name | awk '{print $1}' | uniq` ;do
       		((j++))
        	cat $tmpraw |\
        	grep $i |  \
        	sed 's/^.*column=basic:\(.*,\) timestamp=.*value=\(.*\)$/\1\2/g' | \
        	sed 's/,/::/1;s/ //g' | \
        	grep ": *.\{1\}" | \
        	sed  's/^\(.*\)::\(.*\),\{0,1\}$/"\1":"\2"/g'| \
        	sed "/time/s/T/ /g" | \
        	sed '$q;s/^\(.*\)$/\1,/g' | \
		sed '1i\"device_id":"'$i'",' | \
        	sed '1p;$p' | \
       		sed '1s/.*/{/g;$s/.*/}/g'
        	if [ "$j" != $lines ];then
               		printf ','
        	fi
	done

	printf ']}'
	exec 1>&8

	cp $tmpjson tmp.txt

	sed -i "/active_time/{h;s/active_time/Active_time/1;G}" $tmpjson
	for i in `cat tmp.txt | grep active_time | awk -F '"' '{print $4}' | sed 's/ /!/g'`;do
       		t=`echo $i |sed "s/!/ /g"`
        	nt="`date -d "$t" +%s`"
		if [ "$t" = "" -o "$nt" = "" ];then
			continue
		fi
        	sed -i "/.*active_time.*$t/s/$t/$nt/g" $tmpjson
	done
	rm -f tmp.txt

	sed -i '/active_time.*[0-9]\{1,\}/s/"active_time":"\(.*\)",$/"active_time":\1,/g' $tmpjson
	sed -i '/^,,/s/,,/,/g' $tmpjson
	cp $tmpjson $1
	rm -f $tmpjson  $tmpraw
fi

starttime=`date -d "$start" +%s`
endtime=`date -d "$end" +%s`

time=`echo $start | sed "s/.*\(201.-..-..\).*/\1/g"`
#echo $time
cat $1 | jq '.devices | map(select(.active_time > '"$starttime"' and  .active_time < '"$endtime"')) '
