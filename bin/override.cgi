#!/usr/bin/perl
#
# This needs to do error checking....
#
use strict;
use warnings;

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

my $SQL = "select ra.request_id, ra.msg_from as borrower_id, l.name as borrower, ra.msg_to as lender_id, l2.name as lender, ra.status, ra.message from requests_active ra left join libraries l on (l.lid=ra.msg_from) left join libraries l2 on (l2.lid=ra.msg_to) where request_id=? and status='ILL-Request' order by ra.ts";
my $aref = $dbh->selectall_arrayref($SQL, { Slice => {} }, $reqid);
my $href = pop(@$aref);

$SQL = "insert into requests_active (request_id, msg_from, msg_to, status, message) values (?,?,?,?,?)";
my $borrower_id;
my $lender_id;
my $status = "Message";
my $message = "";
my $retval;
my $return_data_href;

switch( $override ) {

    case "bReceive" {
	# borrowing override
	$borrower_id = $href->{"borrower_id"};
	$lender_id = $href->{"lender_id"};
	# can only force 'Shipped' if the lender hasn't already marked it as 'Shipped'
	my $cntAnswers = $dbh->selectrow_array( "select count(*) from requests_active where request_id=? and msg_from=? and status like 'Shipped';", undef, $reqid, $lender_id );
	if ((defined $cntAnswers) && ($cntAnswers == 0)) {
	    $message = $href->{"borrower"} . " received item without " . $href->{"lender"} . " marking as 'Shipped'";
	    # borrower sends a message about overriding
	    $retval = $dbh->do( $SQL, undef, $reqid, $borrower_id, $lender_id, $status, $message );	
	    # force the ILL to be marked as Shipped by the lender
	    $retval = $dbh->do( $SQL, undef, $reqid, $lender_id, $borrower_id, 'Shipped', "override by $href->{borrower}" );
	    $return_data_href->{ success } = $retval;
	    $return_data_href->{ status } = "Shipped";
	    $return_data_href->{ message } = "override";
	} else {
	    $return_data_href->{ success } = 0;
	    $return_data_href->{ status } = "Could not force 'Shipped'";
	    $return_data_href->{ message } = "Lender has already shipped.";
	    $return_data_href->{ alert_text } = "Could not override this request,\nlender has already shipped.\nPlease check your Receiving list.";
	}
    }

    case "bCancel" {
	# borrowing override
	$borrower_id = $href->{"borrower_id"};
	$lender_id = $href->{"lender_id"};
	# can only cancel if the lender hasn't answered yet
	my $cntAnswers = $dbh->selectrow_array( "select count(*) from requests_active where request_id=? and msg_from=? and status like 'ILL-Answer%';", undef, $reqid, $lender_id );
	print STDERR "cntAnswers: $cntAnswers\n";
	if ((defined $cntAnswers) && ($cntAnswers == 0)) {
	    print STDERR "...so cancelling\n";
	    $message = $href->{"borrower"} . " cancelled the request to " . $href->{"lender"};
	    # borrower sends a message about overriding
	    $retval = $dbh->do( $SQL, undef, $reqid, $borrower_id, $lender_id, $status, $message );
	    # force the ILL to be marked as Cancelled by the lender
	    $retval = $dbh->do( $SQL, undef, $reqid, $lender_id, $borrower_id, 'Cancelled', "override by $href->{borrower}" );	
	    # ...and move to history
	    $retval = move_to_history( $dbh, $reqid );
	    $return_data_href->{ success } = $retval;
	    $return_data_href->{ status } = "Cancelled";
	    $return_data_href->{ message } = "override";
	} else {
	    print STDERR "...so NOT cancelling\n";
	    $return_data_href->{ success } = 0;
	    $return_data_href->{ status } = "Could not cancel";
	    $return_data_href->{ message } = "Lender has already answered.";
	    $return_data_href->{ alert_text } = "Could not cancel this request,\nlender has already answered.";
	}
    }

    case "bNoFurtherSources" {
	# borrowing override
	$borrower_id = $href->{"borrower_id"};
	$lender_id = $href->{"lender_id"};
	# can only move to history from here if there is a message saying "No further sources"
	my $cntAnswers = $dbh->selectrow_array( "select count(*) from requests_active where request_id=? and message='No further sources';", undef, $reqid);
	print STDERR "cntAnswers: $cntAnswers\n";
	if ((defined $cntAnswers) && ($cntAnswers == 1)) {
	    print STDERR "...so no further sources, moving to history\n";
	    $retval = move_to_history( $dbh, $reqid );
	    $return_data_href->{ success } = $retval;
	    $return_data_href->{ status } = "Moved to history";
	    $return_data_href->{ message } = "";
	} else {
	    print STDERR "...so NOT moving to history\n";
	    $return_data_href->{ success } = 0;
	    $return_data_href->{ status } = "Could not move to history";
	    $return_data_href->{ message } = "No 'No further sources' message.";
	    $return_data_href->{ alert_text } = "Could not move this request to history,\nno 'No further sources' message.";
	}
    }

    case "bTryNextLender" {
	# borrowing override
	$borrower_id = $href->{"borrower_id"};
	$lender_id = $href->{"lender_id"};
	# can only cancel if the lender hasn't answered yet
	my $cntAnswers = $dbh->selectrow_array( "select count(*) from requests_active where request_id=? and msg_from=? and status like 'ILL-Answer%';", undef, $reqid, $lender_id );
	if ((defined $cntAnswers) && ($cntAnswers == 0)) {
	    $message = $href->{"borrower"} . " is trying next lender";
	    # borrower sends a message about overriding
	    $retval = $dbh->do( $SQL, undef, $reqid, $borrower_id, $lender_id, $status, $message );
	    # mark the ILL as Cancelled by the borrower
	    $retval = $dbh->do( $SQL, undef, $reqid, $borrower_id, $lender_id, 'Cancelled', "override by $href->{borrower}" );	
	    # mark the cancellation as acknowleged by the lender (so the ILL does not show up on the lender's pull list / respond list)
	    $retval = $dbh->do( $SQL, undef, $reqid, $lender_id, $borrower_id, 'CancelReply|Ok', "override by $href->{borrower}" );	

	    # try next lender (from try-next-lender.cgi)
	    my @group = $dbh->selectrow_array("select group_id from request where id=?", undef, $reqid);
	
	    $SQL = "select lid, sequence_number from sources where group_id=? and tried=false order by sequence_number";
	    my @ary = $dbh->selectrow_array( $SQL, undef, $group[0] );

	    if (@ary) {
		# mark this source as tried
		$dbh->do("update sources set request_id=?, tried=true where group_id=? and sequence_number=?", undef, $reqid, $group[0], $ary[1]);
		
		# message to requesting library
		$SQL = "insert into requests_active (request_id, msg_from, msg_to, status, message) values (?,?,?,?,?)";
		$dbh->do($SQL, undef, $reqid, $borrower_id, $borrower_id, "Message", "Trying next source");
		
		# begin the ILL conversation
		$SQL = "INSERT INTO requests_active (request_id, msg_from, msg_to, status) VALUES (?,?,?,?)";
		$dbh->do($SQL, undef, $reqid, $borrower_id, $ary[0], 'ILL-Request');
		
		$SQL = "UPDATE request SET current_source_sequence_number=? where id=?";
		$dbh->do($SQL, undef, $ary[1], $reqid);
		$return_data_href->{ success } = 1;
		$return_data_href->{ status } = "Forwarded to next lender";
	    
	    } else {
		$SQL = "insert into requests_active (request_id, msg_from, msg_to, status, message) values (?,?,?,?,?)";
		$dbh->do($SQL, undef, $reqid, $borrower_id, $borrower_id, "Message", "No further sources");
		$return_data_href->{ success } = 0;
		$return_data_href->{ status } = "Message";
		$return_data_href->{ message } = "No further sources";
		$return_data_href->{ alert_text } = "There were no further sources.\nThis request will remain here until you acknowledge 'No further sources'\n in overrides.";
	    }
	} else {
	    $return_data_href->{ success } = 0;
	    $return_data_href->{ status } = "Could not force cancellation/try-next-lender";
	    $return_data_href->{ message } = "Lender has already answered.";
	    $return_data_href->{ alert_text } = "The lender has already answered; if they could not fill the request, you can try the next lender from the Unfilled page.";
	}
    }

    case "bClose" {
	# borrowing override
	$borrower_id = $href->{"borrower_id"};
	$lender_id = $href->{"lender_id"};
	# can only close if the the borrower has returned but the lender hasn't checked in yet
	my $cntAnswers = $dbh->selectrow_array( "select count(*) from requests_active where request_id=? and msg_from=? and status='Returned' and request_id not in (select request_id from requests_active where request_id=? and status='Checked-in')", undef, $reqid, $borrower_id, $reqid );
	if ((defined $cntAnswers) && ($cntAnswers == 1)) {
	    $message = $href->{"borrower"} . " returned item but " . $href->{"lender"} . " has not checked it in";
	    # borrower sends a message about overriding
	    $retval = $dbh->do( $SQL, undef, $reqid, $borrower_id, $lender_id, $status, $message );
	    # force the ILL to be marked as Checked-in by the lender
	    $retval = $dbh->do( $SQL, undef, $reqid, $lender_id, $borrower_id, 'Checked-in', "override by $href->{borrower}" );	
	    # ...and move to history
	    $retval = move_to_history( $dbh, $reqid );
	    $return_data_href->{ success } = $retval;
	    $return_data_href->{ status } = "Checked-in";
	    $return_data_href->{ message } = "override";
	} else {
	    $return_data_href->{ success } = 0;
	    $return_data_href->{ status } = "Could not force check-in";
	    $return_data_href->{ message } = "Request not returned or already checked in.";
	    $return_data_href->{ alert_text } = "Could not close this request:\neither you have not marked the request as 'Returned'\nor the lender has already checked it in.";
	}
    }

    case "bReturned" {
	# lending override
	$borrower_id = $href->{"borrower_id"};
	$lender_id = $href->{"lender_id"};
	$message = $href->{"borrower"} . " has returned the item to " . $href->{"lender"} . " but did not mark it as 'Returned'";
	# can only Return if the the borrower has received but not yet returned
	my $cntAnswers = $dbh->selectrow_array( "select count(*) from requests_active where request_id=? and msg_to=? and status='Received' and request_id not in (select request_id from requests_active where request_id=? and status='Returned')", undef, $reqid, $lender_id, $reqid );
	if ((defined $cntAnswers) && ($cntAnswers == 1)) {
	    # lender sends a message about overriding
	    $retval = $dbh->do( $SQL, undef, $reqid, $lender_id, $borrower_id, $status, $message );
	    # force the ILL to be marked as Returned by the borrower
	    $retval = $dbh->do( $SQL, undef, $reqid, $borrower_id, $lender_id, 'Returned', "override by $href->{lender}" );	
	    # lender check-in and move to history
	    $retval = $dbh->do( $SQL, undef, $reqid, $lender_id, $borrower_id, 'Checked-in', "" );
	    $retval = move_to_history( $dbh, $reqid );
	    $return_data_href->{ success } = $retval;
	    $return_data_href->{ status } = "Returned";
	    $return_data_href->{ message } = "override";
	} else {
	    $return_data_href->{ success } = 0;
	    $return_data_href->{ status } = "Could not force return";
	    $return_data_href->{ message } = "Request not received or already returned.";
	    $return_data_href->{ alert_text } = "Could not mark this request as Returned:\neither the borrower has not Received yet,\nor they have already marked it as 'Returned'.";
	}
    }

    else {
	$borrower_id = $href->{"borrower_id"};
	$lender_id = $href->{"lender_id"};
	$message = "unknown override: [$override]";
	$retval = $dbh->do( $SQL, undef, $reqid, $borrower_id, $lender_id, $status, $message );
	$return_data_href->{ success } = $retval;
	$return_data_href->{ status } = "error";
	$return_data_href->{ message } = $message;
    }
}

