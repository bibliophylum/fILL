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

$dbh->do("SET TIMEZONE='America/Winnipeg'");

my $SQL = "select count(r.id) as unfilled from request r left join requests_active ra on (r.id = ra.request_id) left join libraries l on ra.msg_from = l.lid where ra.msg_to=? and ra.status like 'ILL-Answer|Unfilled%' and r.id not in (select request_id from requests_active where status='Message' and message='Requester closed the request.') and ra.ts = (select max(ts) from requests_active ra2 where ra2.request_id = ra.request_id)";
my @unfilled = $dbh->selectrow_array($SQL, undef, $lid );
@unfilled[0] = 0 unless (@unfilled);

$SQL = "select count(r.id) as holds from request r left join requests_active ra on (r.id = ra.request_id) left join libraries l on ra.msg_from = l.lid where ra.msg_to=? and ra.status like 'ILL-Answer|Hold-Placed%' and r.id not in (select request_id from requests_active where status='Message' and message='Requester closed the request.') and ra.ts = (select max(ts) from requests_active ra2 where ra2.request_id = ra.request_id)";
my @holds = $dbh->selectrow_array($SQL, undef, $lid );
@holds[0] = 0 unless (@holds);

$SQL = "select count(r.id) as overdue from request r left join requests_active ra on (r.id = ra.request_id) left join libraries l on ra.msg_from = l.lid where ra.msg_to=? and ra.status='Shipped' and ra.request_id not in (select request_id from requests_active where msg_from=? and status='Returned') and ra.request_id not in (select request_id from requests_active where msg_to=? and status='Renew-Answer|Ok') and (substring(message from 'due (.*)') < (to_char( now()::date, 'YYYY-MM-DD')))";
my @overdue = $dbh->selectrow_array($SQL, undef, $lid, $lid, $lid );
$overdue[0] = 0 unless (@overdue);

$SQL = "select count(r.id) as renewals from request r left join requests_active ra on (r.id = ra.request_id) left join sources s on (s.request_id = ra.request_id and s.lid = ra.msg_to) left join libraries l on ra.msg_from = l.lid where ra.msg_to=? and ra.status='Renew' and ra.request_id not in (select request_id from requests_active where msg_from=? and status like 'Renew-Answer%')";
my @renews = $dbh->selectrow_array($SQL, undef, $lid, $lid );
@renews[0] = 0 unless (@renews);

$SQL = "select count(r.id) from request r left join requests_active ra on (r.id = ra.request_id) left join sources s on (s.request_id = ra.request_id and s.lid = ra.msg_to) left join libraries l on ra.msg_from = l.lid where ra.msg_to=? and ra.status='ILL-Request' and ra.request_id not in (select request_id from requests_active where msg_from=?)";
my @waiting = $dbh->selectrow_array($SQL, undef, $lid, $lid );
@waiting[0] = 0 unless (@waiting);

$SQL = "select count(r.id) from request r left join requests_active ra on (r.id = ra.request_id) left join sources s on (s.request_id = ra.request_id and s.lid = ra.msg_to) left join libraries l on ra.msg_from = l.lid where ra.msg_from=? and ra.status like '%Hold-Placed%' and ra.request_id not in (select request_id from requests_active where msg_from=? and status='Shipped') and ra.request_id not in (select request_id from requests_active where msg_from=? and status like '%being-processed-for-supply%')";
my @on_hold = $dbh->selectrow_array($SQL, undef, $lid, $lid, $lid );
@on_hold[0] = 0 unless (@on_hold);

$SQL = "select count(r.id) from request r left join requests_active ra on (r.id = ra.request_id) left join sources s on (s.request_id = ra.request_id and s.lid = ra.msg_to) left join libraries l on ra.msg_from = l.lid where ra.msg_from=? and ra.status like '%Will-Supply%' and ra.request_id not in (select request_id from requests_active where msg_from=? and status='Shipped')";
my @shipping = $dbh->selectrow_array($SQL, undef, $lid, $lid );
@shipping[0] = 0 unless (@shipping);

$SQL = "select count(prid) from patron_request where lid=?";
my @patron_requests = $dbh->selectrow_array($SQL, undef, $lid );
@patron_requests[0] = 0 unless (@patron_requests);


$dbh->disconnect;

print "Content-Type:application/json\n\n" . to_json( { counts => {unfilled => $unfilled[0], holds => $holds[0], overdue => $overdue[0], renewalRequests => $renews[0], waiting => $waiting[0], on_hold => $on_hold[0], shipping => $shipping[0], patron_requests => $patron_requests[0] } } );
