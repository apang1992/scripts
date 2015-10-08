#i:192.168.20.80	
#ii:10.129.20.80 	
#iii:10.129.20.88		
#ali:ali server
#aws:amazon server 
#awsl:aws local
public_flag=i

mail_box="dspang@newrocktech.com"
password=dspang123
#user_id=123456789 #amazon
user_id=1671920448 #192.168.20.80
#user_id=4069683838 #alibaba
#user_id=2671920448 #10.129.20.80
#user_id=3671920448 #10.129.20.88

user_name=$mail_box

device_id_prefix=$(echo "$user_id" | sed "s/^\([0-9]\{6\}\).*$/\1/")

if [ "$public_flag" = "aws" ];then
        active_token=NTI0MTIwZTUt.TNlOC00YmU1LWIwMGMtYjczNDVlMWI2NWEx
        strong_token=Y2VlZDc2MmYt.DI0Mi00NmU1LWJmYTUtY2UzOTJmZDlkMjQ0
        mqtt_server="ssl://ccs.newrockaws.com:8883"
        proxy_server="slave2.newrockaws.com"

        accounts_site=accounts.newrockaws.com
        accounts_port=80
        accounts_host="accounts.newrockaws.com"

        icloud_site=i.newrockaws.com
        icloud_port=80
        icloud_host="i.newrockaws.com"

        api_site=api.newrockaws.com
        api_port=80
        api_host="api.newrockaws.com"
        nc_flag="-i 1"

fi

if [ "$public_flag" = "awsl" ];then
        active_token=NTI0MTIwZTUt.TNlOC00YmU1LWIwMGMtYjczNDVlMWI2NWEx
        strong_token=Y2VlZDc2MmYt.DI0Mi00NmU1LWJmYTUtY2UzOTJmZDlkMjQ0
        mqtt_server="ssl://172.31.23.45:8883"
        proxy_server="172.31.23.47"

        accounts_site=172.31.23.46
        accounts_port=6900
        accounts_host="accounts.newrockaws.com"

        icloud_site=172.31.23.47
        icloud_port=6930
        icloud_host="i.newrockaws.com"

        api_site=172.31.23.47
        api_port=6940
        api_host="api.newrockaws.com"
        nc_flag="-i 0"

fi

if [ $public_flag = "i" ];then

	mqtt_server="ssl://192.168.20.80:1883"
	proxy_server="192.168.20.80"
	active_token=OTk5Y2YwYzkt.jIxNi00MzdmLTk2MzQtNzEyMzU1MmFjYWM0
	strong_token=N2NmOTBmYTEt.GUzNS00NzgyLWJlYmUtOWZjMjA0MGE3NTVm

        accounts_site=accounts.newrocktest.com
        accounts_port=443
	accounts_host="accounts.newrocktest.com"

        icloud_site=i.newrocktest.com
        icloud_port=443
	icloud_host="i.newrocktest.com"

        api_site=api.newrocktest.com
        api_port=443
	api_host="api.newrocktest.com"

	nc_flag="-i 0"
fi

if [ $public_flag = "iii" ];then

	mqtt_server="ssl://10.129.20.88:1883"
	proxy_server="10.129.20.88"

        accounts_site=10.129.20.88
        accounts_port=6900
	accounts_host="accounts.newrocktest.com"

        icloud_site=10.129.20.88
        icloud_port=6930
	icloud_host="i.newrocktest.com"

        api_site=10.129.20.88
        api_port=6940
	api_host="api.newrocktest.com"

	nc_flag="-i 0"
fi

if [ $public_flag = "ii" ];then
	mqtt_server="ssl://10.129.20.80:1883"
	proxy_server="10.129.20.80"
	strong_token=N2NmOTBmYTEt.GUzNS00NzgyLWJlYmUtOWZjMjA0MGE3NTVm
	active_token=OTk5Y2YwYzkt.jIxNi00MzdmLTk2MzQtNzEyMzU1MmFjYWM0

        accounts_site=10.129.20.80
        accounts_port=6900
	accounts_host="accounts.newrocktest80.com"

        icloud_site=10.129.20.80
        icloud_port=6930
	icloud_host="i.newrocktest80.com"

        api_site=10.129.20.80
        api_port=6940
	api_host="api.newrocktest80.com"
	nc_flag="-i 0"

fi

if [ $public_flag = "ali" ];then
	mqtt_server="ssl://121.41.103.71:8883"
	proxy_server="121.40.54.78"

        accounts_site=121.40.54.198
        accounts_port=80
	accounts_host="accounts.newrocktech.com"

        icloud_site=121.40.54.198
        icloud_port=80
	icloud_host="i.newrocktech.com"

        api_site=121.40.54.198
        api_port=80
	api_host="api.newrocktech.com"
	nc_flag="-i 1"

fi


###################################
#user_id=
#strong_token=
###################################

export active_token=$active_token
export strong_token=$strong_token
export mail_box=$mail_box
export email=$mail_box

export user_id=$user_id
export user_name=$user_name
export password=$password

export mqtt_server=$mqtt_server
export proxy_server=$proxy_server
export accounts_site=$accounts_site
export accounts_port=$accounts_port
export accounts_host=$accounts_host
export icloud_site=$icloud_site
export icloud_port=$icloud_port
export icloud_host=$icloud_host
export api_site=$api_site
export api_port=$api_port
export api_host=$api_host

export device_id_prefix=$device_id_prefix

export PATH=$PATH:`pwd`"/scripts":`pwd`"/bin"
export nc_flag=$nc_flag

