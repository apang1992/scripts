#!/bin/sh

export user_id=333333333
export email="martin@newrocktech.com"
export password="martin123"

export user_id1=444444444
export email1="james@newrocktech.com"
export password1="james123"

site_suffix=`cat /var/config/cloud/pluginmgr.ini  | grep api_server | sed 's/^.*=.*newrock\(.*\).com.*$/\1/g'`

if [ "$site_suffix" = aws ];then
	export strong_token="ZWIxNTM4MTAt.zFlZS00OTE3LTk1MDgtYTI4YWY5NDk3ODI1"
	export strong_token1="NjQ3Yjc2Yjct.Dk1ZS00ZGQxLTlhNmQtM2YyNjA1MGJmYjBh"
	export active_token="YjBhMDJkZDkt.DZiZi00NzcwLTk2ZmUtMzJhZjBmMzYyYmMw"
	export active_token1="Nzk2MWJkOTAt.DY2ZC00MzRiLWI2YjctYTdhYjc5NjQzODQ5"
elif [ "$site_suffix" = "test" ];then
	export strong_token="YWU3NjNmMmUt.WQ4NC00M2YyLTk1ZTUtYTczYzhjMTRlMTA2"
	export strong_token1="ZjE2NzdjNzIt.WZkZC00ODRhLTgwZTMtNGU2ZWFiYTAzM2Vh"
	export active_token="MjM3MDg4ZmQt.GNjYy00NDVlLTliOTMtZWE3ZjE3MTE3YjU3"
	export active_token1="NzE1Yjc4MDkt.mVhNy00MDY1LTkwNTAtMDFiMDBiZjRkMDYx"
elif [ "$site_suffix" = "test80" ];then
	export strong_token="NzcyZDU0ODEt.2VmMi00MmI1LWJmYmYtNDA2YWE1ZGIwMWY4"
        export strong_token1="NDE0ODQ0YzMt.mNmMS00MmMzLWE4MzMtYzgxYzQ4NjhhZGM3"
        export active_token="ZDJhN2U4OGYt.TRmNi00NDIxLTgwMjUtYzNmNWVlMjQxMTFl"
        export active_token1="NTRhNGU4Y2Ut.TNhZS00NGY0LTg4NWYtMjhhZTI5Yjc4MGE3"
fi

export api_site="api.newrock$site_suffix.com"
export api_port=443
export api_host="api.newrock$site_suffix.com"


export dev_ip=127.0.0.1
export dev_port=443

export device_id=`nvram_get DevID`
if [ -z "$device_id" ];then
	echo "device id is null"
	exit 1
fi

case `hostname` in
MX8-II|MX8A)
	export dev_pass=mx8
	;;
wroc|WROC|wroc2000|wroc2k|WROC3000|WROC3K|wrok3000|wrock3k|OM50|OM20)
	export dev_pass=admin
	;;
HX4E)
	export dev_pass=hx4
	;;
*)
	echo "Your device is unknown!!"
	exit 1
esac

echo 3 > /proc/sys/vm/drop_caches
trap "cleanup" 0 2

