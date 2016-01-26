#!/bin/bash
usage="usage:`basename $0` accounts|icloud|api|devmgr|anylink|ncms|keycenter"

if [ "$#" != 1  ];then
	echo $usage
	exit 1
fi

case $1 in 
	"all")
		$0 accounts
		$0 icloud
		$0 api
		$0 devmgr
		$0 cloudwatch
		$0 robot
		$0 anylink
		$0 keycenter
		exit 0
		#$0 ncms
		;;
	"accounts")
		bin_src=/home/dspang/go/src/accounts/accounts
		bin_dst=/var/newrock_cloud/accounts/accounts
		;;
	"devmgr")
		bin_src=/home/dspang/go/src/center_system/aw-devmgr/aw-devmgr
		bin_dst=/var/newrock_cloud/aw-devmgr/aw-devmgr
		;;
	"anylink")
		bin_src=/home/dspang/go/src/center_system/aw-anylink/aw-anylink
		bin_dst=/var/newrock_cloud/aw-anylink/aw-anylink
		;;
	"api")
		bin_src=/home/dspang/go/src/center_system/nc-api/nc-api
		bin_dst=/var/newrock_cloud/nc-api/nc-api
		;;
	"icloud")
		bin_src=/home/dspang/go/src/icloud/icloud
		bin_dst=/var/newrock_cloud/icloud/icloud
		;;
	"ncms")
		bin_src=/home/dspang/go/src/ncms/ncms
		bin_dst=/var/newrock_cloud/ncms/ncms
		;;
	"cloudwatch")
		bin_src=/home/dspang/go/src/center_system/aw-cloudwatch/aw-cloudwatch
		bin_dst=/var/newrock_cloud/aw-cloudwatch/aw-cloudwatch
		;;
	"robot")
		bin_src=/home/dspang/go/src/center_system/aw-robot/aw-robot
		bin_dst=/var/newrock_cloud/aw-robot/aw-robot
		;;
	"keycenter")
		bin_src=/home/dspang/go/src/center_system/nc-keycenter/nc-keycenter
		bin_dst=/var/newrock_cloud/nc-keycenter/nc-keycenter
		;;
	*)
		echo "SB"
		exit 1
		;;
esac

cd `dirname $bin_src`

go build || exit 1
strip $bin_src

service newrock_cloud $1 status
service newrock_cloud $1 stop
mkdir -p /tmp/$$
cp `basename $bin_src` /tmp/$$/
echo "newrock321" | su cloud -c "cp /tmp/$$/`basename $bin_src` $bin_dst"
echo "newrock321" | su cloud -c "$bin_dst -l info -v &"
service newrock_cloud $1 status
rm -rf /tmp/$$
exit 0

