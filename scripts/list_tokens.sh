#!/bin/bash

serviceToken=$(getServiceToken.sh)
echo -e -n "\
GET /v1/auth/tokens?user_id=$user_id HTTP/1.1\n\
Content-Type:application/x-www-form-urlencoded;charset=UTF-8\n\
Connection:close\n\
Host:$icloud_host
Cookie:serviceToken=$serviceToken\n\n" | nc  $nc_flag $icloud_site $icloud_port #| sed -r -n -e '/id|scope|title|grantee|"token"/p' | sed -e "N;N;N;N;N;G"
echo
