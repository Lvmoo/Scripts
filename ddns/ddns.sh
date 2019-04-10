#!/usr/bin/env bash
hostname=`cat /etc/hostname`
dns_records=""
domain=YOU_DOMAIN
zone_identifier=ZONE_ID
x_auth_email=EMAIL
x_auth_key=KEY

resolvable_value=$(dig $hostname.$domain @1.1.1.1 | grep -v ";" | grep $hostname.$domain | awk '{print $5}')
local_ip=$(curl -s https://api.lvmoo.com/ip/ )

if [[ -z $dns_records ]];then
    #echo "dns_records is empty"
    #echo -n "Continue or exit? (y or n)"
    #read flag
    #if [ "$flag" = "y" -o "$flag" = "Y" ] ; then
        dns_records=$hostname
    #else
    #    exit
    #fi
fi
echo "即将查寻 $dns_records.$domain 的DNS解析记录"
if [[ -z $resolvable_value ]];then
    echo 查寻 $dns_records.$domain DNS解析记录异常或解析值不存在
    exit
fi

id=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$zone_identifier/dns_records?type=A&name=$dns_records.$domain&page=1&per_page=20&order=type&direction=desc&match=all" \
     -H "X-Auth-Email: $x_auth_email" \
     -H "X-Auth-Key: $x_auth_key" \
     -H "Content-Type: application/json" | jq '.result[0].id' | awk -F '"' '{print $2}')


function CHANGE(){
curl -X PUT "https://api.cloudflare.com/client/v4/zones/$zone_identifier/dns_records/$id" \
-H "X-Auth-Email: $x_auth_email" \
-H "X-Auth-Key: $x_auth_key" \
-H "Content-Type: application/json" \
--data '{"type":"A","name":"'$dns_records'.'$domain'","content":"'$local_ip'","ttl":1,"proxied":false}'
}

function JUDGE(){
if [ "$resolvable_value" == "$local_ip" ];then
    echo "解析值($resolvable_value)与本机ip($local_ip)相同,本次检测完成"
    exit
else
    echo "解析值($resolvable_value)与本机ip($local_ip）不一致，即将修改dns解析值"
    CHANGE
fi
}

JUDGE