#!/bin/bash

OPTION='-a -v'
BANDWIDTH='5000'
EXCLUDE='--exclude *.lnk --exclude *.db --exclude *.tmp --exclude *.~lock.* --exclude ~$*'
SOURCE='/media/disk1'
DESTINATION='/media/disk2'
MODIFIED='/media/disk3'
LOGFILE='/var/log'
DATE=$(date +%Y-%m-%d)

if [ $(ps -A | grep -c rsync) = "0" ] ; then
mkdir -p "$MODIFIED/$DATE"
echo "START `date +%Y-%m-%d_%H:%M`" >> "$LOGFILE/rsync_$DATE.log"

rsync $OPTION --bwlimit=$BANDWIDTH --ignore-errors --delete --delete-excluded $EXCLUDE --backup --backup-dir="$MODIFIED/$DATE" "$SOURCE" "$DESTINATION" | grep -v '/$' >> "$LOGFILE/rsync_$DATE.log"

echo "END `date +%Y-%m-%d_%H:%M`" >> "$LOGFILE/rsync_$DATE.log"
fi
