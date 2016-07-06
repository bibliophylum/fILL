# This will be called from root's cron, as:
# sudo crontab -e
# # pazpar restart once/day (midnight)
# 0 0 * * * /opt/fILL/externals/write-pazpar-files-and-restart.sh >/dev/null 2>&1
#
# This replaces pazpar-restart.sh in the crontab.

# Set directory
cd /opt/fILL/pazpar2/settings

# Remove all pazpar xml files
/usr/bin/find ../settings -name "*.xml" -print0 |/usr/bin/xargs -0 -I file /usr/bin/unlink file
/usr/bin/find ../settings-available -name "*.xml" -print0 |/usr/bin/xargs -0 -I file /usr/bin/unlink file

# Write the pazpar files from the db data:
/opt/fILL/bin/admin-pazpar2-write-xml.cgi libsym=ALL

# Make them available
# This is done in admin-pazpar2-write-xml.cgi
#/usr/bin/find ../settings-available -name "*.xml" -print0 |/usr/bin/xargs -0 -I file /bin/ln -s file

# Restart pazpar
/opt/fILL/externals/pazpar-restart.sh
