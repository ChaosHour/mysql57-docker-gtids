#!/usr/bin/env zsh
#set -xv


# Source the sql files
docker exec -it mysql57-docker-gtids-primary-1 mysql -u root -e "\. /docker-entrypoint-initdb.d/primary.sql"

sleep 2

docker exec -it mysql57-docker-gtids-replica-1 mysql -u root -e "\. /docker-entrypoint-initdb.d/replica.sql"

sleep 2

mysql --defaults-group-suffix=_replica1 -e "show slave status\G" | egrep "Slave_IO_Running:|Slave_SQL_Running:|Seconds_Behind_Master:|Master_Host:"