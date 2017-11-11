# Clickhouse cluster on Docker

Конфигурация кластера: 2 шарда с двумя репликами в каждом шарде (см. include_from.xml)
Каждая нода пишет свои данные в директорию `ch*_volume`

Запуск кластера

    docker-compose up

Подключится к ноде `ch1`

    clickhouse-client --host=127.0.0.1 --port=9011
    
Создать тестовую БД `test_db` на каждой ноде

    create database test_db
    
На одной из нод создать реплицируемую таблицу (таблица создается на всех шардах и репликах)

    CREATE TABLE IF NOT EXISTS test_db.events_shard ON CLUSTER test_cluster (
      event_date           Date DEFAULT toDate(now()),
      company_id           UInt32,
      product_id           UInt32
    ) ENGINE=ReplicatedMergeTree(
        '/clickhouse/tables/{shard}/events_shard', '{replica}',
        event_date,
        (company_id),
        8192
    );
    
Создать Distributed таблицу для записи/чтения данных
  
    CREATE TABLE IF NOT EXISTS test_db.events_dist
    ON CLUSTER test_cluster AS test_db.events_shard
    ENGINE = Distributed(test_cluster, test_db, events_shard, rand());

Запись в distributed таблицу

    INSERT INTO test_db.events_dist (company_id, product_id) VALUES (1, 11), (1, 12), (1, 13);

Чтение из distributed таблицы

    SELECT * FROM test_db.events_dist;
