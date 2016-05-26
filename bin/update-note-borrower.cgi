#!/usr/bin/perl

use CGI;
use CGI::Session;
use DBI;
use JSON;
use Data::Dumper;

my $query = new CGI;
#my $session = CGI::Session->load(undef, $query, {Directory=>"/tmp"});
#if (($session->is_expired) || ($session->is_empty)) {
#    print "Content-Type:application/json\n\n" . to_json( { success => 0, message => 'invalid session' } );
#    exit;
#}

my $note = scalar $query->param('value');
my $reqid = scalar $query->param('reqid');
$reqid = substr( $reqid, 3 );  # lose the leading "req"
my $private_to = scalar $query->param('private_to');

my $dbh = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
		       "mapapp",
		       "maplin3db",
		       {AutoCommit => 1, 
			RaiseError => 1, 
			PrintError => 0,
		       }
    ) or die $DBI::errstr;

$dbh->do("SET TIMEZONE='America/Winnipeg'");

my $retval;

# get the gid for this request
my $gid = $dbh->selectrow_arrayref("select g.group_id from request_group g left join request_chain c on c.group_id=g.group_id left join request r on r.chain_id=c.chain_id where r.id=?", undef, $reqid);

if ($gid && $gid->[0]) {
    # is there an internal borrower note for this gid/library?
    my $aref = $dbh->selectrow_arrayref("select count(*) from internal_note_borrower where gid=? and private_to=?", undef, $gid->[0], $private_to);
    
    if ($aref && $aref->[0]) {  # existing note
	if ($note) {
	    $retval = $dbh->do( "update internal_note_borrower set note=? where gid=? and private_to=?", undef, $note, $gid->[0], $private_to );
	} else {
	    # passed an empty note, so delete the existing one
	    $retval = $dbh->do( "delete from internal_note_borrower where gid=? and private_to=?", undef, $gid->[0], $private_to );
	}
	
    } else {  # new note
	$retval = $dbh->do( "insert into internal_note_borrower (gid, private_to, note) values (?,?,?)", undef, $gid->[0], $private_to, $note);
    }
}

$dbh->disconnect;

print "Content-Type:application/json\n\n" . to_json( { success => $retval, data => $note, reqid => $reqid } );
