#!/usr/bin/perl

use CGI;
use DBI;
use JSON;

my $query = new CGI;
my $reqid = $query->param('reqid');

print STDERR "move-to-history: $reqid\n";

my $rSuccess = 0;
my $rClosed = 0;
my $rFilledBy = 0;
my $rHistory = 0;
my $rActive = 0;
my $rSources = 0;
my $rRequest = 0;

my $dbh = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
		       "mapapp",
		       "maplin3db",
		       {AutoCommit => 1, 
			RaiseError => 1, 
			PrintError => 0,
		       }
    ) or die $DBI::errstr;

$dbh->{AutoCommit} = 0;  # enable transactions, if possible
$dbh->{RaiseError} = 1;

eval {
    # attempts doesn't make sense any more with request_groups... need to figure out what to do here.
    # For now, leave as-is.
    my $SQL = "insert into request_closed (id,title,author,requester,group_id,patron_barcode,attempts) (select id,title,author,requester,group_id,patron_barcode,current_source_sequence_number from request where id=?)";
    $rClosed = $dbh->do( $SQL, undef, $reqid );

    $SQL = "update request_closed set filled_by = (select msg_from from requests_active where request_id=? and status='Checked-in')";
    $rFilledBy = $dbh->do( $SQL, undef, $reqid );

    $SQL = "insert into requests_history (request_id, ts, msg_from, msg_to, status, message) (select request_id, ts, msg_from, msg_to, status, message from requests_active where request_id=?);";
    $rHistory = ($dbh->do( $SQL, undef, $reqid ) ? 1 : 0);

    $SQL = "delete from requests_active where request_id=?";
    $rActive = ($dbh->do( $SQL, undef, $reqid ) ? 1 : 0);

    my @group = $dbh->selectrow_array("select group_id from request where id=?", undef, $reqid);

    # sources.request_id is an fkey.  Can't delete the request until that's reset.
    $SQL = "update sources set request_id=NULL where request_id=?";
    $rSources = ($dbh->do( $SQL, undef, $reqid ) ? 1 : 0);

    $SQL = "delete from request where id=?";
    $rRequest = $dbh->do( $SQL, undef, $reqid );

    $SQL = "select count(id) from request where group_id=?";
    my @cnt = $dbh->selectrow_arrayref( $SQL, undef, $group[0] );
    if ((@cnt) && ($cnt[0] == 0)) {
	$SQL = "delete from sources where group_id=?";
	$rSources = ($dbh->do( $SQL, undef, $group[0] ) ? 1 : 0);
    }

    $dbh->commit;   # commit the changes if we get this far
};
if ($@) {
    warn "Transaction aborted because $@";
    # now rollback to undo the incomplete changes
    # but do it in an eval{} as it may also fail
    eval { $dbh->rollback };
    # add other application on-error-clean-up code here
} else {
    $rSuccess = 1;
}

$dbh->disconnect;

print "Content-Type:application/json\n\n" . to_json( { success => $rSuccess, closed => $rClosed, filledby => $rFilledBy, history => $rHistory, active => $rActive, sources => $rSources, request => $rRequest } );
