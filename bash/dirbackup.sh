#!/bin/sh

BACKUP_DIR=""
TODAY=`date +%Y-%m-%d`
USER=`whoami`


# get args
while getopts ":d:" opt; do
  case $opt in
    d ) 
         BACKUP_DIR="$OPTARG"
         ;;
    \? ) 
         echo >&2 "Usage: $0 [-d directory]"
         exit 1
         ;;
    :) 
         echo "Option -$OPTARG requires an argument." >&2
         exit 1
         ;;
  esac
done

if [ $BACKUP_DIR == "" ]; then
  echo "No directory specified!"
  exit 1
fi

if [ ! -d $BACKUP_DIR ]; then
  echo "${BACKUP_DIR}:  No such directory!"
  exit 1
else
  # get basename
  BASENAME=`/usr/bin/basename ${BACKUP_DIR}`
  # gzip directory
  /usr/bin/tar -zcvf ${BASENAME}-${TODAY}.tar.gz -C ${BACKUP_DIR} ${BACKUP_DIR}
fi
