echo Disabling existing site...
sudo a2dissite fILL.conf
echo Unlinking fILL configuration...
sudo unlink /etc/apache2/sites-available/fILL.conf
echo Removing existing /opt/fILL...
sudo rm -rf /opt/fILL
echo Creating new /opt/fILL...
sudo mkdir /opt/fILL
echo Changing ownership...
sudo chown david:david /opt/fILL
echo Copying from local git repository...
cp -R * /opt/fILL
echo Allowing write to message logs...
sudo chmod ugo+w /opt/fILL/logs/graphing.log
sudo chmod ugo+w /opt/fILL/logs/messages.log
sudo chmod ugo+w /opt/fILL/logs/messages_public.log
sudo chmod ugo+w /opt/fILL/logs/z3950.log
echo Allowing web server to write to htdocs/tmp
sudo chgrp www-data /opt/fILL/htdocs/tmp
sudo chmod g+w /opt/fILL/htdocs/tmp
echo Creating symlink to apache sites-available
sudo ln -s /opt/fILL/conf/fILL.conf /etc/apache2/sites-available/fILL.conf
echo Stopping pazpar2 daemon
sudo kill `cat /var/run/pazpar2.pid`
echo Removing old pazpar2 settings
sudo rm /etc/pazpar2/settings/*
echo Copying pazpar2 settings
sudo cp /opt/fILL/pazpar2/settings/* /etc/pazpar2/settings
echo Updating pazpar2 services
sudo unlink /etc/pazpar2/services-enabled/fILL.xml
sudo cp /opt/fILL/pazpar2/fILL.xml /etc/pazpar2/services-available/fILL.xml
sudo ln -s /etc/pazpar2/services-available/fILL.xml /etc/pazpar2/services-enabled/fILL.xml
echo Updating pazpar2 xslt
#sudo cp /opt/fILL/pazpar2/fILL.xsl /etc/pazpar2/fILL.xsl
sudo cp /opt/fILL/pazpar2/marc21.xsl /etc/pazpar2/marc21.xsl
echo Clearing pazpar2 log
sudo rm /var/log/pazpar2.log
sudo touch /var/log/pazpar2.log
sudo ln -s /var/log/pazpar2.log /opt/fILL/logs/pazpar2.log
echo Restarting pazpar2 daemon
sudo /usr/sbin/pazpar2 -D -u nobody -p /var/run/pazpar2.pid -l /var/log/pazpar2.log -f /etc/pazpar2/server.xml
echo Enabling site...
sudo a2ensite fILL.conf
echo Reloading apache...
sudo /etc/init.d/apache2 reload