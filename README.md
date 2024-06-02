## A modded version of Percona Server 5.7 that includes sysbench for testing.




## Usage

```
make up

When you are ready to use and test with sysbench run:
make start_sysbench

When done
make down_all
```

## Errors on startup
If you get an error like this:
```bash
[+] Running 7/7
 ✔ Network mysql57-docker_db-network     Created                                                                                                                                0.0s
 ✔ Volume "mysql57-docker_primary-data"  Created                                                                                                                                0.0s
 ✔ Volume "mysql57-docker_primary-logs"  Created                                                                                                                                0.0s
 ✔ Volume "mysql57-docker_replica-data"  Created                                                                                                                                0.0s
 ✔ Volume "mysql57-docker_replica-logs"  Created                                                                                                                                0.0s
 ✘ Container mysql57-docker-primary-1    Error                                                                                                                                  0.0s
 ✔ Container mysql57-docker-replica-1    Created                                                                                                                                0.0s
dependency failed to start: container mysql57-docker-primary-1 is unhealthy
make: *** [up] Error 1
```

Just run make up again and it should work.

```bash
make up
docker-compose up -d --build --wait
[+] Building 1.0s (18/18) FINISHED    
[+] Running 2/2
 ✔ Container mysql57-docker-primary-1  Healthy                                                                                                                                  0.0s
 ✔ Container mysql57-docker-replica-1  Healthy                                                                                                                                  0.3s
sleep 10
make start_repl
zsh -c ./start_repl.sh
+------------+
| SLEEP (10) |
+------------+
|          0 |
+------------+
                  Master_Host: 172.25.0.3
             Slave_IO_Running: Yes
            Slave_SQL_Running: Yes
        Seconds_Behind_Master: 0
```

```bash
test with the mysql client
mysql --defaults-group-suffix=_replica1 -e "show slave status\G" | egrep "Slave_IO_Running:|Slave_SQL_Running:|Seconds_Behind_Master:|Master_Host:"
                  Master_Host: 172.25.0.3
             Slave_IO_Running: Yes
            Slave_SQL_Running: Yes
        Seconds_Behind_Master: 0
```

## ~/.my.cnf
```bash
cat ~/.my.cnf
[client_primary1]
user=root
password=s3cr3t
host=192.168.50.75
port=3306
[client_replica1]
user=root
password=s3cr3t
host=192.168.50.75
port=3307
```

## Test with sysbench
```bash
make start_sysbench
zsh -c ./start_sysbench.sh
mysql: [Warning] Using a password on the command line interface can be insecure.
sysbench 1.0.17 (using bundled LuaJIT 2.1.0-beta2)

Running the test with following options:
Number of threads: 1
Initializing random number generator from current time


Initializing worker threads...

Threads started!

thread prepare0
Creating table 'sbtest1'...
Inserting 100000 records into 'sbtest1'
Creating secondary indexes on 'sbtest1'...
Creating table 'sbtest2'...
Inserting 100000 records into 'sbtest2'
Creating secondary indexes on 'sbtest2'...
Creating table 'sbtest3'...
Inserting 100000 records into 'sbtest3'
Creating secondary indexes on 'sbtest3'...
Creating table 'sbtest4'...
Inserting 100000 records into 'sbtest4'
Creating secondary indexes on 'sbtest4'...
Creating table 'sbtest5'...
Inserting 100000 records into 'sbtest5'
Creating secondary indexes on 'sbtest5'...

Output truncated

SQL statistics:
    queries performed:
        read:                            0
        write:                           912
        other:                           48
        total:                           960
    transactions:                        1      (0.03 per sec.)
    queries:                             960    (31.44 per sec.)
    ignored errors:                      0      (0.00 per sec.)
    reconnects:                          0      (0.00 per sec.)

General statistics:
    total time:                          30.5313s
    total number of events:              1

Latency (ms):
         min:                                30527.25
         avg:                                30527.25
         max:                                30527.25
         95th percentile:                    30469.90
         sum:                                30527.25

Threads fairness:
    events (avg/stddev):           1.0000/0.00
    execution time (avg/stddev):   30.5272/0.00

sysbench 1.0.17 (using bundled LuaJIT 2.1.0-beta2)

Running the test with following options:
Number of threads: 1
Initializing random number generator from current time


Initializing worker threads...

Threads started!

Open another terminal and run:
mysqladmin --defaults-group-suffix=_primary1 proc -i1
+----+--------+--------------------+--------+-------------+------+-------------------+------------------+---------+-----------+---------------+
| Id | User   | Host               | db     | Command     | Time | State             | Info             | Time_ms | Rows_sent | Rows_examined |
+----+--------+--------------------+--------+-------------+------+-------------------+------------------+---------+-----------+---------------+
| 6  | repl   | 172.25.0.2:58584   |        | Binlog Dump | 376  | Sending to client |                  | 375718  | 0         | 0             |
| 12 | sbtest | 192.168.65.1:57691 | sbtest | Sleep       | 0    |                   |                  | 0       | 100       | 200           |
| 14 | root   | 192.168.65.1:57694 |        | Query       | 0    | starting          | show processlist | 2       | 0         | 0             |
+----+--------+--------------------+--------+-------------+------+-------------------+------------------+---------+-----------+---------------+
```


## When done
```bash
make down_all
docker-compose down -v --rmi all --remove-orphans
[+] Running 9/9
 ✔ Container mysql57-docker-replica-1   Removed                                                                                                                                 2.0s
 ✔ Container mysql57-docker-primary-1   Removed                                                                                                                                 4.2s
 ✔ Image mysql57-docker-replica:latest  Removed                                                                                                                                 0.0s
 ✔ Volume mysql57-docker_replica-logs   Removed                                                                                                                                 0.2s
 ✔ Volume mysql57-docker_primary-data   Removed                                                                                                                                 0.1s
 ✔ Volume mysql57-docker_replica-data   Removed                                                                                                                                 0.2s
 ✔ Image mysql57-docker-primary:latest  Removed                                                                                                                                 0.0s
 ✔ Volume mysql57-docker_primary-logs   Removed                                                                                                                                 0.1s
 ✔ Network mysql57-docker_db-network    Removed                  
 ```