# Create directories
user=`whoami`
uid=`id -u $user`
gid=`id -g $user`

mkdir -p ./db_mnt/source/mysql_data
mkdir -p ./db_mnt/target/pg_data

mkdir -p ./zookeeper/data
mkdir -p ./zookeeper/logs
mkdir -p ./zookeeper/txns

mkdir -p ./kafka/data
mkdir -p ./kafka/logs

chown -R $uid:$gid ./db_mnt/source/mysql_data
chown -R $uid:$gid ./db_mnt/target/pg_data
chown -R $uid:$gid ./zookeeper/data
chown -R $uid:$gid ./zookeeper/logs
chown -R $uid:$gid ./zookeeper/txns
chown -R $uid:$gid ./kafka/data
chown -R $uid:$gid ./kafka/logs

chmod -R 777 ./airflow
chmod -R 777 ./db_mnt
chmod -R 777 ./kafka
chmod -R 777 ./mysql
chmod -R 777 ./zookeeper

# start containers
docker-compose -f docker-compose-dev-basic.yml up -d

# change the permission for my.cnf file
docker container exec -it mysql_db chmod 0444 etc/mysql/my.cnf

# restart mysql_db
docker container stop mysql_db
docker-compose -f docker-compose-dev-basic.yml up -d

# Prepare the user and db
docker container exec -it mysql_db bash
mysql --user=root --password=password 
mysql> GRANT SELECT, LOCK TABLES, RELOAD, SHOW DATABASES, REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'debezium' IDENTIFIED BY 'debezium';  
mysql> FLUSH PRIVILEGES;
mysql> source /home/inventory.sql
mysql> exit
exit

# Register mysql connector for inventory database
curl -i -X POST \
-H "Accept:application/json" \
-H "Content-Type:application/json" \
localhost:8083/connectors/ \
-d \
'{ "name": "digicertcom-inventory", 
"config": { 
    "connector.class": "io.debezium.connector.mysql.MySqlConnector", "tasks.max": "1", 
    "database.hostname": "mysql_db", 
    "database.port": "3306", 
    "database.user": "debezium", 
    "database.password": "debezium", 
    "database.server.id": "1", 
    "database.server.name": "dbserver1", 
    "database.include.list": "inventory", 
    "database.history.kafka.bootstrap.servers": "kafka:9092", 
    "database.history.kafka.topic": "dbhistory.inventory" 
    } 
}'

# Verify connector registry
curl -H "Accept:application/json" localhost:8083/connectors/

# Verify connector task
curl -i -X GET -H "Accept:application/json" localhost:8083/connectors/digicertcom-inventory

# Verify the status of the connector
curl -s "http://localhost:8083/connectors?expand=info&expand=status"

# Verify if the topics are created for each table
docker container exec -it kafka sh bin/kafka-topics.sh --zookeeper zookeeper:2181 --list

docker run -it --rm\
        --name watcher \
        --link zookeeper:zookeeper \
        --link kafka:kafka \
        --network dev_default \
        -e ZOOKEEPER_CONNECT=zookeeper:2181 \
        -e KAFKA_BROKER=kafka:9092 \
        -e KAFKA_LISTENERS=kafka:9092 \
        -e KAFKA_ADVERTISED_LISTENERS=kafka:9092 \
        debezium/kafka:1.3 \
        watch-topic -a -k dbserver1.inventory.customers
