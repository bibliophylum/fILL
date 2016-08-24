#!/usr/bin/perl

use CGI;
use CGI::Session;
use DBI;
use JSON;
use Data::Dumper;

my $query = new CGI;
my $session = CGI::Session->load(undef, $query, {Directory=>"/tmp"});
if (($session->is_expired) || ($session->is_empty)) {
    print "Content-Type:application/json\n\n" . to_json( { success => 0, message => 'invalid session' } );
    exit;
}
my $msg_from = $query->param('oid');
my $oid = $msg_from;
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

my $retval = 0;
my $retmsg = "";

my $SQL = "select
 count(request_id) 
from
 requests_active 
where
 request_id=?
 and (
   (msg_to=? and status like 'ILL-Answer|Hold-Placed%')
   or ((msg_to=? and status like 'ILL-Answer|Locations-provided%') and (request_id not in (select request_id from requests_active ra where ra.request_id=request_id and status like 'ILL-Answer|Unfilled%')))
   or (msg_to=? and status like 'ILL-Answer|Will-Supply%')
   or (msg_from=? and message='Trying next source')
 )";
my $lenderUpdated = $dbh->selectrow_array($SQL,undef,$reqid,$oid,$oid,$oid,$oid);
#print STDERR Dumper($lenderUpdated);

if ((defined $lenderUpdated) && ($lenderUpdated != 0)) {
    # the lender updated the record before we got to it
    $retmsg = "Lender has responded - please reload this page.";
    #print STDERR $retmsg;

} else {

    $dbh->begin_work;  # wrap this in a transaction

    eval {
	my @gcr = $dbh->selectrow_array("select g.group_id, c.chain_id, r.id from request r left join request_chain c on c.chain_id=r.chain_id left join request_group g on c.group_id=g.group_id where r.id=?", undef, $reqid);

	$SQL = "select oid, sequence_number from sources where group_id=? and (tried is null or tried=false) order by sequence_number";
	my @ary = $dbh->selectrow_array( $SQL, undef, $gcr[0] );
	
	my @curr = $dbh->selectrow_array("select msg_to from requests_active where request_id=? and status='ILL-Request' order by ts desc", undef, $reqid);
	
	if (@ary) {
	    # message to self (requesting library)
	    $SQL = "insert into requests_active (request_id, msg_from, msg_to, status, message) values (?,?,?,?,?)";
	    $dbh->do($SQL, undef, $reqid, $msg_from, $msg_from, "Message", "Trying next source");
	    
	    # message to lender (so this request doesn't show up on lender's respond list)
	    $SQL = "insert into requests_active (request_id, msg_from, msg_to, status, message) values (?,?,?,?,?)";
	    $dbh->do($SQL, undef, $reqid, $msg_from, $curr[0], "Message", "Trying next source");
	    
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
	    $retmsg = "There are no further sources.";
	}
	
	$dbh->commit;
	
    } or do {
	#  $@ is untrustworthy.  
	#  See https://stackoverflow.com/questions/3686426/perl-dbi-rollback-not-working
	my $retmsg = DBI->errstr;
	$dbh->rollback();
    };
}
$dbh->disconnect;

print "Content-Type:application/json\n\n" . to_json( { success => $retval, 
						       alert_text => $retmsg 
						     } );
