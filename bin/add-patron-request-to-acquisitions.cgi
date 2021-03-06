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
my $oid = $query->param('oid');

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
my $SQL = "select pr.prid, pr.pid, pr.title, pr.author, pr.medium, pr.isbn, pr.pubdate, pr.ts from patron_request pr left join patrons p on p.pid = pr.pid where pr.prid = ? and pr.oid = ?";
my $patronRequest = $dbh->selectrow_hashref($SQL, undef, $prid, $oid );
if ($patronRequest) {

    eval {

        # These should be atomic...
        # create the request_group
	$dbh->do("INSERT INTO acquisitions (oid, pid, title, author, medium, isbn, pubdate, ts) VALUES (?,?,?,?,?,?,?,?)",
		 undef,
		 $oid,     # requester
		 $patronRequest->{"pid"},
		 $patronRequest->{"title"},
		 $patronRequest->{"author"},
		 $patronRequest->{"medium"},
		 $patronRequest->{"isbn"},
		 $patronRequest->{"pubdate"},
		 $patronRequest->{"ts"}
	    );

# NOTE: adding a patron request to the "wish list" now triggers a 
# "decline-patron-request.cgi", which does the following:
#
#	$dbh->do("DELETE FROM patron_request WHERE prid=? and oid=?",
#		 undef,
#		 $prid,
#		 $oid
#	    );
#	$dbh->do("DELETE FROM patron_request_sources WHERE prid=?",
#		 undef,
#		 $prid
#	    );

	$dbh->commit;
    };  # end of eval
    if ($@) {
	warn "add-patron-request-to-acquisitions transaction aborted because $@";
	eval { $dbh->rollback };
    } else {
	$success = 1;
    }
}
$dbh->disconnect;

print "Content-Type:application/json\n\n" . to_json( { success => $success } );
