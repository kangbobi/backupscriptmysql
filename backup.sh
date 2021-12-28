#!/bin/bash

################################################################
##
##   MySQL Database Backup Script
##   Written By: Rahul Kumar
##   Modified By: Bobi Saputra
##   URL: https://tecadmin.net/bash-script-mysql-database-backup/
##   Last Update: Jan 05, 2019
##
################################################################

export PATH=/bin:/usr/bin:/usr/local/bin
TODAY=`date +"%d%b%Y"`

################################################################
################## Update below values  ########################

DB_BACKUP_PATH='/home/backup/'
MYSQL_HOST='localhost'
MYSQL_PORT='3306'
MYSQL_USER='root'
MYSQL_PASSWORD='mysecret'
DATABASE_NAME='datacenter'
BACKUP_RETAIN_DAYS=30   ## Number of days to keep local backup copy

#################################################################

mkdir -p ${DB_BACKUP_PATH}/${TODAY}
####echo "Backup started for database - ${DATABASE_NAME}"

Databases=$(echo "SHOW DATABASES" | mysql -uroot -h ${MYSQL_HOST})
for db in $Databases; do
echo "Backup started for database - ${db}"
mysqldump  --skip-extended-insert --force -h ${MYSQL_HOST} \
   -P ${MYSQL_PORT} \
   -u ${MYSQL_USER} \
   -p${MYSQL_PASSWORD} \
   ${db} | gzip > ${DB_BACKUP_PATH}/${TODAY}/${db}-${TODAY}.sql.gz
done
if [ $? -eq 0 ]; then
  echo "Database backup successfully completed"
else
  echo "Error found during backup"
  exit 1
fi


##### Remove backups older than {BACKUP_RETAIN_DAYS} days  #####

DBDELDATE=`date +"%d%b%Y" --date="${BACKUP_RETAIN_DAYS} days ago"`

if [ ! -z ${DB_BACKUP_PATH} ]; then
      cd ${DB_BACKUP_PATH}
      if [ ! -z ${DBDELDATE} ] && [ -d ${DBDELDATE} ]; then
            rm -rf ${DBDELDATE}
      fi
fi
