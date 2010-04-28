#!/usr/bin/perl
#
# Cron this to run at midnight every day.  This will allow "server down" notifications
# to be sent.
#

use DBI;

# Connect to database
my $dbh = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
		       "mapapp",
		       "maplin3db",
		       {AutoCommit => 1, 
			RaiseError => 1, 
			PrintError => 0,
		       }
    );

$dbh->do( "UPDATE zservers SET notification_sent=0");

$dbh->disconnect;



