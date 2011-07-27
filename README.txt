$ sudo su -
# su - postgres
$ /usr/lib/postgresql/8.4/bin/initdb -D /var/lib/postgresql/8.4/maplin

$ /usr/lib/postgresql/8.4/bin/pg_ctl -D /var/lib/postgresql/8.4/maplin -l /var/log/postgresql/postgresql-8.4-maplin.log start

$ createdb maplin

$ createuser mapapp
Shall the new role be a superuser? (y/n) y

$ exit   <back to root>
# exit   <back to myself>
$ cd $HOME/prj/maplin/trunk/updates

$ psql -U mapapp -h localhost -d maplin <00.initial.sql
...

