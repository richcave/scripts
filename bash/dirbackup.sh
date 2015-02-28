#!/bin/bash

TODAY=`date +%Y-%m-%d`
USER=`whoami`

# get args
while getopts "d:" Option
do
  case $Option in
    d ) BACKUP_DIR="$OPTARG";;
    [?] ) echo >&2 "Usage: $0 [-d database] [-f] [-u user] [-t type] ..."
         exit 1;;
  esac
done

shift $(($OPTIND - 1))

if [ ! -d $BACKUP_DIR ]; then
  echo "${BACKUP_DIR}:  No such directory!"
  exit 1
else
  # zip
  /bin/tar -zcvf /home/${USER}${BACKUP_DIR}-${TODAY}.tar.gz ${BACKUP_DIR}/
fi