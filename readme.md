# Sample Implementation of Kafka
A container based implementation of kafka using debezium connect to source data from mysql and push into required db.

## Steps to recreate:
### 1: Launch intance using docker-compose
```bash
docker-compose -f docker-comp-file.yml up -d
```
### 2: Configure mysql_db container
Launch mysql_db container's bash
 ```bash
docker container exec -it mysql_db bash
```
Launch into mysql
 ```bash
mysql --user=root --password=password
```
Assigning Permission and sourcing sql script
```bash
mysql> GRANT SELECT, LOCK TABLES, RELOAD, SHOW DATABASES, REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'debezium' IDENTIFIED BY 'debezium';  
mysql> FLUSH PRIVILEGES;
mysql> source /home/inventory.sql
mysql> exit
```
### 3: Register mysql connector to inventory database
```bash
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
```
Note: All the kafka topics will be named from table

### 4: Verify the messages getting logged into individual topics
Log into kafka bash
```bash
docker conatiner exec -it --user root kafka bash
```
See the messages in command line
```bash
bin/kafka-console-consumer.sh --bootstrap-server kafka:9092 --topic  dbserver1.inventory.orders --from-beginning
```
### 5: Run consumer file
install requirements and run the code
