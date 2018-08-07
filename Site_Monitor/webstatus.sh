#!/usr/bin/env bash
#=================================================
#	System Required: CentOS/Debian/Ubuntu
#	Description: site monitor
#	Version: 1.0.1
#	Author: Kay
#	Blog: https://wwww.lvmoo.com/xxx.love
#=================================================
function set_env() {
time_out=9
#超时时间
monitor_dir=/srv/monitor/
#存放目录设定
ft_sendkey="SENDKEY"
#方糖api的key
start_init
}
function start_init() {
if [ ! -d $monitor_dir ]; then
  mkdir $monitor_dir
fi
cd $monitor_dir
web_stat_log=web.status
if [ ! -f $web_stat_log ]; then
  touch $web_stat_log
fi
server_list_file=server.list
if [ ! -f $server_list_file ]; then
  echo "`date '+%Y-%m-%d %H:%M:%S'` ERROR:$server_list_file NOT exists!"
  echo "`date '+%Y-%m-%d %H:%M:%S'` ERROR:$server_list_file NOT exists!" >>$web_stat_log
  exit
fi
monitor
}
#total=`wc -l $server_list_file|awk '{print $1}'`
function monitor() {
for website in `cat $server_list_file`
do
  sum=0
  for((i=1;i<=3;i++));
  do
    url="$website"
    server_status=`curl -o /dev/null -s -m $time_out --connect-timeout $time_out -w %{http_code}::%{time_total}"\n" "$url" `
    server_code=`echo $server_status | awk -F "::" '{ print $1 }'`
    if [ "$server_code" = "000" ]; then
      let sum++
    fi
    sleep 1
  done
  if [ "$sum" == "3" ];then
    echo "`date '+%Y-%m-%d %H:%M:%S'` visit $website status code 000 ERROR server can't connect at $time_outs or stop response at $time_outs"
    echo "`date '+%Y-%m-%d %H:%M:%S'` visit $website status code 000 ERROR server can't connect at $time_outs or stop response at $time_outs" >>$web_stat_log
    http --form POST http://pushbear.ftqq.com/sub \
      Cache-Control:no-cache \
      Content-Type:application/x-www-form-urlencoded \
      sendkey="$ft_sendkey" \
      desp='>**'$website'**

      "'$(date +%Y-%m-%d_%H:%M:%S)'"


      **ERROR!!!**
      3 times in a row
      status code 000
      server can not connect at '$time_out' or stop response at '$time_out'' \
      text=Site_connect_error
    #sleep 60
  else
    echo "`date '+%Y-%m-%d %H:%M:%S'` visit $website status code 200 OK"
    echo "`date '+%Y-%m-%d %H:%M:%S'` visit $website status code 200 OK" >>$web_stat_log
  fi
  sleep 1
done
sleep 30
start_init
}
set_env
