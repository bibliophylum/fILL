#!/usr/bin/perl
#
# Program: clearOldSearches.pl
# Purpose: delete old search results (if, for example, user has closed
#          their browser without logging out).
# Author:  David Christensen
# Date:    2008-06-23
# Mods:

use DBI;

# Set up database connection
#my $dbh = DBI->connect("DBI:mysql:database=maplin;mysql_server_prepare=1",
#		      "mapapp",
#		      "maplin3db", 
#		      {LongReadLen => 65536} 
#	);
my $dbh = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
		       "mapapp",
		       "maplin3db",
		       {AutoCommit => 1, 
			RaiseError => 1, 
			PrintError => 0,
		       }
    );

#     0    1    2     3     4    5     6     7     8
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
$year += 1900;
$mon += 1;
my $today = sprintf("%4d-%02d-%02d",$year,$mon,$mday);

my $rows_deleted = $dbh->do( 
    "DELETE FROM marc WHERE ts < ?", 
    undef,
    $today
    );

print "clearOldSearches: [" . localtime() . "] $rows_deleted rows deleted from marc table\n";

$rows_deleted = $dbh->do( 
    "DELETE FROM status_check WHERE ts < ?", 
    undef,
    $today
    );

print "clearOldSearches: [" . localtime() . "] $rows_deleted rows deleted from status_check table\n";

# Disconnect from the database.
$dbh->disconnect();
