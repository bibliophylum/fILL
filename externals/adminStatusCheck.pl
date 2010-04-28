#!/usr/bin/perl

use ZOOM;
use DBI;

# Nope: sessionid should be passed in as a parameter, so that main prog can clean up afterwards.
#my $sessionid = get_session_id();
my $sessionid = $ARGV[0];

#print "sessionid: $sessionid\n";

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


# Wait... this is wrong.  That sessionid should not exist...
# The main prog needs to clean this up when it's done.
#$dbh->do("DELETE FROM status_check WHERE sessionid=?",
#	     undef,
#	     $sessionid
#	     );

# Set up connections
my @z;       # connections
my @r;       # results
my @servers; # servers list

# Get list of available servers from db
my $SQL = "SELECT id, name, z3950_connection_string, holdings_tag, holdings_location, holdings_callno FROM zservers WHERE available=1";
my $ar_conn = $dbh->selectall_arrayref( $SQL, { Slice => {} } );

for (my $i = 0; $i < @$ar_conn; $i++) {
    $dbh->do("INSERT INTO status_check (sessionid, zid, event, msg) VALUES (?,?,?,?)",
	     undef,
	     $sessionid,
	     $ar_conn->[$i]{id},
	     0,
	     "Connecting..."
	     );

#    print "Connection $i is $ar_conn->[$i]{name}\n";

    $z[$i] = new ZOOM::Connection($ar_conn->[$i]{z3950_connection_string}, 0,
				  async => 1, # asynchronous mode
				  count => 1, # piggyback retrieval count
				  preferredRecordSyntax => "usmarc");
    if ($z[$i]->errcode() != 0) {
	# something went wrong
	$dbh->do("UPDATE status_check SET event=?, msg=? WHERE ((sessionid=?) AND (zid=?))",
		 undef,
		 $z[$i]->errcode(),
		 $z[$i]->errmsg(),
		 $sessionid,
		 $ar_conn->[$i]{id},
	    );

    } else {
	# Let's try a search
	#$r[$i] = $z[$i]->search_pqf("\@attr 1=4 ducks");
	$r[$i] = $z[$i]->search_pqf("\@attr 1=1016 \"franklin roosevelt\"");
    }
}

while (($i = ZOOM::event(\@z)) != 0) {
    $ev = $z[$i-1]->last_event();
#    print("connection ", $i-1, ": ", ZOOM::event_str($ev), "\n");
#    print "\t[" . $ar_conn->[$i-1]{name} . "]\n";
    $dbh->do("UPDATE status_check SET event=?, msg=? WHERE ((sessionid=?) AND (zid=?))",
	     undef,
	     $ev,
	     ZOOM::event_str($ev),
	     $sessionid,
	     $ar_conn->[$i-1]{id},
	     );

    if ($ev == ZOOM::Event::ZEND) {
	$size = $r[$i-1]->size();
#	print "connection ", $i-1, ": $size hits\n";
##	print $r[$i-1]->record(0)->render() if $size > 0;
	$dbh->do("UPDATE status_check SET event=?, msg=? WHERE ((sessionid=?) AND (zid=?))",
		 undef,
		 $ev,
		 "$size hits.",
		 $sessionid,
		 $ar_conn->[$i-1]{id},
	    );

    }
}

#sub get_session_id {
#    require Digest::MD5;
#
#    Digest::MD5::md5_hex(Digest::MD5::md5_hex(time().{}.rand().$$));
#}
