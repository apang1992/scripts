#!/bin/bash
. profile
exec 16>&1

echo "*********************************************************************************"
echo "*                                 api tool  v0.1                                *"
echo "*********************************************************************************"

trap 'command=""' 2

command="a"

for ((i=0;;i++)) ; do 
	if [  $i -ne 0 -a -n  "$command" ] ; then
		echo "*********************************************************************************"
	fi

	if [ ! -z  $command  ] ;then
		echo
		echo "0,list my tokens"
		echo "521,list user's all devices			531,foo"
		echo "522,show a specific device information		532,show user's all anylink services"
		echo "523,add a new device				533,create an anylink service"
		echo "524,modify a deivce				534,show  an anylink service"
		echo "525,delete a device				535,modify an anylink service"
		echo "526,bind device					536,delete an anylink service"
		echo "527,unbind a device				537,show device's all anylink services"
		echo "528,connect to cloud				538,foo"
		echo "529,Activate a device				539,foo"
		echo "5210,update agent"
		echo "5211,get auth_code"
		echo "q,exit"
		echo
	fi
	echo -n "Please input a request:"

	read command

	case $command in 
		"0")
			list_tokens.sh
			continue
			;;
		"521") 
			echo -n "input user_id(default:$user_id):"
			read view_user_id
			echo -n "show your token(default:serviceToken):"
			read token
			if [ "$view_user_id" = "$user_id"  -o "$view_user_id" = "self" -o "$view_user_id" = "" ];then
				uri="/v1/devices?user_id=$user_id"
			else
				uri="/v1/devices?user_id=$view_user_id"
			fi
			method="GET"
			body=""
			auth_method="Bearer"
			;;
		"522")
			echo -n "input device_id:"
			read device_id
			echo -n "your token(default:serviceToken):"
			read token
			uri="/v1/devices/$device_id"
			method="GET"
			body=""
			auth_method="Bearer"
			;;
		"523")
			echo "not implemented"
			continue
			;;
		"524")
			echo "not implemented"
			continue
			;;
		"525")
			echo "not implemented"
			continue
			;;
		"526")
			echo -n "input mac:"
                        read mac
                        device_id=`echo "$mac" | nc 10.129.20.80 8083 | cut -b 1-36`
                        echo -n "active token(default $active_token($mail_box)):"
                        read token
                        if [ "$token" = "" ];then token=$active_token ;else token=$token ; fi
			uri="/v1/devices/$device_id/actions/bind"
			method="POST"
			body=""
			auth_method="Bearer"
			;;
		"527")
			echo -n "user_id(default $user_id):"
			read view_user_id
			echo -n "device_id:"
			read device_id
			if [ "$view_user_id" = "$user_id"  -o "$view_user_id" = "self" -o "$view_user_id" = "" ];then
				uri="/v1/devices/$device_id/actions/bind?user_id=$user_id"
			else
				uri="/v1/devices/$device_id/actions/bind?user_id=$view_user_id"
			fi
			method="DELETE"
			token=""
			body=""
			auth_method="Bearer"
			;;
		"528")
			echo "not implemented"
			continue
			;;
		"529")
			echo -n "input mac:"
			read mac
			device_id=`echo "$mac" | nc 10.129.20.80 8083 | cut -b 1-36`
			echo -n "active token(default $active_token($mail_box)):"
			read token
			if [ "$token" = "" ];then token=$active_token ;else token=$token ; fi
			uri="/v1/devices/$device_id/actions/activate"
			method="POST"
			body="user_id=$user_id&device_id=$device_id"
			auth_method="Bearer"
			;;
		"5210")
			echo "not implemented"
			continue
			;;
		"5211")
			echo -n "device id:"
			read device_id
			echo -n "device key:"
			read device_key
			method="POST"
			uri="/v1/devices/authcodes?device_id=$device_id"
			token=$(echo -n "$device_key:x-auth-device"|base64 -w 0)
			auth_method="Basic"
			;;
		"532")
			echo -n "user_id(default,$user_id):"
			read view_user_id
			echo -n "show your token(default:serviceToken):"
			read token

			if [ "$view_user_id" = "$user_id"  -o "$view_user_id" = "self" -o "$view_user_id" = "" ];then
				uri="/v1/services/anylink?user_id=$user_id"
			else
				uri="/v1/services/anylink?user_id=$view_user_id"
			fi
			method="GET"
			body=""

			auth_method="Bearer"
			;;
		"533")
			echo "not implemented"
			continue
			;;
		"534")
			echo -n "service_id:"
			read service_id
			echo -n "user_id:"
			read user_id
			uri="/v1/services/anylink/$service_id?user_id=$user_id"
			method="GET"
			body=""
			auth_method="Bearer"
			;;
		"536")
			echo "not implemented"
			continue
			;;
		"537")
			echo "not implemented"
			continue
			;;
		"q"|"Q")
			echo "Byebye"
			exit 0
			;;
		*) 
			command=""
			;;

	esac

	if [ "$command" = "" ];then
		continue
	fi



	if [  "$token" = "service"  -o "$token" = "" ] ;then
		token=$(getServiceToken.sh )
	fi

	if [ -z $body ] ; then

		echo -e -n "$method $uri HTTP/1.1\n\
Content-Type:application/x-www-form-urlencoded;charset=UTF-8\n\
Host:$api_host
Authorization:$auth_method $token\n\
Connection:close\n\n" | nc  $nc_flag $api_site $api_port 
	else
		content_length=${#body}

		echo -e -n "$method $uri HTTP/1.1\n\
Host:$api_host
Content-Type:application/x-www-form-urlencoded;charset=UTF-8\n\
Connection:close\n\
Authorization:$auth_method $token\n\
Content-Length:$content_length\n\n$body" | nc  $nc_flag $api_site $api_port 
	fi

	echo

done
