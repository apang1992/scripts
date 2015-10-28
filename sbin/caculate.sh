#!/bin/sh

start=2015-10-28
end=2015-10-29

if [ "$#" = 0 ];then
	echo usage : ./caculate.sh rawfile "[test|aws]"
	exit 
fi
if [ "$2" = aws ];then
	sshdest=ec2-user@$master_ip
else
	sshdest=hadoop@192.168.20.120
fi

if [ ! -f $1 ];then
        #echo "scan 'device'" | hbase shell 2>/dev/null | sed -n '/ROW  COLUMN+CELL/,$p' | grep '^ [0-9a-zA-Z-]\{20\}' | grep -v geoip | grep -v device_name > tmpfile$$
        echo "echo \"scan 'device'\" | hbase shell"  | ssh $sshdest 2>/dev/null | sed -n '/ROW  COLUMN+CELL/,$p' | grep '^ [0-9a-zA-Z-]\{20\}' | grep -v geoip | grep -v device_name > $1
fi
cp $1 tmpfile$$

exec 8>&1
exec 1>output.txt

printf '{"devices":['

lines=`cat tmpfile$$ | grep "^ [0-9a-zA-Z-]\{20\}"   | grep -v geoip | grep -v agent_version| grep -v device_name | awk '{print $1}' | uniq | wc -l`
j=0
for i in `cat tmpfile$$ | grep "^ [0-9a-zA-Z-]\{20\}"   | grep -v geoip | grep -v agent_version  | grep -v device_name | awk '{print $1}' | uniq` ;do
        ((j++))
        cat tmpfile$$ |\
        grep $i |grep -v geoip |  \
        sed 's/^.*column=basic:\(.*,\) timestamp=.*value=\(.*\)$/\1\2/g' | \
        sed 's/,/::/1;s/ //g' | \
        grep ": *[0-9a-zA-Z]\{1\}" | \
        sed  's/^\(.*\)::\(.*\),\{0,1\}$/"\1":"\2"/g'| \
        sed "/time/s/T/ /g" | \
        sed '$q;s/^\(.*\)$/\1,/g' | \
        sed '1p;$p' | \
        sed '1s/.*/{/g;$s/.*/}/g'
        if [ "$j" != $lines ];then
                printf ','
        fi

done

printf ']}'
exec 1>&8

cp output.txt tmp.txt

for i in `cat tmp.txt | grep active_time | awk -F '"' '{print $4}' | sed 's/ /!/g'`;do
        t=`echo $i |sed "s/!/ /g"`
        nt=`date -d "$t" +%s`
        sed -i "/$t/s/$t/$nt/g" output.txt
done
sed -i '/active_time/s/"active_time":"\(.*\)",$/"active_time":\1,/g' output.txt
sed -i '/^,,/s/,,/,/g' output.txt

starttime=`date -d $start +%s`
endtime=`date -d $end +%s`

#cat output.txt | jq '.devices | map(select(.active_time > '$starttime' and  .active_time < '$endtime')) '
cat output.txt | jq '.'

rm output.txt
rm tmpfile$$
rm -f tmp.txt
exit
