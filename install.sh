# Want to do all of this without wiping the production....

#echo Disabling existing site...
#sudo a2dissite fILL.conf

#echo Unlinking fILL configuration...
#sudo unlink /etc/apache2/sites-available/fILL.conf

echo Stopping chat daemon
sudo /etc/init.d/fILL-chat-server stop
sudo cat /dev/null > /opt/fILL/logs/chat-server.pl.log

echo Removing existing /opt/fILL...
# want to preserve conf, logs, report-output
sudo rm -rf /opt/fILL/bin
sudo rm -rf /opt/fILL/devdocs
sudo rm -rf /opt/fILL/externals
sudo rm -rf /opt/fILL/htdocs
sudo rm -rf /opt/fILL/modules
sudo rm -rf /opt/fILL/pazpar2
sudo rm -rf /opt/fILL/restricted_docs
sudo rm -rf /opt/fILL/selenium
sudo rm -rf /opt/fILL/services
sudo rm -rf /opt/fILL/templates
sudo rm -rf /opt/fILL/testing
sudo rm -rf /opt/fILL/updates

#echo Creating new /opt/fILL...
#sudo mkdir /opt/fILL

#echo Changing ownership...
#sudo chown david:david /opt/fILL

echo Copying from local git repository...
cp -R bin /opt/fILL/bin
cp -R devdocs /opt/fILL/devdocs
cp -R externals /opt/fILL/externals
cp -R htdocs /opt/fILL/htdocs
cp -R modules /opt/fILL/modules
cp -R pazpar2 /opt/fILL/pazpar2
cp -R restricted_docs /opt/fILL/restricted_docs
cp -R selenium /opt/fILL/selenium
cp -R services /opt/fILL/services
cp -R templates /opt/fILL/templates
cp -R testing /opt/fILL/testing
cp -R updates /opt/fILL/updates

sudo chgrp -R devel /opt/fILL/*

#echo Allowing write to message logs...
#sudo chmod ugo+w /opt/fILL/logs/graphing.log
#sudo chmod ugo+w /opt/fILL/logs/messages.log
#sudo chmod ugo+w /opt/fILL/logs/messages_public.log
#sudo chmod ugo+w /opt/fILL/logs/z3950.log
#sudo chmod ugo+w /opt/fILL/logs/fILLreporter.log
#sudo chmod ugo+w /opt/fILL/logs/telnet.log

echo Allowing web server to write to htdocs/tmp
sudo chgrp www-data /opt/fILL/htdocs/tmp
sudo chmod g+w /opt/fILL/htdocs/tmp

#echo Creating symlink to apache sites-available
#sudo ln -s /opt/fILL/conf/fILL.conf /etc/apache2/sites-available/fILL.conf

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
sudo cp /opt/fILL/pazpar2/horizon-opac.xsl /etc/pazpar2/horizon-opac.xsl
sudo cp /opt/fILL/pazpar2/wmrl.xsl /etc/pazpar2/wmrl.xsl
echo Clearing pazpar2 log
sudo unlink /opt/fILL/logs/pazpar2.log
sudo rm /var/log/pazpar2.log
sudo touch /var/log/pazpar2.log
sudo ln -s /var/log/pazpar2.log /opt/fILL/logs/pazpar2.log
echo Restarting pazpar2 daemon
sudo /usr/sbin/pazpar2 -D -u nobody -p /var/run/pazpar2.pid -l /var/log/pazpar2.log -f /etc/pazpar2/server.xml

echo Starting chat daemon
sudo /etc/init.d/fILL-chat-server start

#echo Enabling site...
#sudo a2ensite fILL.conf
#echo Reloading apache...
#sudo /etc/init.d/apache2 reload
