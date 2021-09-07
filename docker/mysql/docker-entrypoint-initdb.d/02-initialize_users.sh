#!/bin/bash
set -ex

MYSQLCMD="mysql --protocol=socket --host=localhost --user=root"

echo $MYSQLCMD

mysql_tzinfo_to_sql /usr/share/zoneinfo/UTC UTC | ${MYSQLCMD} mysql
mysql_tzinfo_to_sql /usr/share/zoneinfo/Europe/Moscow Europe/Moscow | ${MYSQLCMD} mysql
mysql_tzinfo_to_sql /usr/share/zoneinfo/Asia/Yekaterinburg Asia/Yekaterinburg | ${MYSQLCMD} mysql

${MYSQLCMD} -e "CREATE DATABASE IF NOT EXISTS ${DATABASE_NAME};"
${MYSQLCMD} -e "CREATE DATABASE IF NOT EXISTS ${DATABASE_TEST_NAME};"
${MYSQLCMD} -e "CREATE USER IF NOT EXISTS '${DATABASE_USER}'@'%' IDENTIFIED BY '${DATABASE_PASSWORD}';"
${MYSQLCMD} -e "GRANT SELECT, CREATE, DROP, UPDATE, DELETE, INDEX, INSERT, ALTER, TRIGGER, LOCK TABLES ON ${DATABASE_NAME}.* TO '${DATABASE_USER}'@'%';"
${MYSQLCMD} -e "GRANT SELECT, CREATE, DROP, UPDATE, DELETE, INDEX, INSERT, ALTER, TRIGGER, LOCK TABLES ON \`${DATABASE_TEST_NAME}%\`.* TO '${DATABASE_USER}'@'%';"
${MYSQLCMD} -e "GRANT PROCESS, REFERENCES ON *.* TO '${DATABASE_USER}'@'%';"
${MYSQLCMD} -e "FLUSH PRIVILEGES;"
