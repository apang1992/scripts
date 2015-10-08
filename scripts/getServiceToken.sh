#!/bin/bash
tmpfile="tmp"$$
sessionfile="session"$$
authfile="auth"$$
serviceTokenFile="serviceTokenFile"$$
serviceToken=$1
trap "rm -rf $tmpfile $passfile $authfile $serviceTokenFile $sessionfile; exit 0"   0 2 

exec 10<&1
exec 1>$sessionfile
body="user=$user_name&pwd=$password"
length=${#body}
nc $nc_flag $accounts_site $accounts_port << EOF
POST /passports/serviceLogin?callback=abc HTTP/1.1
Host: $accounts_host 
Content-Type: application/x-www-form-urlencoded
Connection:close
Content-Length:$length

user=$user_name&pwd=$password
EOF

exec 1>&10

#cat $sessionfile 

passToken=$(sed -n '/pass_token/{s/^.*"\([[:alnum:]]\{20,\}\).*$/\1/g;p}' $sessionfile)
beegoSessionId=$(sed -n '/beegosessionID/{s/^.*sessionID=\([[:alnum:]]*\);.*$/\1/g;p}' $sessionfile)

exec 11<&1
exec 1>$authfile
nc  $nc_flag $accounts_site $accounts_port << EOF
GET /passports/serviceAuth?userId=$user_id&session=zzzzz HTTP/1.1
Host:$accounts_host
Cookie: beegosessionID=$beegoSessionId;passToken=$passToken
Connection:close

EOF
exec 1>&11

auth=$(sed -n "/auth=/{s/^.*auth=\([[:alnum:]]*\).*$/\1/g;p}" $authfile)

exec 12<&1
exec 1>$serviceTokenFile

nc $nc_flag $icloud_site $icloud_port << EOF
GET /sts?auth=$auth HTTP/1.1
Host:$icloud_host
Connection:close

EOF

exec 1>&12

serviceToken=$(sed -n "/serviceToken=/{s/^.*serviceToken=\([[:alnum:]]\{20,\}\).*$/\1/g;p}" $serviceTokenFile)
echo -n  $serviceToken
