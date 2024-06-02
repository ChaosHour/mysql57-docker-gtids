#!/usr/bin/env zsh
#set -xv

# Drop existing tables
#for i in {1..1000}
#do
#  echo "Dropping table sbtest.${i}"
#    docker exec -it mysql57-docker-primary-1 mysql -u root -ps3cr3t -e "DROP TABLE IF EXISTS sbtest.${i}" | grep -v W
#done

# Create and call a stored procedure to drop existing tables
docker exec -it mysql57-docker-primary-1 mysql -u root -ps3cr3t -e "
USE sbtest;
DROP PROCEDURE IF EXISTS drop_tables;
DELIMITER $$
CREATE PROCEDURE drop_tables()
BEGIN
  DECLARE i INT DEFAULT 1;
  WHILE i <= 1000 DO
    SET @table_name = CONCAT('sbtest', i);
    SET @sql = CONCAT('DROP TABLE IF EXISTS ', @table_name);
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    SET i = i + 1;
  END WHILE;
END $$
DELIMITER ;
CALL drop_tables();
"
sleep 5

# Run sysbench prepare
docker run \
--rm=true \
--name=sb-prepare \
severalnines/sysbench \
sysbench \
--db-driver=mysql \
--oltp-table-size=100000 \
--oltp-tables-count=24 \
--threads=1 \
--mysql-host=192.168.50.75 \
--mysql-port=3306 \
--mysql-user=sbtest \
--mysql-password=sbt3st \
/usr/share/sysbench/tests/include/oltp_legacy/parallel_prepare.lua \
run


sleep 5

# Run sysbench
docker run \
--rm=true \
--name=sb-run \
severalnines/sysbench \
sysbench \
--db-driver=mysql \
--oltp-table-size=100000 \
--oltp-tables-count=24 \
--threads=1 \
--time=300 \
--mysql-host=192.168.50.75 \
--mysql-port=3306 \
--mysql-user=sbtest \
--mysql-password=sbt3st \
/usr/share/sysbench/tests/include/oltp_legacy/oltp.lua \
run