# sql to add to the request conversation

$dbh->disconnect;
#print "Content-Type:application/json\n\n" . to_json( { success => $retval } );
print "Content-Type:application/json\n\n" . to_json( $return_data_href );


sub move_to_history {
    my $dbh = shift;
    my $reqid = shift;

    $dbh->{AutoCommit} = 0;  # enable transactions, if possible
    $dbh->{RaiseError} = 1;
    my $rSuccess;

    eval {
	# attempts doesn't make sense any more with request_groups... need to figure out what to do here.
	# For now, leave as-is.
	my $SQL = "insert into request_closed (id,title,author,requester,group_id,patron_barcode,attempts) (select id,title,author,requester,group_id,patron_barcode,current_source_sequence_number from request where id=?)";
	$dbh->do( $SQL, undef, $reqid );
	
	$SQL = "update request_closed set filled_by = (select msg_from from requests_active where request_id=? and status='Checked-in')";
	$dbh->do( $SQL, undef, $reqid );
	
	$SQL = "insert into requests_history (request_id, ts, msg_from, msg_to, status, message) (select request_id, ts, msg_from, msg_to, status, message from requests_active where request_id=?);";
	$dbh->do( $SQL, undef, $reqid );
	
	$SQL = "delete from requests_active where request_id=?";
	$dbh->do( $SQL, undef, $reqid );
	
	my @group = $dbh->selectrow_array("select group_id from request where id=?", undef, $reqid);
	
	# sources.request_id is an fkey.  Can't delete the request until that's reset.
	$SQL = "update sources set request_id=NULL where request_id=?";
	$dbh->do( $SQL, undef, $reqid );
	
	$SQL = "delete from request where id=?";
	$dbh->do( $SQL, undef, $reqid );
		  
	$SQL = "select count(id) from request where group_id=?";
	my @cnt = $dbh->selectrow_arrayref( $SQL, undef, $group[0] );
	if ((@cnt) && ($cnt[0] == 0)) {
	    $SQL = "delete from sources where group_id=?";
	    $dbh->do( $SQL, undef, $group[0] );
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

    return $rSuccess;
}


