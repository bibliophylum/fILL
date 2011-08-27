echo Disabling existing site...
sudo a2dissite maplin3.conf
echo Unlinking maplin configuration...
sudo unlink /etc/apache2/sites-available/maplin3.conf
echo Removing existing /opt/maplin3...
sudo rm -rf /opt/maplin3
echo Creating new /opt/maplin3...
sudo mkdir /opt/maplin3
echo Changing ownership...
sudo chown david:david /opt/maplin3
echo Copying from checked-out svn repository...
cp -R * /opt/maplin3
echo Allowing write to message logs...
sudo chmod ugo+w /opt/maplin3/logs/graphing.log
sudo chmod ugo+w /opt/maplin3/logs/messages.log
sudo chmod ugo+w /opt/maplin3/logs/messages_public.log
sudo chmod ugo+w /opt/maplin3/logs/z3950.log
sudo chmod ugo+w /opt/maplin3/logs/zsearch.log
sudo chmod ugo+w /opt/maplin3/logs/zserver_alive.log
echo Allowing web server to write to htdocs/tmp
sudo chgrp www-data /opt/maplin3/htdocs/tmp
sudo chmod g+w /opt/maplin3/htdocs/tmp
echo Creating symlink to apache sites-available
sudo ln -s /opt/maplin3/conf/maplin3.conf /etc/apache2/sites-available/maplin3.conf
echo Stopping pazpar2 daemon
sudo kill `cat /var/run/pazpar2.pid`
echo Removing old pazpar2 settings
sudo rm /etc/pazpar2/settings/*
echo Copying pazpar2 settings
sudo cp /opt/maplin3/pazpar2/settings/* /etc/pazpar2/settings
echo Updating pazpar2 services
sudo unlink /etc/pazpar2/services-enabled/maplin.xml
sudo cp /opt/maplin3/pazpar2/maplin.xml /etc/pazpar2/services-available/maplin.xml
sudo ln -s /etc/pazpar2/services-available/maplin.xml /etc/pazpar2/services-enabled/maplin.xml
echo Clearing pazpar2 log
sudo rm /var/log/pazpar2.log
sudo touch /var/log/pazpar2.log
sudo ln -s /var/log/pazpar2.log /opt/maplin3/logs/pazpar2.log
echo Restarting pazpar2 daemon
sudo /usr/sbin/pazpar2 -D -u nobody -p /var/run/pazpar2.pid -l /var/log/pazpar2.log -f /etc/pazpar2/server.xml
echo Enabling site...
sudo a2ensite maplin3.conf
echo Reloading apache...
sudo /etc/init.d/apache2 reload