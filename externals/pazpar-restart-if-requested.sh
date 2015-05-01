# This will be called from root's cron, as:
# sudo crontab -e
# # check if pazpar restart requested, every 5 minutes
# */5 * * * * /opt/fILL/externals/pazpar-restart-if-requested.sh >/dev/null 2>&1

if [ ! -f /tmp/pazpar-restart-requested ]
  then
    #echo "pazpar2 restart not requested, so exiting"
    exit;
fi
/bin/rm /tmp/pazpar-restart-requested
kill `/bin/cat /var/run/pazpar2.pid`
/bin/rm /etc/pazpar2/settings/*
/bin/cp /opt/fILL/pazpar2/settings/* /etc/pazpar2/settings
/usr/bin/unlink /etc/pazpar2/services-enabled/fILL.xml
/bin/cp /opt/fILL/pazpar2/fILL.xml /etc/pazpar2/services-available/fILL.xml
/bin/ln -s /etc/pazpar2/services-available/fILL.xml /etc/pazpar2/services-enabled/fILL.xml
/bin/cp /opt/fILL/pazpar2/marc21.xsl /etc/pazpar2/marc21.xsl
/usr/bin/unlink /opt/fILL/logs/pazpar2.log
/bin/rm /var/log/pazpar2.log
/usr/bin/touch /var/log/pazpar2.log
/bin/ln -s /var/log/pazpar2.log /opt/fILL/logs/pazpar2.log
/usr/sbin/pazpar2 -D -u nobody -p /var/run/pazpar2.pid -l /var/log/pazpar2.log -f /etc/pazpar2/server.xml
echo "`/bin/date` pazpar restarted by admin request" >> /opt/fILL/logs/pzrestart.log
