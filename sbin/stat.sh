#!/bin/sh
users_aws='echo "use newrockcloud; select id,userid,email,status,case when length(login_ip) < 2 then \"---\" else login_ip end as login_ip,ifnull(updated_at,\"unknown\") as updated_at from user_passport ; " | mysql -unwcloud -pnewrock2015 -h54.223.169.152 | column -t | expand'
eval $users_aws > users.txt$$
date=`head caculate.sh  | grep start | sed "s/.*\(201.-..-..\).*/\1/g"`
start=`head caculate.sh  | grep start | sed 's/.*\(201.-..-.. ..:..:..\)"/\1/g'`
end=`head caculate.sh  | grep end | sed 's/.*\(201.-..-.. ..:..:..\)"/\1/g'`
count=`./caculate.sh aws.json | jq 'length'`
echo "从" $start "到" $end "有" $count "台新设备" "在"
./caculate.sh  aws.json | jq 'map(.active_addr)| sort' | sed "s/,$//g" | uniq -c  | sort -k 1 -n -r | grep -v '1 \[' | grep -v '1 \]'
echo "激活.其中"
./caculate.sh  aws.json | jq 'map(.product_type)| sort' | sed "s/,$//g" | uniq -c  | sort -k 1 -n -r | grep -v '1 \[' | grep -v '1 \]'
echo "绑定到:"
./caculate.sh  aws.json | jq 'map(.user_id)| sort' | sed "s/,$//g" | uniq -c  | sort -k 1 -n -r | grep -v '1 \[' | grep -v '1 \]' > u.txt$$
for pair in `cat users.txt$$  | awk '{print $2"-"$3}' | grep -v userid`;do 
        uid=`echo $pair | awk -F '-' '{print $1}'`
        email=`echo $pair | awk -F '-' '{print $2}'`
        #echo $pair $uid $email
        sed  -i "/$uid/s/$/\t$email/g" u.txt$$
done
cat u.txt$$

echo ""
echo ""
echo "当前云平台总计:"
echo " 用户设备:"
cat aws.json | jq '.devices | map(.user_id)| sort' | sed "s/,$//g" | uniq -c  | sort -k 1 -n -r | grep -v '1 \[' | grep -v '1 \]'  > u.txt$$
for pair in `cat users.txt$$  | awk '{print $2"-"$3}' | grep -v userid`;do 
        uid=`echo $pair | awk -F '-' '{print $1}'`
        email=`echo $pair | awk -F '-' '{print $2}'`
        #echo $pair $uid $email
        sed  -i "/$uid/s/$/\t$email/g" u.txt$$
done
cat u.txt$$
rm -f u.txt$$ users.txt$$
echo ""
echo " 在线状态:"
cat aws.json | jq '.devices | map(.connection_status)| sort' | sed "s/,$//g" | uniq -c  | sort -k 1 -n -r | grep -v '1 \[' | grep -v '1 \]'
echo ""
echo " 设备型号:"
cat aws.json | jq '.devices | map(.product_type)| sort' | sed "s/,$//g" | uniq -c  | sort -k 1 -n -r | grep -v '1 \[' | grep -v '1 \]'
echo ""
echo " 设备分布:"
cat aws.json | jq '.devices | map(.connection_addr)| sort' | sed "s/,$//g" | uniq -c  | sort -k 1 -n -r | grep -v '1 \[' | grep -v '1 \]'

