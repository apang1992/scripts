#!/bin/sh

cloud_web=cloud_web_1.0.17.tar.gz
boa_version=2_4_13_SSL

cloudae=cloudae_1.0.13
cloudae_ini=CloudPlatform/cloudae/cloudae.ini

mx8_ii_web=MX/mx8-II/ch_nr/web_0.0.47_auth.tar.gz
wroc2k_web=wrom/web_3.0.60.tar.gz
wroc3k_web=wroc3000/web_1.9.27_auth.tar.gz
hx4e_web=MX/hx4e/ch_nr/web_0.0.46_auth.tar.gz
om50_web=OM50/web_0.0.48_auth.tar.gz 
om20_web=om20/web_0.0.48_auth.tar.gz

if [ "$auth_flag" = "A" ];then
	pluginmgr=CloudPlatform/pluginmgr/1.1.X/pluginmgr_1.1.22
	pluginmgr_ini=CloudPlatform/pluginmgr/1.1.X/pluginmgr.ini
else
	pluginmgr=CloudPlatform/pluginmgr/pluginmgr_1.0.6
	pluginmgr_ini=CloudPlatform/pluginmgr/pluginmgr.ini_1.0.x
fi
###############################################################################

cd /tmp
wget -q ftp://release:newrock@192.168.20.164/$pluginmgr
wget -q ftp://release:newrock@192.168.20.164/CloudPlatform/cloudae/$cloudae
n_pluginmgr_md5=`md5sum $(basename $pluginmgr) | awk '{print $1}'`
n_cloudae_md5=`md5sum $cloudae | awk '{print $1}'`
#echo $n_pluginmgr_md5 $n_cloudae_md5
rm -f $(basename $pluginmgr) $cloudae 


boa_gz="boa_$boa_version.gz"
mx8_ii_boa=mx_release/release_9_2/mx8-II/$boa_gz
wroc2k_boa=mx_release/release_2_1/wrom/$boa_gz
wroc3k_boa=mx_release/release_2_1/wroc3000/$boa_gz
hx4e_boa=mx_release/release_9_2/hx4e/$boa_gz
om50_boa=mx_release/release_2_1/om50/$boa_gz
om20_boa=mx_release/release_2_1/om20/$boa_gz

if [ "$error_flag" = "1" ];then
	echo "Parameter error"
	exit 1
fi

n_cloudae_version=`echo $cloudae|sed "s/^cloudae_\(.*\)$/\1/"`
n_pluginmgr_version=`basename $pluginmgr | sed "s/^pluginmgr_\(.*\)/\1/"`

n_mx8_ii_web_version=`echo $mx8_ii_web | sed "s#^.*/web_\(.*\).tar.gz#\1#"`
n_wroc2k_web_versoin=`echo $wroc2k_web | sed "s#^.*/web_\(.*\).tar.gz#\1#"`
n_wroc3k_web_version=`echo $wroc3k_web | sed "s#^.*/web_\(.*\).tar.gz#\1#"`
n_hx4e_web_version=`echo $hx4e_web | sed "s#^.*/web_\(.*\).tar.gz#\1#"`
n_om50_web_version=`echo $om50_web | sed "s#^.*/web_\(.*\).tar.gz#\1#"`
n_om20_web_version=`echo $om20_web | sed "s#^.*/web_\(.*\).tar.gz#\1#"`

hostname=`hostname`
echo "Your device type is $hostname"

if [ -f "/tmp/web/version.htm" ];then web_version=`cat /tmp/web/version.htm  | sed -n '/web version:/{n;p}' | sed 's/^.*>\(.*\)<.*$/\1/g'`; else web_version="too old" ; fi

if   [ "$hostname" = "MX8-II" -o "$hostname" = "MX8A" ];then
        web=$mx8_ii_web
	boa=$mx8_ii_boa                                						#mx8-II
        if [ "$web_version" != "$n_mx8_ii_web_version" ];then need_web=YES ;else need_web=NO ;fi
elif [ "$hostname" = "wroc" -o "$hostname" = "WiFi_IPPBX" ];then
        web=$wroc2k_web                                                  			  #wroc2K
	boa=$wroc2k_boa                                						#mx8-II
        if [ "$web_version" != "$n_wroc2k_web_versoin" ];then need_web=YES ; else need_web=NO ;fi
elif [ "$hostname" = "WROC3000" ];then
        web=$wroc3k_web                                               				 #wroc3000
	boa=$wroc3k_boa                                						#mx8-II
        if [ "$web_version" != "$n_wroc3k_web_version" ];then need_web=YES ; else need_web=NO ;fi
elif [ "$hostname" = "HX4E" -o "$hostname" = "HX4-VoIP-IAD" ];then
        web=$hx4e_web                                    					#hx4e
        boa=$hx4e_boa                                    					#hx4e
        if [ "$web_version" != "$n_hx4e_web_version" ];then need_web=YES ; else need_web=NO ; fi
elif [ "$hostname" = "OM50" ];then
        web=$om50_web                           			                        #om50
        boa=$om50_boa                        			                        #om50
        if [ "$web_version" != "$n_om50_web_version" ];then need_web=YES ; else need_web=NO ; fi
