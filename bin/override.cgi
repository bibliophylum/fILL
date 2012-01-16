#!/usr/bin/perl

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
# Gah.  can't use backticks in cgi...
	$retval = `./change-request-status.cgi reqid=$reqid lid=$lender_id msg_to=$borrower_id status=Shipped message="override by $href->{borrower}"`;
    }
    case "bClose" {
	# borrowing override
	$borrower_id = $href->{"borrower_id"};
	$lender_id = $href->{"lender_id"};
	$message = $href->{"borrower"} . " returned item but " . $href->{"lender"} . " has not checked it in";
	# borrower sends a message about overriding
	$retval = $dbh->do( $SQL, undef, $reqid, $borrower_id, $lender_id, $status, $message );
	# force the ILL to be marked as Checked-in by the lender
	$retval = `./change-request-status.cgi reqid=$reqid lid=$lender_id msg_to=$borrower_id status=Checked-in message="override by $href->{borrower}"`;
	# ...and move to history
	$retval = `./move-to-history.cgi reqid=$reqid`;
    }

    case "bReturned" {
	# lending override
	$borrower_id = $href->{"borrower_id"};
	$lender_id = $href->{"lender_id"};
	$message = $href->{"borrower"} . " has returned the item to " . $href->{"lender"} . " but did not mark it as 'Returned'";
	# lender sends a message about overriding
	$retval = $dbh->do( $SQL, undef, $reqid, $lender_id, $borrower_id, $status, $message );
	# force the ILL to be marked as Returned by the borrower
	$retval = `./change-request-status.cgi reqid=$reqid lid=$borrower_id msg_to=$lender_id status=Returned message="override by $href->{lender}"`;
	# lender check-in and move to history
	$retval = `./change-request-status.cgi reqid=$reqid lid=$lender_id msg_to=$borrower_id status=Checked-in message=""`;
	$retval = `./move-to-history.cgi reqid=$reqid`;
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

print $retval;  # Content-type header + JSON
