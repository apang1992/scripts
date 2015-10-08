#!/bin/bash
exec 17>&1
exec 1>&16
echo 
echo "0,all"
echo "1,user"
echo "2,user:profile"
echo "3,user:full(only youself)"
echo "4,user:email"
echo "5,user:phone"
echo "6,device"
echo "7,device:full"
echo "8,device:info"
echo "9,device:anylink"
echo "A,device_range:all"

echo "B,device_mac:mac"
echo "C,device:active"
echo "r,return to main loop"
echo
echo -n "input the scope(s)(eg,356):"
read scope


MACINFO=$(echo $scope | sed -n "/B/p")

if [ "$MACINFO" != "" ];then
	echo -n "input mac list(eg,112233445566|AABBCCDDEEFF):"
	read mac_list
fi

exec 1>&17

if [ "$scope" = "" ];then
	scopes="all"
else
	scopes=$(echo $scope | sed "\
s/1/user,/;\
s/2/user:profile,/;\
s/3/user:full,/;\
s/4/user:email,/;\
s/5/user:phone,/;\
s/6/device,/;\
s/7/device:full,/;\
s/8/device:info,/;\
s/9/device:anylink,/;\
s/A/device_range:all,/;\
s/B/device_range:$mac_list,/;\
s/C/device:active,/\
" | sed "s/^\(.*\),$/\1/" | sed "s/,/%2C/g;s/:/%3A/g")
fi

if [ "$scope" = "r" ];then
	scopes="r"
fi

echo -n $scopes