cleanup () {
	rm -f /var/run/tmp*
	echo 3 > /proc/sys/vm/drop_caches
	rm -f /var/run/*.tcl 
	#rm -f /var/run/tcl_lib/*.tcl
	exit
}

cd /var/run

if [ ! -d /var/lib/tcl8.6 ];then
	mkdir -p /var/lib/tcl8.6
fi

if [ ! -f /var/lib/tcl8.6/init.tcl ];then
	wget ftp://dspang:dspang123@10.129.20.80/ftp/mips/init.tcl
	mv init.tcl /var/lib/tcl8.6
fi

if [ ! -f /var/run/tclsh ];then
	wget ftp://dspang:dspang123@10.129.20.80/ftp/mips/tclsh
	chmod +x tclsh
fi

if [ ! -d /var/run/tcl_lib/ ];then
	mkdir tcl_lib
fi

if [ ! -f /var/run/curl ];then
	wget ftp://dspang:dspang123@10.129.20.80/ftp/mips/curl
        chmod +x curl
fi

if [ ! -f /var/run/jq ];then
	wget ftp://dspang:dspang123@10.129.20.80/ftp/mips/jq
        chmod +x jq
fi

if [ ! -f /var/run/tcl_lib/json.tcl ];then
	wget ftp://dspang:dspang123@10.129.20.80/ftp/auto_test/json.tcl
	mv json.tcl /var/run/tcl_lib/
        chmod +x /var/run/tcl_lib/json.tcl
fi

if [ ! -f /var/run/tcl_lib/libssl.so.1.0.0 -o ! -f /var/run/tcl_lib/libcrypto.so.1.0.0 ];then
	wget ftp://dspang:dspang123@10.129.20.80/ftp/mips/libcrypto.so.1.0.0
	wget ftp://dspang:dspang123@10.129.20.80/ftp/mips/libssl.so.1.0.0
	mv libcrypto.so.1.0.0 tcl_lib
	mv libssl.so.1.0.0 tcl_lib
fi

if [ ! -f /var/run/tcl_lib/libtls1.6.4.so -o ! -f /var/run/tcl_lib/tls.tcl ];then
	wget -q ftp://dspang:dspang123@10.129.20.80/ftp/mips/libtls1.6.4.so
	wget -q ftp://dspang:dspang123@10.129.20.80/ftp/mips/tls.tcl
	mv libtls1.6.4.so tcl_lib
	mv tls.tcl tcl_lib
fi

export LD_LIBRARY_PATH=/var/run/tcl_lib:/lib/
export PATH="$PATH:/var/run/"


#echo "Now dowloading scripts"
wget -q ftp://dspang:dspang123@10.129.20.80/ftp/auto_test/common.tcl	 	; chmod +x common.tcl
wget -q ftp://dspang:dspang123@10.129.20.80/ftp/auto_test/login.tcl	 	; chmod +x login.tcl
wget -q ftp://dspang:dspang123@10.129.20.80/ftp/auto_test/logout.tcl	 	; chmod +x logout.tcl
wget -q ftp://dspang:dspang123@10.129.20.80/ftp/auto_test/get_device_status.tcl ; chmod +x get_device_status.tcl
wget -q ftp://dspang:dspang123@10.129.20.80/ftp/auto_test/unbind.tcl 		; chmod +x unbind.tcl
wget -q ftp://dspang:dspang123@10.129.20.80/ftp/auto_test/bind.tcl 		; chmod +x bind.tcl
wget -q ftp://dspang:dspang123@10.129.20.80/ftp/auto_test/enable_cloud.tcl 	; chmod +x enable_cloud.tcl
wget -q ftp://dspang:dspang123@10.129.20.80/ftp/auto_test/unable_cloud.tcl 	; chmod +x unable_cloud.tcl
wget -q ftp://dspang:dspang123@10.129.20.80/ftp/auto_test/get_user_dev.tcl 	; chmod +x get_user_dev.tcl
wget -q ftp://dspang:dspang123@10.129.20.80/ftp/auto_test/activate.tcl 		; chmod +x activate.tcl
wget -q ftp://dspang:dspang123@10.129.20.80/ftp/auto_test/gen_auth_code.tcl	; chmod +x gen_auth_code.tcl
wget -q ftp://dspang:dspang123@10.129.20.80/ftp/auto_test/cloudae.tcl		; chmod +x cloudae.tcl



single_test () {
	echo
	echo '*'
	echo "*$1..."
	echo '*'
	if [ "$1" = "bind..." -o "$1" = "bind" ];then
		echo "Now bind to $3 $4 ......"
	fi
	/var/run/$2 $3 $4 $5 
	return $?
}
single_test "login..." login.tcl

#######################################################################
single_test "Enable_cloud..." enable_cloud.tcl
if [ "$?" -eq 9 ];then
	echo -e "id80000=on OK "
	r0=9
else
	echo -e "id80000=on FAILED"
	r0=1
fi

if [ 5 -eq `ps aux | grep cloudae | grep -v grep  | wc -l` ];then
        echo -e "5 cloudae processes OK "
        r1=9
else
        echo -e "5 cloudae processes FAILED "
        r1=1
fi

if [ "on" = "`cat /var/config/cloud/pluginmgr.ini | grep cloudserver | awk -F '=' '{print $2}'| sed 's/ //g'`" ];then
        echo -e "cloudserver=on OK "
        r2=9
else
        echo -e "cloudserver=on FAILED "
	echo "cloudserver: `cat /var/config/cloud/pluginmgr.ini | grep cloudserver`"
        r2=1
fi

if [ "$r0" = 9 -a "$r1" = 9 -a "$r2" = 9 ];then
	echo -e "\033[32mEnable cloud OK \033[0m"
else
	echo -e "\033[31mEnable cloud FAILED \033[0m"
fi

#######################################################################	
check_bind_status () {
	#usr_dev=`./get_user_dev.tcl $2 $3`
	usr_dev=`./curl -s -H "Authorization:Bearer $3" "http://$api_site:80/v1/devices?user_id=$2"`
	if [ "$1" = "bind" ];then
		if [ ! -z "`echo $usr_dev | grep $device_id`" ]; then 
  		      echo -e "\033[32mBind OK \033[0m"
		else
        		echo -e "\033[31mBind FAILED \033[0m"
		        echo $usr_dev
		fi
	else
		if [  -z "`echo $usr_dev | grep $device_id`" -a -z "`echo $usr_dev | grep error`" -a ! -z "`echo $usr_dev | grep ok`" ]; then 
  		      echo -e "\033[32mUnbind OK \033[0m"
		else
        		echo -e "\033[31mUnbind FAILED \033[0m"
        		echo $usr_dev
		fi
	fi
}

i=0
while [ "$i" -lt 50 ];do
i=`expr 1 + $i`
#######################################################################
single_test "bind..." bind.tcl $email $password
check_bind_status "bind" $user_id $strong_token

#######################################################################
#test cloudae 
echo
single_test "tcpproxy..." cloudae.tcl
#######################################################################

single_test "Unbind..." unbind.tcl
check_bind_status "unbind" $user_id $strong_token

#single_test "bind..." bind.tcl $user_id $password
#check_bind_status "bind" $user_id $strong_token

#single_test "Unbind..." unbind.tcl
#check_bind_status "unbind" $user_id $strong_token

single_test "bind..." bind.tcl $email1 $password1
check_bind_status "bind" $user_id1 $strong_token1

single_test "Unbind..." unbind.tcl
check_bind_status "unbind" $user_id1 $strong_token1

#single_test "bind..." bind.tcl $user_id1 $password1
#check_bind_status "bind" $user_id1 $strong_token1

#single_test "Unbind..." unbind.tcl
#check_bind_status "unbind" $user_id1 $strong_token1

#######################################################################
#single_test "bind through active token" activate.tcl $active_token
#check_bind_status "bind" $user_id $strong_token

#single_test "Unbind..." unbind.tcl
#check_bind_status "unbind" $user_id $strong_token

#single_test "bind through active token" activate.tcl $active_token1
#check_bind_status "bind" $user_id1 $strong_token1

#single_test "Unbind..." unbind.tcl
#check_bind_status "unbind" $user_id1 $strong_token1
done

#######################################################################

check_auth_status () {
	if [ "$1" = "device" ];then
		echo device		
	else
		echo icloud
	fi
}

#single_test "generate authcode..." gen_auth_code.tcl
#if [ "$?" = 9 ];then
#	echo "gen authcode OK"
#else
#	echo "gen authcode FAILED"
#fi

#######################################################################




single_test "unable_cloud..." unable_cloud.tcl
if [ "$?" -eq 9 ];then
        echo -e "id80000=off OK "
        r0=9
else
        echo -e "id80000=off FAILED"
        r0=1
fi
if [ -z "`ps aux | grep cloudae | grep -v grep`" ];then
	echo "cloudae killed OK"
	r1=9
else
	echo "cloudae exist! FAILED"
	r1=1
fi

if [ "`cat /var/config/cloud/pluginmgr.ini | grep cloudserver | awk -F '=' '{print $2}'| sed 's/ //g'`" = off ];then
	echo "cloudserver=off OK"
	r2=9
else
	echo "cloudserver=off FAILED"
        echo "cloudserver: `cat /var/config/cloud/pluginmgr.ini | grep cloudserver`"
	r2=9
fi
if [ "$r0" = 9 -a "$r1" = 9 -a "$r2" = 9  ];then
        echo -e "\033[32mUnable cloud OK \033[0m"
else
        echo -e "\033[31mUnable cloud FAILED \033[0m"
fi

#######################################################################
single_test "logout..." logout.tcl

