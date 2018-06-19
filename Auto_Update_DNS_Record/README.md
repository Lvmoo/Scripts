简要说明
--------
**依赖服务**

 - [Cloudflare API][1]
 - [Server酱][2]（或[PushBear][3]）

**目标**

 - 根据站点当前的超时状况自动更新记录的解析值
 - 连连超时微信通知
 - 更新记录微信通知结果

**实现**

`TIME_INTERVAL()`
函数对上次更新解析记录做间隔判断，切换到最稳定线路后至少1小时后方可再更新解析记录。
`TIME_OUT()`
函数对监控的服务器进行超时检测，当连续3次超过7秒没有收到其回应认定访问超时。
`UPDATE_DNS_1()`
*脚本*

    curl -X PUT "https://api.cloudflare.com/client/v4/zones/462fcdeaab0f3e9c4d90d5c06c722dee/dns_records/a2ac6dbb488378c116e4c12989c02b20" \
    -H "X-Auth-Email: 0@lvmoo.com" \
    -H "X-Auth-Key: dc70e6beb51a4947bbc2fb7c5312701a26da3" \
    -H "Content-Type: application/json" \
    --data '{"type":"A","name":"lvmoo.com","content":"3.3.3.3","ttl":1,"proxied":false}

作用：用于更新解析记录
可以参照Cloudflare官方API进行设置。
*脚本*

    curl https://pushbear.ftqq.com/sub --data 'sendkey=3920-fec0e0ffc173ae055c227f65c3748a08&text='$text2'&desp='$desp2''  --compressed
作用：微信通知


需求说明
--------
[一个“反人类”解析记录变更需求的实现][4]


  [1]: https://api.cloudflare.com/
  [2]: http://sc.ftqq.com
  [3]: https://pushbear.ftqq.com/admin/#/
  [4]: https://wwww.lvmoo.com/archives/931.html
