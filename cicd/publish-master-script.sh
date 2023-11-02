#!/usr/bin/env bash
#创建时间相关文件夹
time=$(date "+%Y-%m-%d")
name="master-$time\_$BUILD_ID"
mkdir="ssh clickhouse@172.17.0.17 \"mkdir /var/www/html/debian/$name\""  || exit 1
echo ${mkdir} |awk '{run=$0;system(run)}'
pwd
#拷贝过去
scp1="scp ./build/programs/clickhouse  clickhouse@172.17.0.17:/var/www/html/debian/$name" || exit 1
scp2="scp ./build/prothentic/config/cluster_local.zip clickhouse@172.17.0.17:/var/www/html/debian/$name" || exit 1
scp3="scp ./build/prothentic/config/cluster_replicas_prod-single.zip clickhouse@172.17.0.17:/var/www/html/debian/$name" || exit 1
scp4="scp ./build/prothentic/config/cluster_replicas_prod-multi.zip clickhouse@172.17.0.17:/var/www/html/debian/$name" || exit 1
scp5="scp ./build/prothentic/config/single_prod.zip clickhouse@172.17.0.17:/var/www/html/debian/$name" || exit 1
scp6="scp ./build/prothentic/tools.zip clickhouse@172.17.0.17:/var/www/html/debian/$name" || exit 1
echo ${scp1} |awk '{run=$0;system(run)}'
echo ${scp2} |awk '{run=$0;system(run)}'
echo ${scp3} |awk '{run=$0;system(run)}'
echo ${scp4} |awk '{run=$0;system(run)}'
echo ${scp5} |awk '{run=$0;system(run)}'
echo ${scp6} |awk '{run=$0;system(run)}'

#重启server
if [[ -n `ssh clickhouse@172.17.0.17 'ps -aux |grep /home/clickhouse/ch-builds/release|grep -v grep'` ]]; then   
    ssh clickhouse@172.17.0.17 "/var/www/html/debian/$name/clickhouse client --port=9101 --user=default --password=123456  --query=\"system shutdown\""  || exit 1
 else
    echo "no server"
 fi
sleep 20s
ssh clickhouse@172.17.0.17 " /var/www/html/debian/$name/clickhouse server  --config /home/clickhouse/ch-builds/release/config-release.xml >/dev/null 2>&1&"   || exit 1
sleep 10s



if [[ $publish == 'true' ]]; then
	time=$(date "+%y%m")
	publishName="master"$time"B"$BUILD_ID
    publishMkdir="ssh clickhouse@172.17.0.17 \"mkdir /var/www/html/releases/$publishName\""  || exit 1
	echo ${publishMkdir} |awk '{run=$0;system(run)}'
    scp7="scp ./build/programs/clickhouse  clickhouse@172.17.0.17:/var/www/html/releases/$publishName" || exit 1
    scp8="scp ./build/prothentic/config/cluster_local.zip clickhouse@172.17.0.17:/var/www/html/releases/$publishName" || exit 1
    scp9="scp ./build/prothentic/config/cluster_replicas_prod-single.zip clickhouse@172.17.0.17:/var/www/html/releases/$publishName" || exit 1
	scp10="scp ./build/prothentic/config/cluster_replicas_prod-multi.zip clickhouse@172.17.0.17:/var/www/html/releases/$publishName" || exit 1
    scp11="scp ./build/prothentic/config/single_prod.zip clickhouse@172.17.0.17:/var/www/html/releases/$publishName" || exit 1
    scp12="scp ./build/prothentic/tools.zip clickhouse@172.17.0.17:/var/www/html/releases/$publishName" || exit 1
    echo ${scp7} |awk '{run=$0;system(run)}'
    echo ${scp8} |awk '{run=$0;system(run)}'
    echo ${scp9} |awk '{run=$0;system(run)}'
    echo ${scp10} |awk '{run=$0;system(run)}'
    echo ${scp11} |awk '{run=$0;system(run)}'
    echo ${scp12} |awk '{run=$0;system(run)}'
fi

