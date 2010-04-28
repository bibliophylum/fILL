#!/usr/bin/perl

use DBI;

# Set up database connection
#my $dbh = DBI->connect("DBI:mysql:database=maplin;mysql_server_prepare=1",
#		       "mapapp",
#		       "maplin3db",
#		       {LongReadLen => 65536}
#    );
my $dbh = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
		       "mapapp",
		       "maplin3db",
		       {AutoCommit => 1, 
			RaiseError => 1, 
			PrintError => 0,
		       }
    );


# Get list of available servers from db
my $SQL = "SELECT id, name, z3950_connection_string, holdings_tag, holdings_location, holdings_callno FROM zservers WHERE available=1";
print STDERR $SQL . "\n";
my $ar_conn = $dbh->selectall_arrayref( $SQL, { Slice => {} } );

print @$ar_conn . "\n";

foreach my $srvr (@$ar_conn) {
    print "$srvr->{id} $srvr->{name} $srvr->{Z3950_connection_string}\n";
}

# Disconnect from the database.
$dbh->disconnect();
