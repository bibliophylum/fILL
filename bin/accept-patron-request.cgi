#!/usr/bin/perl

use CGI;
use DBI;
use JSON;

my $query = new CGI;
my $prid = $query->param('prid');
my $lid = $query->param('lid');

my $success = 0;

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
	$dbh->do("INSERT INTO request_group (copies_requested, title, author, medium, requester, patron_barcode) VALUES (?,?,?,?,?,?)",
		 undef,
		 1,        # default copies_requested
		 $patronRequest->{"title"},
		 $patronRequest->{"author"},
		 $patronRequest->{"medium"},
		 $lid,     # requester
		 $patronRequest->{"card"},
	    );
	my $group_id = $dbh->last_insert_id(undef,undef,undef,undef,{sequence=>'request_group_seq'});
	
	$dbh->do("INSERT INTO request_chain (group_id) VALUES (?)",
		 undef,
		 $group_id
	    );
	my $chain_id = $dbh->last_insert_id(undef,undef,undef,undef,{sequence=>'request_chain_seq'});
	
	$dbh->do("INSERT INTO request (requester, chain_id) VALUES (?,?)",
		 undef,
		 $lid,
		 $chain_id
	    );
	my $request_id = $dbh->last_insert_id(undef,undef,undef,undef,{sequence=>'request_seq'});
	
	$SQL = "select sequence_number, lid, call_number from patron_request_sources where prid = ? order by sequence_number";
	my $sources_aref = $dbh->selectall_arrayref($SQL, { Slice => {} }, $prid );
	for my $source (@$sources_aref) {
	    $dbh->do("INSERT INTO sources (sequence_number, lid, call_number, group_id) VALUES (?,?,?,?)",
		     undef,
		     $source->{"sequence_number"},
		     $source->{"lid"},
		     $source->{"call_number"},
		     $group_id
		);
	}
	
	$dbh->do("INSERT INTO requests_active (request_id, msg_from, msg_to, status) VALUES (?,?,?,?)",
		 undef,
		 $request_id,
		 $lid,
		 $sources_aref->[0]->{"lid"},
		 'ILL-Request'
	    );
	
	$dbh->do("UPDATE sources SET tried=true, request_id=? WHERE group_id=? AND sequence_number=?",
		 undef,
		 $request_id,
		 $group_id,
		 1
	    );

	$dbh->do("DELETE FROM patron_request WHERE prid=? and lid=?",
		 undef,
		 $prid,
		 $lid
	    );
	$dbh->do("DELETE FROM patron_request_sources WHERE prid=?",
		 undef,
		 $prid
	    );

	$dbh->do("UPDATE patrons SET ill_requests = ill_requests+1 WHERE pid=?",
		 undef,
		 $patronRequest->{"pid"}
	    );

	$dbh->commit;
    };  # end of eval
    if ($@) {
	warn "accept-patron-request transaction aborted because $@";
	eval { $dbh->rollback };
    } else {
	$success = 1;
    }
}
$dbh->disconnect;

print "Content-Type:application/json\n\n" . to_json( { success => $success } );
