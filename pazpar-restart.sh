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
sudo unlink /opt/fILL/logs/pazpar2.log
sudo rm /var/log/pazpar2.log
sudo touch /var/log/pazpar2.log
sudo ln -s /var/log/pazpar2.log /opt/fILL/logs/pazpar2.log
echo Restarting pazpar2 daemon
sudo /usr/sbin/pazpar2 -D -u nobody -p /var/run/pazpar2.pid -l /var/log/pazpar2.log -f /etc/pazpar2/server.xml

