#!/bin/bash
# backup.sh
# This is cron'd to run every half-hour.

cd /maplin3/htdocs/tmp
find /maplin3/htdocs/tmp -type f -mmin +30 -name "graph*.png" -exec rm {} \;
