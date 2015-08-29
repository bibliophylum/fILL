cd settings
find ../settings-available -name "*.xml" -print0 |xargs -0 -I file ln -s file
cd ..
