# A modded version of Percona Server 5.7 used for testing GTIDs




## Usage

```
make up2


When done
make down_all
```

## Errors on startup

If you get an error like this:

```bash
make up2
docker-compose up -d --build --wait
WARN[0000] /Users/klarsen/projects/mysql57-docker-gtids/docker-compose.yml: `version` is obsolete
[+] Building 2.6s (21/21) FINISHED                                                                                                                                                       docker:desktop-linux
mysql57-docker-gtids-replica                                                                                                                                          0.0s
[+] Running 6/7
 ✔ Network mysql57-docker-gtids_db-network     Created                                                                                                                                                   0.2s
 ✔ Volume "mysql57-docker-gtids_primary-data"  Created                                                                                                                                                   0.0s
 ✔ Volume "mysql57-docker-gtids_primary-logs"  Created                                                                                                                                                   0.0s
 ✔ Volume "mysql57-docker-gtids_replica-data"  Created                                                                                                                                                   0.0s
 ✔ Volume "mysql57-docker-gtids_replica-logs"  Created                                                                                                                                                   0.0s
 ✔ Container mysql57-docker-gtids-primary-1    Healthy                                                                                                                                                 100.8s
 ⠦ Container mysql57-docker-gtids-replica-1    Waiting                                                                                                                                                 110.2s
container mysql57-docker-gtids-replica-1 is unhealthy
make: *** [up2] Error 1
```

Just run make up2 again and it should work.

```bash
make up2
docker-compose up -d --build --wait
WARN[0000] /Users/klarsen/projects/mysql57-docker-gtids/docker-compose.yml: `version` is obsolete
[+] Building 2.2s (21/21) FINISHED                                                                                                                                                       docker:desktop-linux
                                                                                      0.0s
[+] Running 2/2
 ✔ Container mysql57-docker-gtids-primary-1  Healthy                                                                                                                                                     1.0s
 ✔ Container mysql57-docker-gtids-replica-1  Healthy                                                                                                                                                     1.0s
sleep 10
make start_repl_gtid
zsh -c ./start_repl_gtid.sh

What's next?
  Try Docker Debug for seamless, persistent debugging tools in any container or image → docker debug mysql57-docker-gtids-primary-1
  Learn more at https://docs.docker.com/go/debug-cli/
+----------+
| SLEEP(3) |
+----------+
|        0 |
+----------+

What's next?
  Try Docker Debug for seamless, persistent debugging tools in any container or image → docker debug mysql57-docker-gtids-replica-1
  Learn more at https://docs.docker.com/go/debug-cli/
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

## GTIDs enabled

```bash
mysql --defaults-group-suffix=_primary1 -e "show variables like '%gtid%'"
+----------------------------------+-----------+
| Variable_name                    | Value     |
+----------------------------------+-----------+
| binlog_gtid_simple_recovery      | ON        |
| enforce_gtid_consistency         | ON        |
| gtid_executed_compression_period | 1000      |
| gtid_mode                        | ON        |
| gtid_next                        | AUTOMATIC |
| gtid_owned                       |           |
| gtid_purged                      |           |
| session_track_gtids              | OFF       |
+----------------------------------+-----------+
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

## When done
```bash
make down_all
docker-compose down -v --rmi all --remove-orphans
WARN[0000] /Users/klarsen/projects/mysql57-docker-gtids/docker-compose.yml: `version` is obsolete
[+] Running 9/9
 ✔ Container mysql57-docker-gtids-replica-1   Removed                                                                                                                                                    2.5s
 ✔ Container mysql57-docker-gtids-primary-1   Removed                                                                                                                                                   10.4s
 ✔ Volume mysql57-docker-gtids_primary-logs   Removed                                                                                                                                                    0.1s
 ✔ Image mysql57-docker-gtids-replica:latest  Removed                                                                                                                                                    0.0s
 ✔ Volume mysql57-docker-gtids_replica-logs   Removed                                                                                                                                                    0.0s
 ✔ Volume mysql57-docker-gtids_replica-data   Removed                                                                                                                                                    0.1s
 ✔ Volume mysql57-docker-gtids_primary-data   Removed                                                                                                                                                    0.1s
 ✔ Image mysql57-docker-gtids-primary:latest  Removed                                                                                                                                                    0.0s
 ✔ Network mysql57-docker-gtids_db-network    Removed                                                                                                                                                    0.1s
 ```