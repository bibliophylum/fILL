#!/usr/bin/perl
#
# This needs to do error checking....
#
use CGI;
use DBI;
use JSON;
use Switch;

my $query = new CGI;
my $reqid = $query->param('reqid');
my $override = $query->param('override');

my $dbh = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
		       "mapapp",
		       "maplin3db",
		       {AutoCommit => 1, 
			RaiseError => 1, 
			PrintError => 0,
		       }
    ) or die $DBI::errstr;

my $SQL = "select ra.request_id, ra.msg_from as borrower_id, l.name as borrower, ra.msg_to as lender_id, l2.name as lender, ra.status, ra.message from requests_active ra left join libraries l on (l.lid=ra.msg_from) left join libraries l2 on (l2.lid=ra.msg_to) where request_id=? and status='ILL-Request'";
my $href = $dbh->selectrow_hashref($SQL, undef, $reqid);

$SQL = "insert into requests_active (request_id, msg_from, msg_to, status, message) values (?,?,?,?,?)";
my $borrower_id;
my $lender_id;
my $status = "Message";
my $retval;
switch( $override ) {

    case "bReceive" {
	# borrowing override
	$borrower_id = $href->{"borrower_id"};
	$lender_id = $href->{"lender_id"};
	$message = $href->{"borrower"} . " received item without " . $href->{"lender"} . " marking as 'Shipped'";
	# borrower sends a message about overriding
	$retval = $dbh->do( $SQL, undef, $reqid, $borrower_id, $lender_id, $status, $message );	
	# force the ILL to be marked as Shipped by the lender
	$retval = $dbh->do( $SQL, undef, $reqid, $lender_id, $borrower_id, 'Shipped', "override by $href->{borrower}" );	
    }

    case "bCancel" {
	# borrowing override
	$borrower_id = $href->{"borrower_id"};
	$lender_id = $href->{"lender_id"};
	$message = $href->{"borrower"} . " cancelled the request to " . $href->{"lender"};
	# borrower sends a message about overriding
	$retval = $dbh->do( $SQL, undef, $reqid, $borrower_id, $lender_id, $status, $message );
	# force the ILL to be marked as Cancelled by the lender
	$retval = $dbh->do( $SQL, undef, $reqid, $lender_id, $borrower_id, 'Cancelled', "override by $href->{borrower}" );	
	# ...and move to history
	$retval = move_to_history( $dbh, $reqid );
    }

    case "bClose" {
	# borrowing override
	$borrower_id = $href->{"borrower_id"};
	$lender_id = $href->{"lender_id"};
	$message = $href->{"borrower"} . " returned item but " . $href->{"lender"} . " has not checked it in";
	# borrower sends a message about overriding
	$retval = $dbh->do( $SQL, undef, $reqid, $borrower_id, $lender_id, $status, $message );
	# force the ILL to be marked as Checked-in by the lender
	$retval = $dbh->do( $SQL, undef, $reqid, $lender_id, $borrower_id, 'Checked-in', "override by $href->{borrower}" );	
	# ...and move to history
	$retval = move_to_history( $dbh, $reqid );
    }

    case "bReturned" {
	# lending override
	$borrower_id = $href->{"borrower_id"};
	$lender_id = $href->{"lender_id"};
	$message = $href->{"borrower"} . " has returned the item to " . $href->{"lender"} . " but did not mark it as 'Returned'";
	# lender sends a message about overriding
	$retval = $dbh->do( $SQL, undef, $reqid, $lender_id, $borrower_id, $status, $message );
	# force the ILL to be marked as Returned by the borrower
	$retval = $dbh->do( $SQL, undef, $reqid, $borrower_id, $lender_id, 'Returned', "override by $href->{lender}" );	
	# lender check-in and move to history
	$retval = $dbh->do( $SQL, undef, $reqid, $lender_id, $borrower_id, 'Checked-in', "" );
	$retval = move_to_history( $dbh, $reqid );
    }

    else {
	$borrower_id = $href->{"borrower_id"};
	$lender_id = $href->{"lender_id"};
	$message = "unknown override: [$override]";
	$retval = $dbh->do( $SQL, undef, $reqid, $borrower_id, $lender_id, $status, $message );
    }
}

# sql to add to the request conversation

$dbh->disconnect;
print "Content-Type:application/json\n\n" . to_json( { success => $retval } );


sub move_to_history {
    my $dbh = shift;
    my $reqid = shift;

    $dbh->{AutoCommit} = 0;  # enable transactions, if possible
    $dbh->{RaiseError} = 1;
    eval {
	my $SQL = "insert into request_closed (id,title,author,requester,patron_barcode,attempts) (select id,title,author,requester,patron_barcode,current_target from request where id=?)";
	$rClosed = $dbh->do( $SQL, undef, $reqid );
	
	$SQL = "update request_closed set filled_by = (select msg_from from requests_active where request_id=? and status='Checked-in')";
	$rFilledBy = $dbh->do( $SQL, undef, $reqid );
	
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

    return $rSuccess;
}
