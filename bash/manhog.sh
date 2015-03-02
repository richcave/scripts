#!/bin/sh

MAN_DIR=/usr/share/man
ABS_FILE=`find ${MAN_DIR} -type f -ls | sort -k 7 -r -n | head -n 1 | awk -F' ' '{print $11}'`
#echo ${ABS_FILE}
FILE=`/usr/bin/basename ${ABS_FILE}`
echo "Largest man page: ${FILE}"
