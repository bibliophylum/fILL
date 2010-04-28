#!/bin/bash
# backup.sh
# This is cron'd to run every half-hour.

curtime=$(date);
echo Backup on $curtime

cd /maplin3/devdocs
mv data.sql.gz data.sql.prev.gz
mysqldump -u mapapp -pmaplin3db maplin >data.sql
gzip data.sql

hour=$(date '+%H');
if [ $hour = "23" ]; then
    prefix=backup
    suffix=$(date '+%Y%m%d')
    filename=$prefix.$suffix
    echo Daily /maplin3/devdocs/$filename
    cp data.sql.gz $filename
fi
