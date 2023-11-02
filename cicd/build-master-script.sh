#!/usr/bin/env bash
#submodule
if [ ! -f './contrib/avro/LICENSE.txt' ]; then
	rm -rf ./contrib/
	cp -r ../contrib  ./
fi

if [ ! -d './.git/modules/' ]; then
	cp -r ../modules  ./.git/
fi

if [[ $CleanBuild == 'true' ]]; then
	rm -rf ./build
fi

time=$(date "+%y%m")
tweak=$time"B"$BUILD_ID

#build
export CC=`which clang-15`
export CXX=`which clang++-15`

mkdir -p build
cd build
cmake .. -G Ninja \
-DCMAKE_C_COMPILER=$(which clang-15) \
-DCMAKE_CXX_COMPILER=$(which clang++-15) \
-DCMAKE_BUILD_TYPE=Release \
-DENABLE_CLICKHOUSE_ALL=OFF \
-DENABLE_CLICKHOUSE_SERVER=ON \
-DENABLE_CLICKHOUSE_CLIENT=ON \
-DENABLE_CLICKHOUSE_BENCHMARK=ON \
-DENABLE_CLICKHOUSE_KEEPER=ON \
-DENABLE_CLICKHOUSE_KEEPER_CONVERTER=ON \
-DENABLE_UTILS=OFF \
-DENABLE_TESTS=OFF \
-DVERSION_TWEAK=$tweak \
-DENABLE_LIBRARIES=ON

ninja || exit 1
ninja pro-archive-configs || exit 1
ninja pro-archive-tools || exit 1
cd ..


#启动server
cd ./build/programs/
if [[  -n `ps -aux |grep clickhouse-server|grep -v grep`  ]]; then
    ./clickhouse-client --query="system shutdown"
    sleep 10s
else
    echo "no server"
fi

 ./clickhouse-server  start >/dev/null 2>&1&
cd ../..
sleep 20s

#到目录下插入数据
cd ./tests/test_data/
export PATH=../../build/programs/:$PATH
./insert_test_data_0001.sh
./insert_test_data_0002.sh
./insert_test_data_0003.sh
cd ../
export PATH=../build/programs/:$PATH
sleep 2s
./run_test_dataset_all.sh || exit 1
