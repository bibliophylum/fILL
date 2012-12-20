#!/usr/bin/perl

use DBI;
use Getopt::Long;
use Data::Dumper;

my $rid;
my $verbose;
my $help;
GetOptions ("rid=i" => \$rid, "verbose"  => \$verbose, "help" => \$help);

if ($help || (!defined $rid)) {
    print "usage: $0 --rid nnn [--verbose]\n";
    print "\tDisentangle a request currently erroneously in history,\n";
    print "\tmoving it back into active (and re-creating the active\n";
    print "\trequest_group and request_chain if necessary).\n";
    exit;
}

my $dbh = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
		       "mapapp",
		       "maplin3db",
		       {AutoCommit => 0, 
			RaiseError => 1, 
			PrintError => 0,
		       }
    );
$dbh->do("SET TIMEZONE='America/Winnipeg'");
$dbh->{PrintError} = 1 if ($verbose);

eval {
    # get the request_id, chain_id, and group_id
    my @gcr = $dbh->selectrow_array(
	"select g.group_id, c.chain_id, r.id from history_group g left join history_chain c on c.group_id = g.group_id left join request_closed r on r.chain_id = c.chain_id where r.id=?",
	undef,
	$rid
	);
    if (@gcr) {
	if ($verbose) {
	    print "gid [$gcr[0]], cid [$gcr[1]], rid [$gcr[2]]\n";
	}
    } else {
	print STDERR "error: no such request_id [$rid] in requests_history!\n";
	exit 1;
    }
    
    # see if that group already exists in active
    my @ag = $dbh->selectrow_array (
	"select count(group_id) from request_group where group_id=?",
	undef,
	$gcr[0]
	);
    if ((@ag) && ($ag[0] == 0)) {
	# not in active, so add it (using the same group_id as history)
	$dbh->do( "insert into request_group (group_id, copies_requested, title, author, requester, patron_barcode, note) select group_id, copies_requested, title, author, requester, patron_barcode, note from history_group where group_id=?",
		  undef,
		  $gcr[0]
	    );
	if ($verbose) {
	    print "history_group re-added to request_group\n";
	}
    } else {
	if ($verbose) {
	    print "history_group already exists in request_group, continuing...\n";
	}
    }

    # clean up old active request_chain with no request
    # (their requests were stolen and moved to history, which is what we're cleaning up here)
    my $existing_chains_aref = $dbh->selectall_arrayref( "select chain_id from request_chain where group_id=?",
	undef,
	$gcr[0]
	);
    if (($verbose) && (@$existing_chains_aref)) {
	print "existing active chains... checking for associated requests\n";
    }
    foreach my $chain_aref (@$existing_chains_aref) {
	#print "select count(id) from request where chain_id=" . $chain_aref->[0] . "\n";
	my @cnt = $dbh->selectrow_array( "select count(id) from request where chain_id=?",
					 undef,
					 $chain_aref->[0]
	    );
	if ((@cnt) && ($cnt[0] == 0)) {
	    $dbh->do( "delete from request_chain where group_id=? and chain_id=?",
		      undef,
		      $gcr[0],
		      $chain_aref->[0]
		);
	    if ($verbose) {
		print "\texisting chain_id [$chain_aref->[0]] had no request, so deleted.\n";
	    }
	} else {
	    if ($verbose) {
		print "\texisting chain_id [$chain_aref->[0]] HAS request(s), so kept.\n";
	    }
	}
    }

    
    # as the problem is that multiple chains got combined in history,
    # this request will need a new chain_id in active
    $dbh->do( "insert into request_chain (group_id) values (?)",
	      undef,
	      $gcr[0]
	);
    # get the new chain_id
    my @rc = $dbh->selectrow_array (
	"select max(chain_id) from request_chain where group_id=?",
	undef,
	$gcr[0]
	);
    if ($verbose) {
	print "new active chain_id [$rc[0]]\n";
    }
    
    # ...and re-create the active request (using the new chain_id)
    $dbh->do( "insert into request (id,requester,chain_id) select id, requester, ? from request_closed where id=?",
	      undef,
	      $rc[0],
	      $rid
	);
    if ($verbose) {
	print "new active request, id [$rid]  chain_id [$rc[0]]\n";
    }
    

    # move the history to active
    $dbh->do( "insert into requests_active (request_id, ts, msg_from, msg_to, status, message) (select request_id, ts, msg_from, msg_to, status, message from requests_history where request_id=?)",
	      undef,
	      $rid
	);
    if ($verbose) {
	print "associated requests_history inserted into requests_active\n";
    }
    
    $dbh->do( "delete from requests_history where request_id=?",
	      undef,
	      $rid
	);
    if ($verbose) {
	print "requests_history deleted for request_id $rid\n";
    }

    # delete the request_closed entry
    $dbh->do( "delete from request_closed where id=?",
	      undef,
	      $rid
	);
    if ($verbose) {
	print "request_closed entry for id [$rid] deleted\n";
    }


    # check if there are any request_closed entries left in that history_chain
    my @cnt = $dbh->do( "select count(id) from request_closed where chain_id=?",
			undef,
			$gcr[1]
	);
    if ((@cnt) && ($cnt[0] == 0)) {
	# no request_closed left in this history_chain
	$dbh->do( "delete from history_chain where chain_id=?",
		  undef,
		  $gcr[1]
	    );
	if ($verbose) {
	    print "no request_closed left in history_chain [$gcr[1]], so chain deleted\n";
	}
    }

    # check if there are any history_chain left in that history_group
    @cnt = undef;
    @cnt = $dbh->do( "select count(group_id) from history_chain where group_id=?",
		     undef,
		     $gcr[0]
	);
    if ((@cnt) && ($cnt[0] == 0)) {
	# no chains left in this group
	$dbh->do( "delete from history_group where group_id=?",
		  undef,
		  $gcr[0]
	    );
	if ($verbose) {
	    print "no history_chains left in this history_group, so group deleted\n";
	}
    }

    $dbh->commit;  # commit the changes if we get this far
};
if ($@) {
    warn "Transaction aborted because $@";
    # now rollback to undo the incomplete changes
    # but do it in an eval{} as it may also fail
    eval { $dbh->rollback };
    # add other application on-error-clean-up code here
}

$dbh->disconnect;



