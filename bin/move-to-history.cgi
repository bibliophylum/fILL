#!/usr/bin/perl

use CGI;
use DBI;
use JSON;

my $query = new CGI;
my $reqid = $query->param('reqid');

#print STDERR "move-to-history: $reqid\n";

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

$dbh->do("SET TIMEZONE='America/Winnipeg'");

$dbh->{AutoCommit} = 0;  # enable transactions, if possible
$dbh->{RaiseError} = 1;

eval {
    my $SQL;
    # get the request_id, chain_id, and group_id from the (live) request
    $SQL = "select g.group_id, c.chain_id, r.id from request_group g left join request_chain c on c.group_id = g.group_id left join request r on r.chain_id=c.chain_id where r.id=?";
    my @gcr = $dbh->selectrow_array( $SQL, undef, $reqid );
    print STDERR "move-to-history: gid [$gcr[0]], cid [$gcr[1]], rid [$gcr[2]]\n";
    
    # see if the group already exists in history
    $SQL = "select count(group_id) from history_group where group_id=?";
    my @hg = $dbh->selectrow_array( $SQL, undef, $gcr[0] );
    if ((@hg) && ($hg[0] == 0)) {
	# not yet in history_group, so add it
	$SQL = "insert into history_group (group_id, copies_requested, title, author, requester, patron_barcode, note) select group_id, copies_requested, title, author, requester, patron_barcode, note from request_group where group_id=?";
	$dbh->do( $SQL, undef, $gcr[0] );
	print STDERR "move-to-history: request_group added to history_group\n";
    } else {
	print STDERR "move-to-history: request_group already exists in history_group\n";
    }

    # see if the chain already exists in history
    # (this should not happen... entire chain moved at once)
    $SQL = "select count(chain_id) from history_chain where chain_id=?";
    my @hc = $dbh->selectrow_array( $SQL, undef, $gcr[1] );
    if ((@hc) && ($hc[0] == 0)) {
	# not yet in history_chain, so add it
	$SQL = "insert into history_chain (group_id, chain_id) values (?,?)";
	$dbh->do( $SQL, undef, $gcr[0], $gcr[1] );
	print STDERR "move-to-history: request_chain added to history_chain\n";
    } else {
	print STDERR "move-to-history: request_chain already exists in history_chain!\n";
    }

    # get all of the requests for this chain
    $SQL = "select id from request where chain_id=?";
    my $chained_requests_aref = $dbh->selectall_arrayref( $SQL, undef, $gcr[1] );
    print STDERR "move-to-history: moving chain to history\n";
    foreach my $req_aref (@$chained_requests_aref) {
	my $chained_req = $req_aref->[0];
	print STDERR "move-to-history: chain [" . $gcr[1] . "], request [$chained_req]\n";

	# attempts doesn't make sense any more with request_groups / request_chains... need to figure out what to do here.
	# For now, leave as-is.
	$SQL = "insert into request_closed (id,requester,chain_id) (select id,requester, chain_id from request where id=?)";
	$rClosed = $dbh->do( $SQL, undef, $chained_req );
	print STDERR "move-to-history: request [$chained_req] inserted into request_closed\n";

	$SQL = "insert into requests_history (request_id, ts, msg_from, msg_to, status, message) (select request_id, ts, msg_from, msg_to, status, message from requests_active where request_id=?);";
	$rHistory = ($dbh->do( $SQL, undef, $chained_req ) ? 1 : 0);
	print STDERR "move-to-history: associated requests_active inserted into requests_history\n";

	$SQL = "delete from requests_active where request_id=?";
	$rActive = ($dbh->do( $SQL, undef, $chained_req ) ? 1 : 0);
	print STDERR "move-to-history: requests_active deleted for reqid $chained_req\n";

	# sources.request_id is an fkey.  Can't delete the request until that's reset.
	$SQL = "update sources set request_id=NULL where request_id=?";
	$rSources = ($dbh->do( $SQL, undef, $chained_req ) ? 1 : 0);
	print STDERR "move-to-history: sources referencing this request have been nulled\n";

	$SQL = "delete from request where id=?";
	$rRequest = $dbh->do( $SQL, undef, $chained_req );
	print STDERR "move-to-history: request deleted\n";
    }

    $SQL = "select count(id) from request where chain_id=?";
    my @cnt = $dbh->selectrow_array( $SQL, undef, $gcr[1] );
    if ((@cnt) && ($cnt[0] == 0)) {
	# no requests left in this chain
	$SQL = "delete from request_chain where chain_id=?";
	$dbh->do( $SQL, undef, $gcr[1] );
	print STDERR "move-to-history: no requests left in this chain, chain deleted\n";
    } else {
	# this should not happen.
	print STDERR "move-to-history: strange... still requests in this chain, chain not deleted\n";
    }
    @cnt = undef;

    $SQL = "select count(group_id) from request_chain where group_id=?";
    @cnt = $dbh->selectrow_array( $SQL, undef, $gcr[0] );
    if ((@cnt) && ($cnt[0] == 0)) {
	# no chains left in this group
	$SQL = "delete from request_group where group_id=?";
	$rChains = $dbh->do( $SQL, undef, $gcr[0] );
	print STDERR "move-to-history: no chains left in this group, group deleted\n";

	# we don't need the sources for history
	$SQL = "delete from sources where group_id=?";
	$rSources = ($dbh->do( $SQL, undef, $group[0] ) ? 1 : 0);
	print STDERR "move-to-history: no further need of sources, sources deleted\n";
    } else {
	print STDERR "move-to-history: still chains in this group, group not deleted\n";
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

print "Content-Type:application/json\n\n" . to_json( { success => $rSuccess, closed => $rClosed, history => $rHistory, active => $rActive, sources => $rSources, request => $rRequest } );
