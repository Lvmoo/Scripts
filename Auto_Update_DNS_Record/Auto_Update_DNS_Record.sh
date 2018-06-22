#!/usr/bin/env bash
#=================================================
#	System Required: CentOS/Debian/Ubuntu
#	Description: Auto Update DNS Record
#	Version: 1.1.1
#	Author: Kay
#	Blog: https://wwww.lvmoo.com/931.love
#=================================================
function SET_ENV() {
  export LANG=zh_CN.UTF-8
  export domain=lvmoo.com
  export domain_A=1.1.1.1
  export backup1_A=2.2.2.2
  export backup2_A=3.3.3.3
  START_INIT
}
function START_INIT() {
  sleep 10
  server_add=$(ping -c 1 $domain | grep PING | awk '{ print $3 }' | awk -F "[()]" '{ print $2 }')
  echo `date +"%Y-%m-%d %H:%M:%S"` START_INIT 输出 域名当前解析值 $server_add
  if  [ $server_add == $domain_A ]
  then
    echo `date +"%Y-%m-%d %H:%M:%S"` START_INIT 输出 调用 UPDATE_DNS_1 中
    UPDATE_DNS_1
  elif [ $server_add == $backup1_A ]
  then
    echo `date +"%Y-%m-%d %H:%M:%S"` START_INIT 输出 调用 UPDATE_DNS_2 中
    UPDATE_DNS_2
  elif [ $server_add == $backup2_A ]
  then
    echo `date +"%Y-%m-%d %H:%M:%S"` START_INIT 输出 调用 TIME_INTERVAL 判断时间间隔中
    TIME_INTERVAL
  else
    echo `date +"%Y-%m-%d %H:%M:%S"` START_INIT 输出 $server_add 不在脚本内的IP列表
    START_INIT
  fi
}

#时间间隔判断
TIME_INTERVAL() {
  Start_Time=`date +"%Y-%m-%d %H:%M:%S"` #脚本运行时间
  if [ ! -f  ./End_Time ];then
    End_Time="1970-01-01 08:00:00"
  else
    End_Time=`cat ./End_Time`
    #echo $End_Time
  fi
  STime=`date -d  "$Start_Time" +%s`
  ETime=`date -d  "$End_Time" +%s`
  Interval=`expr $STime - $ETime`
  #echo $Interval
  if  [ "$Interval" -ge "3600" ]; then
    echo `date +"%Y-%m-%d %H:%M:%S"` TIME_INTERVAL 输出 间隔时间 $Interval 大于等于60分钟
    echo `date +"%Y-%m-%d %H:%M:%S"` TIME_INTERVAL 输出 调用 UPDATE_DNS_3 中
    UPDATE_DNS_3
  else
    echo `date +"%Y-%m-%d %H:%M:%S"` 切换到 $backup2_A 时间`cat ./End_Time`
    echo `date +"%Y-%m-%d %H:%M:%S"` 切换到 $backup2_A 间隔时间小于60分钟,暂时不做国内线路到国外线路的切换
    START_INIT
  fi
}

function TIME_OUT() {
  sum=0
  for((i=1;i<=3;i++));
  do
    server_status=`curl -o /dev/null -s -m 7 --connect-timeout 7 -w %{http_code}::%{time_total}"\n" "$domain" `
    server_code=`echo $server_status | awk -F "::" '{ print $1 }'`
    if [ "$server_code" = "000" ]; then
      let sum++
    fi
    echo `date +"%Y-%m-%d %H:%M:%S"` TIME_OUT 输出server_status $server_status
    #sleep 2
  done
  echo `date +"%Y-%m-%d %H:%M:%S"` TIME_OUT 输出sum值 $sum
}

function UPDATE_DNS_1() {
  TIME_OUT
  if [ "$sum" == "3" ];then
    echo "`date +"%Y-%m-%d %H:%M:%S"`  地址 $server_add 连续三次连接超时"
    text1=$server_add超时告警
    desp1="`date +"%Y-%m-%d_%H:%M:%S"`地址:$server_add连续三次连接超时,即将切换DNS"
    curl https://pushbear.ftqq.com/sub --data 'sendkey=3920-fec0e0ffc173ae055c227f65c3748a08&text='$text1'&desp='$desp1''  --compressed
    text2=$domain第一次切换A记录
    desp2=`curl -X PUT "https://api.cloudflare.com/client/v4/zones/462fcdeaab0f3e9c4d90d5c06c722dee/dns_records/a2ac6dbb488378c116e4c12989c02b20" \
     -H "X-Auth-Email: 0@lvmoo.com" \
     -H "X-Auth-Key: dc70e6beb51a4947bbc2fb7c5312701a26da3" \
     -H "Content-Type: application/json" \
     --data '{"type":"A","name":"lvmoo.com","content":"2.2.2.2","ttl":1,"proxied":false}'`
    curl https://pushbear.ftqq.com/sub --data 'sendkey=3920-fec0e0ffc173ae055c227f65c3748a08&text='$text2'&desp='$desp2''  --compressed
    text3=www.$domain第一次切换A记录
    desp3=`curl -X PUT "https://api.cloudflare.com/client/v4/zones/462fcdeaab0f3e9c4d90d5c06c722dee/dns_records/ebbc4bbd95f17c12e2c59174b28134ec" \
     -H "X-Auth-Email: 0@lvmoo.com" \
     -H "X-Auth-Key: dc70e6beb51a4947bbc2fb7c5312701a26da3" \
     -H "Content-Type: application/json" \
     --data '{"type":"A","name":"www.lvmoo.com","content":"2.2.2.2","ttl":1,"proxied":false}'`
    curl https://pushbear.ftqq.com/sub --data 'sendkey=3920-fec0e0ffc173ae055c227f65c3748a08&text='$text3'&desp='$desp3''  --compressed
    sleep 60
  else
    echo `date +"%Y-%m-%d %H:%M:%S"` UPDATE_DNS_1 输出信息 线路 $domain_A OK 暂时不会切换到 $backup1_A
  fi
  START_INIT
}

