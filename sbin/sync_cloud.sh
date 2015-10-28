#!/bin/sh
#WARNING: you have to link /etc/init.d/newrock_cloud to /var/newrock_cloud/newrock_cloud
#You must have the command su whose version is 2.23.3

localhost_site="127.0.0.1"
test_site="192.168.20.80"
web_tmp=/tmp/webtmp
usageMsg="usage:$0 test|aws accounts|icloud|api... [bin|web]"

if [ "`whoami`" != "dspang" ];then
	echo "You should be dspang!!"
	exit 1
fi

if [ ! -f `dirname $0`/newrock_cloud ];then
	echo "where is your newrock_cloud file"
	exit 1
fi

exec 2>/dev/null

if [ "$#" != 2 && "$#" != 3 ];then
	echo $usageMsg
	exit 1
fi

if [ "$2" != "all" -a "$2" != "accounts" -a "$2" != "icloud" -a "$2" != "api" -a "$2" != "keycenter" -a "$2" != "devmgr" -a "$2" != "anylink" -a "$2" != "mqtt" -a "$2" != "proxy" -a "$2" != "ncms"   ];then
	echo $usageMsg
	exit 1
fi

if [ "$1" = "test"   ];then
	accounts_site="$test_site"
	anylink_site="$test_site"
	api_site="$test_site"
	devmgr_site="$test_site"
	icloud_site="$test_site"
	keycenter_site="$test_site"
	mqtt_site="$test_site"
	ncms_site="$test_site"
	proxy_site="$test_site"
	login_user="cloud"
elif [ "$1" = "test80" ];then
    	accounts_site="$localhost_site"
    	anylink_site="$localhost_site"
    	api_site="$localhost_site"
    	devmgr_site="$localhost_site"
    	icloud_site="$localhost_site"
    	keycenter_site="$localhost_site"
    	mqtt_site="$localhost_site"
  	ncms_site="$localhost_site"
   	proxy_site="$localhost_site"
	login_user="cloud"
elif [ "$1" = "aws" ];then
	accounts_site=$master_ip
	anylink_site=$slave1_ip
	api_site=$slave2_ip
	devmgr_site=$slave1_ip
	icloud_site=$slave2_ip
	keycenter_site=$master_ip
	mqtt_site=$slave1_ip
	ncms_site=$slave2_ip
	proxy_site=$slave2_ip
	ncms_site=$master_ip
	login_user="ec2-user"
else    
	echo $usageMsg
	exit 1
fi

service_name=newrock_cloud

update_bin(){
	if [ "$2" = "accounts" ];then
		bin_path="/var/newrock_cloud/accounts/accounts"
		bin_site=$accounts_site
	elif [ "$2" = "icloud" ];then
		bin_path="/var/newrock_cloud/icloud/icloud"
       	bin_site=$icloud_site
	elif [ "$2" = "api" ];then
		bin_path="/var/newrock_cloud/nc-api/nc-api"
        bin_site=$api_site
	elif [ "$2" = "keycenter" ];then
		bin_path="/var/newrock_cloud/nc-keycenter/nc-keycenter"
        bin_site=$keycenter_site
	elif [ "$2" = "anylink" ];then
		bin_path="/var/newrock_cloud/aw-anylink/aw-anylink"
        bin_site=$anylink_site
	elif [ "$2" = "devmgr" ];then
		bin_path="/var/newrock_cloud/aw-devmgr/aw-devmgr"
        bin_site=$devmgr_site
	elif [ "$2" = "proxy" ];then
		bin_path="/var/newrock_cloud/tcpproxy/tcpproxy"
        bin_site=$proxy_site
	elif [ "$2" = "mqtt" ];then
		bin_path="/var/newrock_cloud/mqtt/mosquitto"
        bin_site=$mqtt_site
	elif [ "$2" = "ncms" ];then
		bin_path="/var/newrock_cloud/ncms/ncms"
        bin_site=$ncms_site
	else 
		echo "usage error!"
		exit 1
	fi
	scp  `dirname $0`/newrock_cloud $login_user@$bin_site:/var/newrock_cloud/newrock_cloud

	previous_pid=`echo "ps aux | grep $2 | grep -E -v \"(grep|sudo|update_bin)\"" | ssh -q  $login_user@$bin_site | awk '{print $2}' `
	scp $bin_path $login_user@$bin_site:$bin_path.new
	echo "service $service_name $2 stop > /dev/null 2>&1" | ssh -q  $login_user@$bin_site 
	usleep 200000 
	echo "mv -f $bin_path.new $bin_path" | ssh -q $login_user@$bin_site
	echo "chmod 755 $bin_path" | ssh -q $login_user@$bin_site
	echo "service $service_name $2 start > /dev/null 2>&1" | ssh -q $login_user@$bin_site
	usleep 200000
	current_pid=`echo "ps aux | grep $2 | grep -E -v \"(grep|sudo|update_bin)\"" | ssh -q  $login_user@$bin_site | awk '{print $2}' `
	if [ "$previous_pid" != "$current_pid" ];then
		echo "restart $2 successfully($previous_pid $current_pid)"
	else		
		echo "restart $2 failed($previous_pid $current_pid)"
	fi
	current_md5=`echo "md5sum $bin_path" | ssh -q  $login_user@$bin_site | awk '{print $1}'`
	local_md5=`md5sum $bin_path | awk '{print $1}'`
	if [ "$current_md5" = "$local_md5" ];then
		echo "update_bin $2 successfully"
	else
		echo "update_bin $2 failed"
	fi
}

