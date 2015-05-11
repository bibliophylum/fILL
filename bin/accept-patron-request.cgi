#!/usr/bin/perl

use CGI;
use CGI::Session;
use DBI;
use JSON;

my $query = new CGI;
my $session = CGI::Session->load(undef, $query, {Directory=>"/tmp"});
if (($session->is_expired) || ($session->is_empty)) {
    print "Content-Type:application/json\n\n" . to_json( { success => 0, message => 'invalid session' } );
    exit;
}
my $prid = $query->param('prid');
my $lid = $query->param('lid');

my $success = 0;
my $message = "";
my %status;

my $dbh = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
                       "mapapp",
                       "maplin3db",
                       {AutoCommit => 0,  # enable transactions! 
                        RaiseError => 1, 
                        PrintError => 0,
                       }
    ) or die $DBI::errstr;

$dbh->do("SET TIMEZONE='America/Winnipeg'");

# sql to get new (not yet handled) patron requests
my $SQL = "select pr.prid, pr.pid, p.name, p.card, pr.title, pr.author, pr.medium from patron_request pr left join patrons p on p.pid = pr.pid where pr.prid = ? and pr.lid = ?";
my $patronRequest = $dbh->selectrow_hashref($SQL, undef, $prid, $lid );
if ($patronRequest) {

    if ((not defined ($patronRequest->{"card"}) || ($patronRequest->{"card"} =~ /^\s*$/ ))) {
	$patronRequest->{"card"} = $patronRequest->{"name"};
    }

    eval {

        # These should be atomic...
        # create the request_group
	$status{"insert-request-group"} = $dbh->do("INSERT INTO request_group (copies_requested, title, author, medium, requester, patron_barcode, patron_generated) VALUES (?,?,?,?,?,?,?)",
		 undef,
		 1,        # default copies_requested
		 $patronRequest->{"title"},
		 $patronRequest->{"author"},
		 $patronRequest->{"medium"},
		 $lid,     # requester
		 $patronRequest->{"card"},
		 1,        # patron_generated
	    );
	my $group_id = $dbh->last_insert_id(undef,undef,undef,undef,{sequence=>'request_group_seq'});
	
	$status{"insert-request-chain"} = $dbh->do("INSERT INTO request_chain (group_id) VALUES (?)",
		 undef,
		 $group_id
	    );
	my $chain_id = $dbh->last_insert_id(undef,undef,undef,undef,{sequence=>'request_chain_seq'});
	
	$status{"insert-request"} = $dbh->do("INSERT INTO request (requester, chain_id) VALUES (?,?)",
		 undef,
		 $lid,
		 $chain_id
	    );
	my $request_id = $dbh->last_insert_id(undef,undef,undef,undef,{sequence=>'request_seq'});
	
	$SQL = "select sequence_number, lid, call_number from patron_request_sources where prid = ? order by sequence_number";
	my $sources_aref = $dbh->selectall_arrayref($SQL, { Slice => {} }, $prid );
	for my $source (@$sources_aref) {
	    $status{"insert-sources"} = $dbh->do("INSERT INTO sources (sequence_number, lid, call_number, group_id) VALUES (?,?,?,?)",
		     undef,
		     $source->{"sequence_number"},
		     $source->{"lid"},
		     $source->{"call_number"},
		     $group_id
		);
	}
	
	$status{"insert-requests-active"} = $dbh->do("INSERT INTO requests_active (request_id, msg_from, msg_to, status) VALUES (?,?,?,?)",
		 undef,
		 $request_id,
		 $lid,
		 $sources_aref->[0]->{"lid"},
		 'ILL-Request'
	    );
	
	$status{"update-sources"} = $dbh->do("UPDATE sources SET tried=true, request_id=? WHERE group_id=? AND sequence_number=?",
		 undef,
		 $request_id,
		 $group_id,
		 1
	    );

	$status{"delete-patron-request-sources"} = $dbh->do("DELETE FROM patron_request_sources WHERE prid=?",
		 undef,
		 $prid
	    );
	$status{"delete-patron-request"} = $dbh->do("DELETE FROM patron_request WHERE prid=? and lid=?",
		 undef,
		 $prid,
		 $lid
	    );

	$status{"update-patrons"} = $dbh->do("UPDATE patrons SET ill_requests = ill_requests+1 WHERE pid=?",
		 undef,
		 $patronRequest->{"pid"}
	    );

	$dbh->commit;
    };  # end of eval
    if ($@) {
	$message = "accept-patron-request transaction aborted because $@";
	warn $message;
	eval { $dbh->rollback };
    } else {
	$success = 1;
    }
}
$dbh->disconnect;

print "Content-Type:application/json\n\n" . to_json( { success => $success,
						       message => $message,
						       status => \%status
						     } );
