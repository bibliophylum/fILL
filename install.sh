# Want to do all of this without wiping the production....

#echo Disabling existing site...
#sudo a2dissite fILL.conf

echo Stopping reporter...
sudo kill `cat /tmp/fILLreporter.pid`

#echo Unlinking fILL configuration...
#sudo unlink /etc/apache2/sites-available/fILL.conf

echo Removing existing /opt/fILL...
# want to preserve conf, logs, report-output
sudo rm -rf /opt/fILL/bin
sudo rm -rf /opt/fILL/devdocs
sudo rm -rf /opt/fILL/externals
sudo rm -rf /opt/fILL/htdocs
sudo rm -rf /opt/fILL/localisation
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

echo Building Perl modules...
topdir=$(pwd)
echo ---[ Biblio-SIP2-Client ]------------
cd modules/Biblio-SIP2-Client
perl Makefile.PL
make
make test
sudo make install
cd $topdir

echo ---[ Biblio-Authentication ]------------
cd modules/Biblio-Authentication
perl Makefile.PL
make
make test
sudo make install
cd $topdir

echo ---[ fILL-stats ]------------
cd modules/fILL-stats
perl Makefile.PL
make
make test
sudo make install
cd $topdir

echo ---[ fILL-charts ]------------
cd modules/fILL-charts
perl Makefile.PL
make
make test
sudo make install
cd $topdir

#echo Changing ownership...
#sudo chown david:david /opt/fILL

echo Copying from local git repository...
cp -R bin /opt/fILL/bin
cp -R devdocs /opt/fILL/devdocs
cp -R externals /opt/fILL/externals
cp -R htdocs /opt/fILL/htdocs
cp -R localisation /opt/fILL/localisation
cp -R modules /opt/fILL/modules
#cp -R pazpar2 /opt/fILL/pazpar2  # instead, run /opt/fILL/externals/write-pazpar-files-and-restart.sh
cp -R restricted_docs /opt/fILL/restricted_docs
cp -R selenium /opt/fILL/selenium
cp -R services /opt/fILL/services
cp -R templates /opt/fILL/templates
cp -R testing /opt/fILL/testing
cp -R updates /opt/fILL/updates

sudo chgrp -R devel /opt/fILL/*

echo Making pazpar2 directories
sudo mkdir /opt/fILL/pazpar2
sudo mkdir /opt/fILL/pazpar2/settings-available
sudo mkdir /opt/fILL/pazpar2/settings
sudo mkdir /opt/fILL/pazpar2/tmp
sudo chown david /opt/fILL/pazpar2
sudo chgrp david /opt/fILL/pazpar2

echo Allowing web server to write to pazpar2/settings
sudo chgrp www-data /opt/fILL/pazpar2/settings
sudo chgrp www-data /opt/fILL/pazpar2/settings-available
sudo chgrp www-data /opt/fILL/pazpar2/tmp

echo Creating pazpar2 files and restarting pazpar2
cp pazpar2/*.xml /opt/fILL/pazpar2/
cp pazpar2/*.xsl /opt/fILL/pazpar2/
(sudo /opt/fILL/externals/write-pazpar-files-and-restart.sh)
echo done

#echo Allowing write to message logs...
#sudo chmod ugo+w /opt/fILL/logs/graphing.log
#sudo chmod ugo+w /opt/fILL/logs/messages.log
#sudo chmod ugo+w /opt/fILL/logs/messages_public.log
#sudo chmod ugo+w /opt/fILL/logs/z3950.log
#sudo chmod ugo+w /opt/fILL/logs/fILLreporter.log
#sudo chmod ugo+w /opt/fILL/logs/telnet.log

echo Allowing web server to write to htdocs/tmp
sudo mkdir /opt/fILL/htdocs/tmp
sudo chown david /opt/fILL/htdocs/tmp
sudo chgrp www-data /opt/fILL/htdocs/tmp
sudo chmod g+w /opt/fILL/htdocs/tmp

#echo Creating symlink to apache sites-available
#sudo ln -s /opt/fILL/conf/fILL.conf /etc/apache2/sites-available/fILL.conf

#echo Restarting reporter daemon
#sudo /opt/fILL/services/fILLreporter.pl

#echo Enabling site...
#sudo a2ensite fILL.conf
#echo Reloading apache...
#sudo /etc/init.d/apache2 reload