update_web(){
    if [ "$2" = "accounts" ];then
        web_path="/var/newrock_cloud/accounts/account_web"
        web_site=$accounts_site
    elif [ "$2" = "icloud" ];then
        web_path="/var/newrock_cloud/icloud/icloud_web"
        web_site=$icloud_site
    elif [ "$2" = "ncms" ];then
        web_path="/var/newrock_cloud/ncms/ncms_web"
        web_site=$ncms_site
    else
        echo $usageMsg
        exit 1
    fi
    if [ ! -d "$web_tmp" -a ! -z "$web_tmp" ];then
        mkdir $web_tmp
    fi
    if [ ! -d "$web_tmp" -a ! -z "$web_tmp" ];then
        echo "tmp dir error!"   
        exit 1
    fi
    cd $web_tmp
    cp -r $web_path $web_tmp/
    rm -rf ./`basename $web_path`/.git*
    tar -czf "`basename $web_path`".tar.gz `basename $web_path`
    scp "`basename $web_path`".tar.gz $login_user@$web_site:"`dirname $web_path`"

    echo "service $service_name $2 stop > /dev/null 2>&1" | ssh   $login_user@$web_site
    usleep 200000
    echo " cd `dirname $web_path` ; tar -xzf `basename $web_path`.tar.gz ; rm -f `basename $web_path`.tar.gz" | ssh -q $login_user@$web_site
    if [ "$2" = "icloud" ];then
        echo "cp /var/newrock_cloud/icloud/public.js /var/newrock_cloud/icloud/icloud_web/static/js/" | ssh -q $login_user@$web_site
    fi
    if [ "$2" = "ncms" ];then
        echo "cp /var/newrock_cloud/ncms/public.js /var/newrock_cloud/ncms/ncms_web/js/" | ssh -q $login_user@$web_site
    fi
    echo "service $service_name $2 start > /dev/null 2>&1" | ssh  $login_user@$web_site
    rm -rf $web_tmp
}

if [ -z "$3" -o "$3" = "bin" ];then
	if [ "$2" != "all" ];then
		update_bin "" $2
	else
		update_bin "" accounts
		update_bin "" icloud
		update_bin "" api
		update_bin "" keycenter
		update_bin "" anylink
		update_bin "" devmgr
		#update_bin "" proxy
		#update_bin "" mqtt
		update_bin "" ncms
	fi
elif [ "$3" = "web" ];then
	if [ "$2" != "all" ];then
        update_web "" $2
    else
        update_web "" accounts
        update_web "" icloud
        update_web "" ncms
    fi
else
	echo $usageMsg
	exit 1
fi
