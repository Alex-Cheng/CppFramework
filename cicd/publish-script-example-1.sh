#!/usr/bin/env bash
#创建时间相关文件夹
time=$(date "+%Y-%m-%d")
name="release-23.3-$time\_$BUILD_ID"
mkdir="ssh clickhouse@172.17.0.17 \"mkdir /var/www/html/debian/$name\""  || exit 1
echo ${mkdir} |awk '{run=$0;system(run)}'
pwd
#拷贝过去
scp="scp ./build/programs/clickhouse  clickhouse@172.17.0.17:/var/www/html/debian/$name" || exit 1
echo ${scp} |awk '{run=$0;system(run)}'

if [[ $publish == 'true' ]]; then
	publishName="2303B"$BUILD_ID
    publishMkdir="ssh clickhouse@172.17.0.17 \"mkdir /var/www/html/releases/$publishName\""  || exit 1
	echo ${publishMkdir} |awk '{run=$0;system(run)}'
    publishScp="scp ./build/programs/clickhouse  clickhouse@172.17.0.17:/var/www/html/releases/$publishName" || exit 1
    echo ${publishScp} |awk '{run=$0;system(run)}'
fi
