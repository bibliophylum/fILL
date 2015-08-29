#!/usr/bin/perl

use CGI;
use CGI::Session;
use DBI;
use JSON;
use Data::Dumper;

my $query = new CGI;
my $session = CGI::Session->load(undef, $query, {Directory=>"/tmp"});
if (($session->is_expired) || ($session->is_empty)) {
    print "Content-Type:application/json\n\n" . to_json( { success => 0, message => 'invalid session' } );
    exit;
}
my $rid = $query->param('rid');
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

# sql to get specific request
#my $SQL = "select g.title, g.author, g.medium, g.isbn, g.pubdate, g.patron_barcode from request_group g left join request_chain c on c.group_id=g.group_id left join request r on r.chain_id=c.chain_id where r.id=?";
my $SQL = "select g.requester, g.title, g.author, g.medium, g.isbn, g.pubdate, p.pid from request_group g left join request_chain c on c.group_id=g.group_id left join request r on r.chain_id=c.chain_id left join patrons p on (p.card = g.patron_barcode and p.home_library_id = g.requester) where r.id=?";
my $req = $dbh->selectrow_hashref($SQL, undef, $rid );
if ($req) {

    eval {

        # These should be atomic...
	$dbh->do("INSERT INTO acquisitions (oid, title, author, medium, isbn, pubdate, pid) VALUES (?,?,?,?,?,?,?)",
		 undef,
		 $oid,     # requester
		 $req->{"title"},
		 $req->{"author"},
		 $req->{"medium"},
		 $req->{"isbn"},
		 $req->{"pubdate"},
		 $req->{"pid"}
	    );
	
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
	warn "add-request-to-acquisitions transaction aborted because $@";
	eval { $dbh->rollback };
    } else {
	$success = 1;
    }
}
$dbh->disconnect;

print "Content-Type:application/json\n\n" . to_json( { success => $success } );