function UPDATE_DNS_2() {
  TIME_OUT
  if [ "$sum" == "3" ];then
    echo "`date +"%Y-%m-%d %H:%M:%S"`  地址:$server_add 连续三次连接超时"
    text1=$server_add超时告警
    desp1="`date +"%Y-%m-%d_%H:%M:%S"`地址:$server_add连续三次连接超时,即将切换DNS"
    curl https://pushbear.ftqq.com/sub --data 'sendkey=3920-fec0e0ffc173ae055c227f65c3748a08&text='$text1'&desp='$desp1''  --compressed
    text2=$domain第二次切换A记录
    desp2=`curl -X PUT "https://api.cloudflare.com/client/v4/zones/462fcdeaab0f3e9c4d90d5c06c722dee/dns_records/a2ac6dbb488378c116e4c12989c02b20" \
     -H "X-Auth-Email: 0@lvmoo.com" \
     -H "X-Auth-Key: dc70e6beb51a4947bbc2fb7c5312701a26da3" \
     -H "Content-Type: application/json" \
     --data '{"type":"A","name":"lvmoo.com","content":"3.3.3.3","ttl":1,"proxied":false}'`
    curl https://pushbear.ftqq.com/sub --data 'sendkey=3920-fec0e0ffc173ae055c227f65c3748a08&text='$text2'&desp='$desp2''  --compressed
    text3=www.$domain第二次切换A记录
    desp3=`curl -X PUT "https://api.cloudflare.com/client/v4/zones/462fcdeaab0f3e9c4d90d5c06c722dee/dns_records/ebbc4bbd95f17c12e2c59174b28134ec" \
     -H "X-Auth-Email: 0@lvmoo.com" \
     -H "X-Auth-Key: dc70e6beb51a4947bbc2fb7c5312701a26da3" \
     -H "Content-Type: application/json" \
     --data '{"type":"A","name":"www.lvmoo.com","content":"3.3.3.3","ttl":1,"proxied":false}'`
    curl https://pushbear.ftqq.com/sub --data 'sendkey=3920-fec0e0ffc173ae055c227f65c3748a08&text='$text3'&desp='$desp3''  --compressed
    sleep 60
  else
    echo `date +"%Y-%m-%d %H:%M:%S"` UPDATE_DNS_2 输出信息 线路 $backup1_A OK 暂时不会切换到 $backup2_A
    date +"%Y-%m-%d %H:%M:%S" >./End_Time
  fi
  START_INIT
}

function UPDATE_DNS_3() {
  text1=$domain切回原IP通知
  desp1=`curl -X PUT "https://api.cloudflare.com/client/v4/zones/462fcdeaab0f3e9c4d90d5c06c722dee/dns_records/a2ac6dbb488378c116e4c12989c02b20" \
     -H "X-Auth-Email: 0@lvmoo.com" \
     -H "X-Auth-Key: dc70e6beb51a4947bbc2fb7c5312701a26da3" \
     -H "Content-Type: application/json" \
     --data '{"type":"A","name":"lvmoo.com","content":"1.1.1.1","ttl":1,"proxied":false}'`
  curl https://pushbear.ftqq.com/sub --data 'sendkey=3920-fec0e0ffc173ae055c227f65c3748a08&text='$text1'&desp='$desp1''  --compressed
  text2=www.$domain切回原IP通知
  desp2=`curl -X PUT "https://api.cloudflare.com/client/v4/zones/462fcdeaab0f3e9c4d90d5c06c722dee/dns_records/ebbc4bbd95f17c12e2c59174b28134ec" \
     -H "X-Auth-Email: 0@lvmoo.com" \
     -H "X-Auth-Key: dc70e6beb51a4947bbc2fb7c5312701a26da3" \
     -H "Content-Type: application/json" \
     --data '{"type":"A","name":"www.lvmoo.com","content":"1.1.1.1","ttl":1,"proxied":false}'`
  curl https://pushbear.ftqq.com/sub --data 'sendkey=3920-fec0e0ffc173ae055c227f65c3748a08&text='$text2'&desp='$desp2''  --compressed
  sleep 60
  START_INIT
}

function QUIT() {
  exit
}

SET_ENV
