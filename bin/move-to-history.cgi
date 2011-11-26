#!/usr/bin/perl

use CGI;
use DBI;
use JSON;

my $query = new CGI;
my $reqid = $query->param('reqid');

print STDERR "move-to-history: $reqid\n";

my $rSuccess = 0;
my $rClosed = 0;
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
    my $SQL = "insert into request_closed (id,title,author,requester,patron_barcode,filled_by) (select id,title,author,requester,patron_barcode,current_target from request where id=?)";
    $rClosed = $dbh->do( $SQL, undef, $reqid );

    $SQL = "insert into requests_history (request_id, ts, msg_from, msg_to, status, message) (select request_id, ts, msg_from, msg_to, status, message from requests_active where request_id=?);";
    $rHistory = ($dbh->do( $SQL, undef, $reqid ) ? 1 : 0);

    $SQL = "delete from requests_active where request_id=?;";
    $rActive = ($dbh->do( $SQL, undef, $reqid ) ? 1 : 0);

    $SQL = "delete from sources where request_id=?;";
    $rSources = ($dbh->do( $SQL, undef, $reqid ) ? 1 : 0);

    $SQL = "delete from request where id=?;";
    $rRequest = $dbh->do( $SQL, undef, $reqid );

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

print "Content-Type:application/json\n\n" . to_json( { success => $rSuccess, closed => $rClosed, history => $rHistory, active => $rActive, sources => $rSources, request => $rRequest } );
