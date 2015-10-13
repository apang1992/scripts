#!/bin/bash
usage="usage:`basename $0` accounts|icloud|api|devmgr|anylink|ncms|keycenter"

if [ "$#" != 1  ];then
	echo $usage
	exit 1
fi

case $1 in 
	"accounts")
		bin_dst=/var/newrock_cloud/accounts/accounts
		bin_src=/home/dspang/go/src/accounts/accounts
		;;
	*)
		echo "SB"
		exit 1
		;;
esac

cd `dirname $bin_src`

go build || exit 1

service newrock_cloud $1 status
service newrock_cloud $1 stop
mkdir -p /tmp/$$
cp $1 /tmp/$$/
echo "newrock321" | su cloud -c "cp /tmp/$$/$1 $bin_dst"
echo "newrock321" | su cloud -c "$bin_dst -l debug -v &"
service newrock_cloud $1 status
rm -rf /tmp/$$
exit 0

