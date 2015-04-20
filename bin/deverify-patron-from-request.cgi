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

my $SQL = "select pid from patron_request where prid = ? and lid=?";
my $patronRequest = $dbh->selectrow_hashref($SQL, undef, $prid, $lid );

if ($patronRequest) {

    eval {
	my $SQL = "delete from patron_request_sources where prid=?";
	my $rv = $dbh->do($SQL, undef, $prid );

	$SQL = "insert into patron_requests_declined (prid, title, author, pid, lid, medium, reason, message) select prid, title, author, pid, lid, medium, ?, ? from patron_request where prid=? and lid=?";
	my $reason = "Your library could not verify that you are a patron.";
	my $message = "Please contact the library.";
	my $rows = $dbh->do($SQL, undef, $reason, $message, $prid, $lid );

	$SQL = "delete from patron_request where prid=? and lid=?";
	$rows = $dbh->do($SQL, undef, $prid, $lid );

	$dbh->commit;
    };  # end of eval
    if ($@) {
	warn "deverify-patron-from-request transaction aborted because $@";
	eval { $dbh->rollback };
    } else {
	$success = 1;
    }
}
$dbh->disconnect;

print "Content-Type:application/json\n\n" . to_json( { success => $success } );
