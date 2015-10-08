#!/bin/bash

. profile
exec 16>&1

echo "*******************************************************************"
echo "*                       token manager v0.1                        *"
echo "*******************************************************************"

for ((i=0;;i++)) ; do 

	if [ ! $i -eq 0 ] ; then
		echo "*******************************************************************"
	fi
	echo
	echo "1,get your tokens"
	echo "2,create a token"
	echo "3,delete a token"
	echo "4,get a single token"
	echo "5,update a token"
	echo "6,reset a token"
	echo "q,exit"
	echo
	echo -n "Please input the request :"

	read command

	case $command in 
		"1") 
			uri="/v1/auth/tokens?user_id=$user_id"
			method="GET"
			body=""
			;;
		"2")
			uri="/v1/auth/tokens"
			echo -n "title:"
			read title

			echo -n "grantee_id(default:$user_id):"
			read grantee_id
			if [ "$grantee_id" = "" ];then
				grantee_id=$user_id
			fi	      

			scopes=$(read_scope.sh)

			echo "########"  $scopes


			if [ "$scopes" = "r" ];then continue ; fi
			body="user_id=$user_id&title=$title&scopes=$scopes&grantee_id=$grantee_id"
			method="POST"
			;;
		"3")
			list_tokens.sh
			echo -n "which token do you want to delete(id):"
			read token_id
			uri="/v1/auth/tokens/id/$token_id"
			method="DELETE"
			;;
		"4")
			list_tokens.sh
			echo -n "which token do you want to know(id):"
			read token_id
			uri="/v1/auth/tokens/id/$token_id"
			method="GET"
			;;
		"5")
			list_tokens.sh
			echo -n "Please input the token(id):"
			read token_id

			echo -n "input the token string(string):"
			read token_string

			echo -n "title:"
			read title

			echo -n "grantee_id:"
			read grantee_id

			scopes=$(read_scope.sh)

			if [ "$scopes" = "r" ];then continue ; fi
			uri="/v1/auth/tokens/id/$token_id"
			body="user_id=$user_id&title=$title&scopes=$scopes&grantee_id=$grantee_idi&token=$token_string"
			method="PUT"
			;;
		"6")
			list_tokens.sh
			echo -n "input the token(string):"
			read token
			uri="/v1/auth/tokens/$token?user_id=$user_id"
			method="POST"
			;;
		"q"|"Q")
			echo "Byebye"
			exit 0
			;;
		*) 
			continue
			;;

	esac

	command=""

	#getServiceToken.sh
	serviceToken=$(getServiceToken.sh )
	echo $serviceToken
	if [ -z $body ] ; then

		echo -e -n "$method $uri HTTP/1.1\n\
Host:$icloud_host\n\
Content-Type:application/x-www-form-urlencoded;charset=UTF-8\n\
Connection:close\n\
Cookie:serviceToken=$serviceToken\n\n" | nc $nc_flag $icloud_site $icloud_port 
	else
		length=${#body}

		echo -e -n "$method $uri HTTP/1.1\n\
Host:$icloud_host\n\
Content-Type:application/x-www-form-urlencoded;charset=UTF-8\n\
Connection:close\n\
Cookie:serviceToken=$serviceToken\n\
Content-Length:$length\n\n$body" | nc  $nc_flag $icloud_site $icloud_port 
	fi

	echo

done
