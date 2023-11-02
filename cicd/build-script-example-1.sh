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
	rm -rf /mnt/$JOB_NAME/build
fi

#build
export CC=`which clang-15`
export CXX=`which clang++-15`
echo "Build ID: $BUILD_ID"
echo "Branch: $branch"


mkdir -p /mnt/$JOB_NAME/build
cmake -B /mnt/$JOB_NAME/build -S ./ -G Ninja \
-DCMAKE_C_COMPILER=$(which clang-15) \
-DCMAKE_CXX_COMPILER=$(which clang++-15) \
-DCMAKE_BUILD_TYPE=Release \
-DENABLE_CLICKHOUSE_ALL=ON \
-DENABLE_CLICKHOUSE_SERVER=ON \
-DENABLE_CLICKHOUSE_CLIENT=ON \
-DENABLE_CLICKHOUSE_BENCHMARK=ON \
-DENABLE_UTILS=OFF \
-DENABLE_TESTS=OFF \
-DENABLE_LIBRARIES=ON

(cd /mnt/$JOB_NAME/build && ninja) || exit 1


#设置测试环境
cd $WORKSPACE/tests
export PATH=/mnt/$JOB_NAME/build/programs/:$PATH
./config/install.sh
sleep 2s

#启动server
cd /mnt/$JOB_NAME/build/programs/
echo "try shutdown exist server"
if [[  -n `ps -aux |grep clickhouse-server|grep -v grep`  ]]; then
    /mnt/$JOB_NAME/build/programs/clickhouse-client --query="system shutdown"
    echo "shutdown exist server success"
    sleep 5s
else
    echo "no living server"
fi
pwd

#./clickhouse-server start >/dev/null 2>&1&
/mnt/$JOB_NAME/build/programs/clickhouse-server -C /etc/clickhouse-server/config.xml >/dev/null 2>&1 &
sleep 5s

# run test
cd $WORKSPACE/tests
./clickhouse-test --official-only --order asc --skip git s3 postgresql sqlite mysql filesystem caches cache hdfs 01086_odbc_roundtrip 01193_metadata_loading 01474_executable_dictionary 01674_executable_dictionary_implicit_key 01739_index_hint 01945_show_debug_warning 02015_executable_user_defined_functions 02043_user_defined_executable_function_implicit_cast 02152_http_external_tables_memory_tracking 02285_executable_user_defined_function_group_by 02457_filesystem_function 02521_cannot-find-column-in-projection 02554_log_faminy_support_storage_policy 02013_zlib_read_after_eof 02372_analyzer_join 02422_allow_implicit_no_password 02454_create_table_with_custom_disk 02456_BLAKE3_hash_function_test 02494_zero_copy_projection_cancel_fetch 01175_distributed_ddl_output_mode_long 02168_avro_bug 02187_msg_pack_uuid 02207_allow_plaintext_and_no_password 02420_stracktrace_debug_symbols 02497_remote_disk_fat_column 02116_clickhouse_stderr 00746_sql_fuzzy 00002_log_and_exception_messages_formatting 
# 00534_functions_bad_arguments2 已打开
#./clickhouse-test --official-only -- 00534_functions_bad_arguments