elif [ "$hostname" = "OM20" ];then
        web=$om20_web  				                                                  #om20
        boa=$om20_boa  				                                                  #om20
        if [ "$web_version" != "$n_om20_web_version" ];then need_web=YES ; else need_web=NO ;fi
else
        echo "$hostanme NOT support!"
        exit 1
fi
need_web=NO
boa_current_version=`cat  /var/log/boa.log  | grep 'boa version:' | awk '{print $6}' | sed 's/\./_/g' `
if [ "$boa_current_version" != "$boa_version" ];then
	cd /var/run					     
	rm -f /var/bin/boa.bz2 /var/bin/boa.gz /var/run/boa  
	echo $boa
	wget ftp://release:newrock@192.168.20.164/$boa	     
	mv `basename $boa` boa.gz			     
	cp boa.gz /var/bin 				     
	gzip -d boa.gz					     
	chmod +x boa					     
	killall -9 boa
fi
					     
echo "Your web version is $web_version. Need upgrade? $need_web"

if [ -z  "`nvram_get DevID`" ]; then 
	echo "Error:Cannot get DevID!!Need macset? YES"
	need_macset=YES
fi


if [ -f "/var/run/pluginmgr" ];then pluginmgr_md5=$(echo `md5sum /var/run/pluginmgr` | awk '{print $1}') ; fi
if   [ "$pluginmgr_md5" = "$n_pluginmgr_md5" ];then
	pluginmgr_version="`basename $pluginmgr`"
else
	pluginmgr_version="too old"
fi
if [ "$pluginmgr_md5" != "$n_pluginmgr_md5" ];then need_pluginmgr=YES ; else need_pluginmgr=NO ;fi
echo "Your pluginmgr version is $pluginmgr_version. Need upgrade? $need_pluginmgr"


if [ -f "/var/run/cloudae" ];then cloudae_md5=$(echo `md5sum /var/run/cloudae` | awk '{print $1}');fi
if   [ "$cloudae_md5" = "$n_cloudae_md5" ];then
	cloudae_version="$cloudae"
else
	cloudae_version="too old"
fi
if [ "$cloudae_md5" != "$n_cloudae_md5" ];then need_cloudae=YES ; else need_cloudae=NO ;fi
echo "Your cloudae version is $cloudae_version. Need upgrade? $need_cloudae"

need_pluginmgr_ini=YES
need_cloudae_ini=YES

cd /tmp
exec 2>&1

#cleanup 

killall -9 pluginmgr > /dev/null 2>&1
killall -9 cloudae > /dev/null 2>&1
echo 3 > /proc/sys/vm/drop_caches
rm -f key_unbind platform_devinfo active cloudLogin get_authcode 

if [ "$need_macset" = "YES" ];then
	echo "Now dowloading macset"
	rm -f RT6856.macset_V2.0
	wget ftp://release:newrock@192.168.20.164/macset/RT6856.MACSET/RT6856.macset_V2.0
	# echo "macset/RT6856.MACSET/RT6856.macset_V2.0" | nc $nc_flag $server_ip $server_port > RT6856.macset_V2.0
	chmod +x RT6856.macset_V2.0
fi

if [ "$need_pluginmgr" = "YES" ];then
	echo  "Now upgrading pluginmgr..."
	rm -f /var/bin/pluginmgr.bz2 /var/bin/pluginmgr.gz /var/run/pluginmgr
	rm -f pluginmgr.gz pluginmgr
	echo $pluginmgr
	wget ftp://release:newrock@192.168.20.164/$pluginmgr
	mv `basename $pluginmgr` pluginmgr
	cp pluginmgr /var/run/pluginmgr
	chmod +x /var/run/pluginmgr
	gzip pluginmgr
	mv pluginmgr.gz /var/bin/pluginmgr.gz
fi

if [ "$need_cloudae" = "YES" ];then
	echo  "Now upgrading cloudae..."
	rm -f /var/bin/cloudae.bz2 /var/bin/cloudae.gz /var/run/cloudae
	rm -f cloudae.gz cloudae
	wget ftp://release:newrock@192.168.20.164/CloudPlatform/cloudae/$cloudae
	# echo "CloudPlatform/cloudae/$cloudae" | nc $nc_flag  $server_ip $server_port > $cloudae
	mv $cloudae cloudae
	cp cloudae /var/run/cloudae
	chmod +x /var/run/cloudae
	gzip cloudae
	mv cloudae.gz /var/bin/cloudae.gz
fi

if [ "$need_web" = "YES" ];then
	echo "Now upgrading web..."
	rm -f /var/bin/web.tar.bz2 /var/bin/web.tar.gz
	rm -rf web web.tar.gz
	wget ftp://release:newrock@192.168.20.164/web_release/$web
