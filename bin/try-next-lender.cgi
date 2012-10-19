#!/usr/bin/perl

use CGI;
use DBI;
use JSON;

my $query = new CGI;
my $msg_from = $query->param('lid');
my $reqid = $query->param('reqid');

my $dbh = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
		       "mapapp",
		       "maplin3db",
		       {AutoCommit => 1, 
			RaiseError => 1, 
			PrintError => 0,
		       }
    ) or die $DBI::errstr;

#my $SQL = "select lid from sources where request_id=? and sequence_number=(select current_source_sequence_number from request where id=?)+1";
#my @ary = $dbh->selectrow_array( $SQL, undef, $reqid, $reqid );

my @group = $dbh->selectrow_array("select group_id from request where id=?", undef, $reqid);

$SQL = "select lid, sequence_number from sources where group_id=? and tried=false order by sequence_number";
my @ary = $dbh->selectrow_array( $SQL, undef, $group[0] );

my $retval = 0;
if (@ary) {
    # mark this source as tried
    $dbh->do("update sources set request_id=?, tried=true where group_id=? and sequence_number=?", undef, $reqid, $group[0], $ary[1]);

    # message to requesting library
    $SQL = "insert into requests_active (request_id, msg_from, msg_to, status, message) values (?,?,?,?,?)";
    $dbh->do($SQL, undef, $reqid, $msg_from, $msg_from, "Message", "Trying next source");

    # begin the ILL conversation
    $SQL = "INSERT INTO requests_active (request_id, msg_from, msg_to, status) VALUES (?,?,?,?)";
    $dbh->do($SQL, undef, $reqid, $msg_from, $ary[0], 'ILL-Request');

    $SQL = "UPDATE request SET current_source_sequence_number=? where id=?";
    $dbh->do($SQL, undef, $ary[1], $reqid);

    $retval = 1;

} else {
    # should never get here! (user should not be given the option to request from the next source
    # if there is no next source)
    $SQL = "insert into requests_active (request_id, msg_from, msg_to, status, message) values (?,?,?,?,?)";
    $dbh->do($SQL, undef, $reqid, $msg_from, $msg_from, "Message", "No further sources");
}

$dbh->disconnect;

print "Content-Type:application/json\n\n" . to_json( { success => $retval } );
