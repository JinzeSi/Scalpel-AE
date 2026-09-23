FILENAME="commit-1.txt"

sed -n '1~2p' mysql-order-priority.txt > mysql-order.txt
echo "测试输出开始"
rm /data/sjz/call_analyse2.txt

cp /data2/sjz/Pre-knowledge-mysql/sql_parse/sql_parse-27cd03548955749bd18c30e0e96ea798937375f0.cc /data2/sjz/Pre-knowledge-mysql/sql_parse/sql_parse.cc



rm build_KeyValue_hashTable.txt


cp mysql-BB/init_file_27cd03548955749bd18c30e0e96ea798937375f0/mysql-BB-res-2.txt ./mysql-BB-res-2-new.txt
cp mysql-BB/init_file_27cd03548955749bd18c30e0e96ea798937375f0/mysql-BB-res-3.txt ./mysql-BB-res-3-new.txt
sh updateCommit-new-mysql.sh $FILENAME


