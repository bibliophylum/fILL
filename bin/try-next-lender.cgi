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

$dbh->do("SET TIMEZONE='America/Winnipeg'");

#my $SQL = "select lid from sources where request_id=? and sequence_number=(select current_source_sequence_number from request where id=?)+1";
#my @ary = $dbh->selectrow_array( $SQL, undef, $reqid, $reqid );

my @gcr = $dbh->selectrow_array("select g.group_id, c.chain_id, r.id from request r left join request_chain c on c.chain_id=r.chain_id left join request_group g on c.group_id=g.group_id where r.id=?", undef, $reqid);

$SQL = "select lid, sequence_number from sources where group_id=? and tried is null order by sequence_number";
my @ary = $dbh->selectrow_array( $SQL, undef, $gcr[0] );

my $retval = 0;
if (@ary) {
    # message to requesting library
    $SQL = "insert into requests_active (request_id, msg_from, msg_to, status, message) values (?,?,?,?,?)";
    $dbh->do($SQL, undef, $reqid, $msg_from, $msg_from, "Message", "Trying next source");

    # begin the ILL conversation
    $SQL = "INSERT INTO request (requester, current_source_sequence_number, chain_id) values (?,?,?)";
    $dbh->do($SQL, undef, $msg_from, $ary[1], $gcr[1]);
    my $newRequestId = $dbh->last_insert_id(undef,undef,undef,undef,{sequence=>'request_seq'});

    $SQL = "INSERT INTO requests_active (request_id, msg_from, msg_to, status) VALUES (?,?,?,?)";
    $dbh->do($SQL, undef, $newRequestId, $msg_from, $ary[0], 'ILL-Request');

    # mark this source as tried
    $dbh->do("update sources set request_id=?, tried=true where group_id=? and sequence_number=?", undef, $newRequestId, $gcr[0], $ary[1]);

    $retval = 1;

} else {
    # should never get here! (user should not be given the option to request from the next source
    # if there is no next source)
    $SQL = "insert into requests_active (request_id, msg_from, msg_to, status, message) values (?,?,?,?,?)";
    $dbh->do($SQL, undef, $reqid, $msg_from, $msg_from, "Message", "No further sources");
}

$dbh->disconnect;

print "Content-Type:application/json\n\n" . to_json( { success => $retval } );
