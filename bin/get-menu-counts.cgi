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
my $oid = $query->param('oid');

my $dbh = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
		       "mapapp",
		       "maplin3db",
		       {AutoCommit => 1, 
			RaiseError => 1, 
			PrintError => 0,
		       }
    ) or die $DBI::errstr;

$dbh->do("SET TIMEZONE='America/Winnipeg'");

my $SQL = "select count(r.id) as unfilled from request r left join requests_active ra on (r.id = ra.request_id) left join org o on ra.msg_from = o.oid where ra.msg_to=? and ra.status like 'ILL-Answer|Unfilled%' and r.id not in (select request_id from requests_active where status='Message' and message='Requester closed the request.') and ra.ts = (select max(ts) from requests_active ra2 where ra2.request_id = ra.request_id)";
my @unfilled = $dbh->selectrow_array($SQL, undef, $oid );
@unfilled[0] = 0 unless (@unfilled);

$SQL = "select count(r.id) as holds from request r left join requests_active ra on (r.id = ra.request_id) left join org o on ra.msg_from = o.oid where ra.msg_to=? and ra.status like 'ILL-Answer|Hold-Placed%' and r.id not in (select request_id from requests_active where status='Message' and message='Requester closed the request.') and ra.ts = (select max(ts) from requests_active ra2 where ra2.request_id = ra.request_id)";
my @holds = $dbh->selectrow_array($SQL, undef, $oid );
@holds[0] = 0 unless (@holds);

$SQL = "select count(r.id) as overdue from request r left join requests_active ra on (r.id = ra.request_id) left join org o on ra.msg_from = o.oid where ra.msg_to=? and ra.status='Shipped' and ra.request_id not in (select request_id from requests_active where msg_from=? and status='Returned') and ra.request_id not in (select request_id from requests_active where msg_to=? and status='Renew-Answer|Ok') and (substring(message from 'due (.*)') < (to_char( now()::date, 'YYYY-MM-DD')))";
my @overdue = $dbh->selectrow_array($SQL, undef, $oid, $oid, $oid );
$overdue[0] = 0 unless (@overdue);

$SQL = "select count(r.id) as renewals from request r left join requests_active ra on (r.id = ra.request_id) left join sources s on (s.request_id = ra.request_id and s.oid = ra.msg_to) left join org o on ra.msg_from = o.oid where ra.msg_to=? and ra.status='Renew' and ra.request_id not in (select request_id from requests_active where msg_from=? and status like 'Renew-Answer%')";
my @renews = $dbh->selectrow_array($SQL, undef, $oid, $oid );
@renews[0] = 0 unless (@renews);

$SQL = "select count(r.id) from request r left join requests_active ra on (r.id = ra.request_id) left join sources s on (s.request_id = ra.request_id and s.oid = ra.msg_to) left join org o on ra.msg_from = o.oid where ra.msg_to=? and ra.status='ILL-Request' and ra.request_id not in (select request_id from requests_active where msg_from=?)";
my @waiting = $dbh->selectrow_array($SQL, undef, $oid, $oid );
@waiting[0] = 0 unless (@waiting);

$SQL = "select count(r.id) from request r left join requests_active ra on (r.id = ra.request_id) left join sources s on (s.request_id = ra.request_id and s.oid = ra.msg_to) left join org o on ra.msg_from = o.oid where ra.msg_from=? and ra.status like '%Hold-Placed%' and ra.request_id not in (select request_id from requests_active where msg_from=? and status='Shipped') and ra.request_id not in (select request_id from requests_active where msg_from=? and status like '%being-processed-for-supply%')";
my @on_hold = $dbh->selectrow_array($SQL, undef, $oid, $oid, $oid );
@on_hold[0] = 0 unless (@on_hold);

$SQL = "select count(r.id)
from request r 
  left join requests_active ra on (r.id = ra.request_id) 
where ra.msg_to=? 
  and ra.request_id in (select request_id from requests_active where msg_from=? and status like '%Hold-Placed%') 
  and ra.request_id not in (select request_id from requests_active where msg_from=? and status='Shipped') 
  and ra.request_id not in (select request_id from requests_active where msg_from=? and status like '%being-processed-for-supply%')
  and ra.status='Cancel'
";
my @on_hold_cancel = $dbh->selectrow_array($SQL, undef, $oid, $oid, $oid, $oid );
@on_hold_cancel[0] = 0 unless (@on_hold_cancel);
if ($on_hold_cancel[0] > 0) {
    $on_hold[0] -= $on_hold_cancel[0];
}

$SQL = "select count(r.id) from request r left join requests_active ra on (r.id = ra.request_id) left join sources s on (s.request_id = ra.request_id and s.oid = ra.msg_to) left join org o on ra.msg_from = o.oid where ra.msg_from=? and ra.status like '%Will-Supply%' and ra.request_id not in (select request_id from requests_active where msg_from=? and status='Shipped')";
my @shipping = $dbh->selectrow_array($SQL, undef, $oid, $oid );
@shipping[0] = 0 unless (@shipping);

$SQL = "select count(prid) from patron_request where oid=?";
my @patron_requests = $dbh->selectrow_array($SQL, undef, $oid );
@patron_requests[0] = 0 unless (@patron_requests);

$SQL = "select count(r.id) from request r left join requests_active ra on ra.request_id=r.id where ra.msg_to=? and ra.status = 'Lost'";
my @lost = $dbh->selectrow_array($SQL, undef, $oid );
@lost[0] = 0 unless (@lost);

$SQL = "select count(r.id) as pending from requests_active ra left join request r on r.id=ra.request_id left join request_chain c on c.chain_id = r.chain_id left join request_group g on g.group_id = c.group_id left join org o on o.oid = ra.msg_to where ra.msg_from=? and ra.status = 'ILL-Request' and r.id not in (select request_id from requests_active where status like 'ILL-Answer%') and ra.ts = (select max(ts) from requests_active ra2 where ra2.request_id = ra.request_id)";
my @pending = $dbh->selectrow_array($SQL, undef, $oid );
@pending[0] = 0 unless (@pending);


$dbh->disconnect;

print "Content-Type:application/json\n\n" . to_json( { counts => {unfilled => $unfilled[0], holds => $holds[0], overdue => $overdue[0], renewalRequests => $renews[0], waiting => $waiting[0], on_hold => $on_hold[0], on_hold_cancel => $on_hold_cancel[0], shipping => $shipping[0], patron_requests => $patron_requests[0], lost => $lost[0], pending => $pending[0] } } );
