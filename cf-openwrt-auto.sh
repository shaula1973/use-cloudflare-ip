#!/bin/bash

[[ ! -d "/panyi/cloudflare" ]] && mkdir -p /panyi/cloudflare
cd /panyi/cloudflare

if [[ ! -f "CloudflareST" ]]; then
	wget -N https://github.com/XIU2/CloudflareSpeedTest/releases/download/v2.0.3/CloudflareST_linux_386.tar.gz
	tar -xvf CloudflareST_linux_386.tar.gz
	chmod +x CloudflareST
fi

##注意修改！！！
#/etc/init.d/haproxy stop
#/etc/init.d/passwall stop
wait

./CloudflareST -dn 10 -tll 40 -o cf_result.txt
wait
sleep 3

if [[ -f "cf_result.txt" ]]; then
	first=$(sed -n '2p' cf_result.txt | awk -F ',' '{print $1}') && echo $first >>ip-all.txt
	second=$(sed -n '3p' cf_result.txt | awk -F ',' '{print $1}') && echo $second >>ip-all.txt
	third=$(sed -n '4p' cf_result.txt | awk -F ',' '{print $1}') && echo $third >>ip-all.txt
	wait
	uci commit passwall
	wait
	##注意修改！！！
	sed -i "s/$(uci get passwall.03091b605d5e410aa300b8c6379afc9d.address)/${first}/g" /etc/config/passwall
	it
	uci commit passwall
	wait
	[[ $(/etc/init.d/haproxy status) != "running" ]] && /etc/init.d/haproxy start
	wait
	[[ $(/etc/init.d/passwall status) != "running" ]] && /etc/init.d/passwall start
	# wait
	# if [[ -f "ip-all.txt" ]]; then
	# 	sort -t "." -k4 -n -r ip-all.txt >ip-all-serialize.txt
	# 	uniq -c ip-all.txt ip-mediate.txt
	# 	sort -r ip-mediate.txt >ip-statistics.txt
	# 	rm -rf ip-mediate.txt
	# fi
fi
