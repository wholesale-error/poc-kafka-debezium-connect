import configparser
import sys,os,json
import mysql.connector
from confluent_kafka import Consumer

def getConfig(key):
    config = configparser.RawConfigParser()
    if os.path.isfile('kafka_config'):
        config.read('kafka_config')
    else:
        print("unable to read config file")
        return False

    try:
        config_dict=dict(config.items(key))
    except Exception as e:
        print(e)
        return False

    return config_dict

def kafka_consumer(topicName):
    kafka_dict=getConfig('kafka')
    bootstrap_servers=[kafka_dict['kafka_server']+':'+kafka_dict['kafka_root']]
    KafkaConsumer(value_deserializer=lambda m: json.loads(m.decode('ascii')))
    consumer = KafkaConsumer(topicName, group_id ='group1',bootstrap_servers = bootstrap_servers)
    
    for message in consumer:
        print("%s:%d:%d: key=%s value=%s" % (message.topic, message.partition,message.offset, message.key, message.value))

def db_push(data='', dml='',tabelname='',**kwargs):
    if data and dml:
        try:
            sql_conf=getConfig('mysql')
            conn = mysql.connector.connect(user=sql_conf['user'], password=sql_conf['password'],database=sql_conf['db'], host =['host'], **kwargs)
            cursor=conn.cursor()
            print(data)
            tablename=''

            if dml=='insert':
                query=f'insert into {tablename} values {tuple(data.values())}'
                cursor.execute(query)
                conn.commit()
            elif dml=='delete':
                del_str=''
                for key,val in in_data.items():
                    del_str+=f"{key}={val} and "
                del_str=del_str[:-4]
                query=f'delete from  {tablename} where {del_str}'
                cursor.execute(query)
                conn.commit()
            elif dml=='update':
                db_push(data=data, dml='delete',tablename=tablename )
                db_push(data=data, dml='insert',tablename=tablename )
            else:
                print("unsupported operation")
        except Exception as e:
            print(e)

def consume(data):
    payload= data.get('payload')
    table = payload.get('source').get('table')
    print(table)

    if not payload.get('before'):
        if payload.get('after'):
            print("Insert Statement")
            cur_obj=db_push(data=payload.get('after'),dml='insert',table=table)
    if not payload.get('after'):
        if payload.get('before'):
            print('delete statement')
            cur_obj=db_push(data=payload.get('before'),dml='delete',table=table)
    if payload.get('before') and payload.get('after'):
        cur_obj=db_push(data=payload.get('after'),dml='update',table=table)
        print('Update statement')



def kafka_consumer1(topicName, count=0):
    consumer = Consumer({   
        'bootstrap.servers': 'localhost:9092',
        'group.id': 'a-group6',
        'auto.offset.reset': 'earliest',
    })	
    consumer.subscribe([topicName])

    while True:
        try:
            msg=consumer.poll(1.0)
            if msg is None:
                print("waiting for messages/event in poll()")
                continue
            elif msg.error():
                print('error: {}'.format(msg.error()))
            else:
                #print(msg.key(),msg.value())
                data= json.loads(msg.value())
                try:
                    consume(data)
                except Exception as e:
                    print(e)
                count+=1
                print(f"consumed {count} messages")              

        except Exception as e:
            print(e)

    

if __name__=="__main__":
    topic= sys.argv[1]
    #print(getConfig('mysql'))
    kafka_consumer1(topic)

