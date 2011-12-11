#!/usr/bin/perl

use CGI;
use DBI;
use JSON;

my $query = new CGI;
my $lid = $query->param('lid');

my $dbh = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
		       "mapapp",
		       "maplin3db",
		       {AutoCommit => 1, 
			RaiseError => 1, 
			PrintError => 0,
		       }
    ) or die $DBI::errstr;

my $SQL = "select count(r.id) as renewals from request r left join requests_active ra on (r.id = ra.request_id) left join sources s on (s.request_id = ra.request_id and s.library = ra.msg_to) left join libraries l on ra.msg_from = l.lid where ra.msg_to=? and ra.status='Renew' and ra.request_id not in (select request_id from requests_active where msg_from=? and status like 'Renew-Answer%')";
my @renews = $dbh->selectrow_array($SQL, undef, $lid, $lid );
@renews[0] = 0 unless (@renews);

$SQL = "select count(r.id) from request r left join requests_active ra on (r.id = ra.request_id) left join sources s on (s.request_id = ra.request_id and s.library = ra.msg_to) left join libraries l on ra.msg_from = l.lid where ra.msg_to=? and ra.status='ILL-Request' and ra.request_id not in (select request_id from requests_active where msg_from=?)";
my @waiting = $dbh->selectrow_array($SQL, undef, $lid, $lid );
@waiting[0] = 0 unless (@waiting);

$dbh->disconnect;

print "Content-Type:application/json\n\n" . to_json( { counts => {renewalRequests => $renews[0], waiting => $waiting[0]} } );
