# Clickhouse cluster on Docker

Cluster configuration: 2 shards with 2 replicas each (read include_from.xml)
Each node writes to `ch*_volume`

Launch cluster

    docker-compose up

Connect to `ch1` node

    clickhouse-client --host=127.0.0.1 --port=9011
    
Create test DB `test_db` on each node

    create database test_db
    
Create Replicated table on one node (automatically creates tables on each shard and replica)

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
    
Create Distributed table for distributed writes and reads
  
    CREATE TABLE IF NOT EXISTS test_db.events_dist
    ON CLUSTER test_cluster AS test_db.events_shard
    ENGINE = Distributed(test_cluster, test_db, events_shard, rand());

Write to Distributed table

    INSERT INTO test_db.events_dist (company_id, product_id) VALUES (1, 11), (1, 12), (1, 13);

Read from Distributed table

    SELECT * FROM test_db.events_dist;