#	echo "web_release/$web" | nc $nc_flag $server_ip $server_port > `basename $web`
	mv `basename $web` web.tar.gz
	echo -n "Now move web.tar.gz to /var/bin..."
	cp web.tar.gz /var/bin/web.tar.gz 
	echo
	echo -n "Now uncompressing web.tar.gz..."
	tar -xzf web.tar.gz 
	chmod +x /tmp/web/cgi-bin/*
	echo
	rm -f web.tar.gz
fi

rm -f cloud_web*
rm -f /var/bin/cloud_web.tar.gz
wget ftp://release:newrock@192.168.20.164/CloudPlatform/web/$cloud_web
#if [ "$hostname" = "wroc" -o "$hostname" = "wroc2k" -o "$hostname" = "wroc2000" ];then
#	wget ftp://release:newrock@192.168.20.164/CloudPlatform/web/wroc2000/$cloud_web
#else
#	wget ftp://release:newrock@192.168.20.164/CloudPlatform/web/$cloud_web
#fi
tar -xzf $cloud_web
mv $cloud_web /var/bin/cloud_web.tar.gz


if [ "$need_pluginmgr_ini" = "YES" ];then
	echo "Now upgrading pluginmgr.ini"
	rm -f /var/config/cloud/pluginmgr.ini
	wget ftp://release:newrock@192.168.20.164/$pluginmgr_ini
	mv `basename $pluginmgr_ini` /var/config/cloud/pluginmgr.ini
fi

if [ "$need_cloudae_ini" = "YES" ];then
        echo "Now upgrading cloudae.ini"
        rm -f /var/config/cloud/cloudae.ini
        wget ftp://release:newrock@192.168.20.164/$cloudae_ini
        mv `basename $cloudae_ini` /var/config/cloud/cloudae.ini
fi

LOG_LEVEL=1
if [ "$auth_flag" = "A" -a "$public_flag" = "0" ];then
	#sed -i "s/newrocktech/cdn.newrocktech/g" /var/config/cloud/pluginmgr.ini
	#sed -i "s/newrocktech/cdn.newrocktech/g" /var/config/cloud/cloudae.ini
	echo
elif [ "$auth_flag" = "A" -a "$public_flag" = "1" ];then
	sed -i "s/cdn.newrocktech/newrocktest/g" /var/config/cloud/pluginmgr.ini
	sed -i "s/cdn.newrocktech/newrocktest/g" /var/config/cloud/cloudae.ini
	sed -i "s/:10443//g" /var/config/cloud/pluginmgr.ini
elif [ "$auth_flag" = "A" -a "$public_flag" = "2" ];then
	sed -i "s/cdn.newrocktech/newrocktest80/g" /var/config/cloud/pluginmgr.ini
	sed -i "s/cdn.newrocktech/newrocktest80/g" /var/config/cloud/cloudae.ini
	sed -i "s/:10443//g" /var/config/cloud/pluginmgr.ini
elif [ "$auth_flag" = "B" -a "$public_flag" = "0" ];then
	sed -i "s/cdn.newrocktech/newrocktech/g" /var/config/cloud/pluginmgr.ini
        sed -i "s/cdn.newrocktech/newrocktech/g" /var/config/cloud/cloudae.ini
	sed -i "s/:10443//g" /var/config/cloud/pluginmgr.ini
elif [ "$auth_flag" = "B" -a "$public_flag" = "1" ];then
	sed -i "s/newrocktech/newrocktest88/g" /var/config/cloud/pluginmgr.ini
        sed -i "s/newrocktech/newrocktest88/g" /var/config/cloud/cloudae.ini
	
	sed -i "s/.cdn//g" /var/config/cloud/cloudae.ini
	sed -i "s/:10443//g" /var/config/cloud/pluginmgr.ini
else 
	echo "param error"
fi

sed -i "s/active_state *= *true/active_state=false/g" /var/config/cloud/pluginmgr.ini
	
#sed -i "s/^.*loglevel=.*$/loglevel=8/g" /var/config/cloud/pluginmgr.ini
#sed -i "s/^.*LOG_LEVEL=.*$/LOG_LEVEL=8/g" /var/config/cloud/cloudae.ini
sed -i '$a\loglevel=8' /var/config/cloud/pluginmgr.ini
sed -i '/cloudserver/s/^.*$/cloudserver=on/g' /var/config/cloud/pluginmgr.ini
sed -i '$a\LOG_LEVEL=8' /var/config/cloud/cloudae.ini
sed -i "/nameserver/s/^.*$/nameserver 192.168.20.80/g" "/etc/resolv.conf"

/var/run/pluginmgr > /dev/null 2>&1 &
sleep 1
msg=`ps aux | grep pluginmgr |grep -v grep`
if [ -z "$msg" ];then
	echo "ERROR: Start pluginmgr failed! Maybe you have to update bin and use macset to get DevID!!"
else
	echo "Start pluginmgr successfully!"
fi
#killall -9 app

iptables -t mangle -F

if [ ! -z `ping -c 3 api.newrocktest.com | grep "bad address"` ];then
	echo "Warning:DNS system cannot resolv api.newrocktest.com!"
	if [ ! -z `ping -c 3 114.114.114.114 | grep "0 packets received"` ];then
		echo "Warning:Network is down!"
	fi
fi
echo  "bin version: `cat /etc/bin_version`"
echo -e "Upgrade finish!"

exit 0
