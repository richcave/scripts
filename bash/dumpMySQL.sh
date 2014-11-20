#!/bin/sh
#
# Written by Richard Cave
# https://github.com/richcave
#
#
# dumpMySQL.sh
# Back up a database to either the daily, weekly or monthly backup folders
#
# Example use: dumpMySQL.sh -u myUser -p myPassword -d myDatabase -t daily
#

# Setup globals
MYSQL_BIN=/usr/bin
# Set BACKUP_DIR to your backup directory
BACKUP_DIR=/media/backup/mysql
TODAY=`date +%Y%m%d`
HOST=localhost
FULL=yes

# TYPE should be daily, weekly, or monthly
TYPE=daily

# get args
while getopts "t:d:h:u:p:f" Option
do
  case $Option in
    d ) DATABASE="$OPTARG";;
    h ) HOST="$OPTARG";;
    f ) FULL=yes;;
    u ) USER="$OPTARG";;
    p ) PSWD="$OPTARG";;
    t ) TYPE="$OPTARG";;
    [?] ) echo >&2 "Usage: $0 [-d database] [-f] [-u user] [-t type] ..."
         exit 1;;
  esac
done

shift $(($OPTIND - 1))

# make sure directories exists
DUMP_DIR=$BACKUP_DIR/$TYPE
if [ ! -d $DUMP_DIR ]; then
  echo "${DUMP_DIR}:  No such directory!"
  exit 1
fi

# call mysqldump
echo "Creating MySQL dump file ${DUMP_DIR}/${DATABASE}.${TODAY}"
if [ $FULL = "no" ]; then
  ${MYSQL_BIN}/mysqldump -u ${USER} --password=${PSWD} -h ${HOST} ${DATABASE} -n
 -t > ${DUMP_DIR}/${DATABASE}.${TODAY}
else
  ${MYSQL_BIN}/mysqldump -u ${USER} --password=${PSWD} -h ${HOST} ${DATABASE} -a
 -n -c > ${DUMP_DIR}/${DATABASE}.${TODAY}
fi

# zip dump file
if [ -f ${DUMP_DIR}/${DATABASE}.${TODAY} ]; then
    /usr/bin/gzip ${DUMP_DIR}/${DATABASE}.${TODAY}
else
  echo "${DUMP_DIR}/${DATABASE}.${TODAY}:  No such file!"
  exit 1
fi

# if daily dump, then remove files older than 2 days
if [ $TYPE = "daily" ]; then
    cd $DUMP_DIR
    find . -name "${DATABASE}*" -mtime +2 -exec rm {} \;
fi

# if weekly dump, then remove files older than 180 days
if [ $TYPE = "weekly" ]; then
    cd $DUMP_DIR
    find . -name "${DATABASE}*" -mtime +180 -exec rm {} \;
fi

# if monthly dump, then remove files older than 365 days
if [ $TYPE = "monthly" ]; then
    cd $DUMP_DIR
    find . -name "${DATABASE}*" -mtime +365 -exec rm {} \;
fi
