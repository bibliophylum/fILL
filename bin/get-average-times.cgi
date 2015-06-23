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

my $SQL = "
--
-- Time stats, average for all libraries over the last year
--
select
 (select -1) as oid,

 (select 'Average') as library,

 (select
  extract(day from avg(extract(epoch from respond.ts) - extract(epoch from request.ts)) / (60*60*24) * interval '1 day') as request_to_response_average_days
 from
  requests_history as request
  left join requests_history as respond on request.request_id=respond.request_id
 where
  request.ts >= (now() - interval '3 months')
  and request.status='ILL-Request'
  and respond.status like 'ILL-Answer%'
 ) as request_to_response_days,

 (select
  extract(hour from avg(extract(epoch from h2.ts) - extract(epoch from h1.ts)) / (60*60*24) * interval '1 day') as will_supply_to_shipped_average_hours
 from
  requests_history as h1
  left join requests_history as h2 on h1.request_id=h2.request_id
 where
  h1.ts >= (now() - interval '3 months')
  and h1.status like 'ILL-Answer|Will-Supply%'
  and h2.status like 'Shipped%'
 ) as will_supply_to_shipped_hours,

 (select
  extract(day from avg(extract(epoch from h2.ts) - extract(epoch from h1.ts)) / (60*60*24) * interval '1 day') as shipped_to_received_average_days
 from
  requests_history as h1
  left join requests_history as h2 on h1.request_id=h2.request_id
 where
  h1.ts >= (now() - interval '3 months')
  and h1.status = 'Shipped'
  and h2.status = 'Received'
 ) as shipped_to_received_days,

 (select
  extract(day from avg(extract(epoch from h2.ts) - extract(epoch from h1.ts)) / (60*60*24) * interval '1 day') as renew_to_renew_answer_average_days
 from
  requests_history as h1
  left join requests_history as h2 on h1.request_id=h2.request_id
 where
  h1.ts >= (now() - interval '3 months')
  and h1.status = 'Renew'
  and h2.status like 'Renew-Answer%'
 ) as renew_to_renew_answer_days,

 (select
  extract(day from avg(extract(epoch from h2.ts) - extract(epoch from h1.ts)) / (60*60*24) * interval '1 day') as received_to_returned_average_days
 from
  requests_history as h1
  left join requests_history as h2 on h1.request_id=h2.request_id
 where
  h1.ts >= (now() - interval '3 months')
  and h1.status = 'Received'
  and h2.status = 'Returned'
 ) as received_to_returned_days,

 (select
  extract(day from avg(extract(epoch from h2.ts) - extract(epoch from h1.ts)) / (60*60*24) * interval '1 day') as returned_to_checked_in_average_days
 from
  requests_history as h1
  left join requests_history as h2 on h1.request_id=h2.request_id
 where
  h1.ts >= (now() - interval '3 months')
  and h1.status = 'Returned'
  and h2.status = 'Checked-in'
 ) as returned_to_checked_in_days
";
my $global_href = $dbh->selectrow_hashref($SQL);
#@unfilled[0] = 0 unless (@unfilled);
#print Dumper($global_href);



$SQL = "select oid from org where active=1";
my $libs_aref = $dbh->selectcol_arrayref($SQL);

my @libraryStats = ();
#my $oid = 79;
foreach my $oid (@$libs_aref) {

$SQL = "
--
-- Time stats, average for one library over the last year
--
select
 (select oid from org where oid=?) as oid,

 (select org_name from org where oid=?) as library,

 (select
  extract(day from avg(extract(epoch from respond.ts) - extract(epoch from request.ts)) / (60*60*24) * interval '1 day') as request_to_response_average_days
 from
  requests_history as request
  left join requests_history as respond on request.request_id=respond.request_id
 where
  request.ts >= (now() - interval '3 months')
  and request.status='ILL-Request'
  and respond.status like 'ILL-Answer%'
  and request.msg_to=?
 ) as request_to_response_days,

 (select
  extract(hour from avg(extract(epoch from h2.ts) - extract(epoch from h1.ts)) / (60*60*24) * interval '1 day') as will_supply_to_shipped_average_hours
 from
  requests_history as h1
  left join requests_history as h2 on h1.request_id=h2.request_id
 where
  h1.ts >= (now() - interval '3 months')
  and h1.status like 'ILL-Answer|Will-Supply%'
  and h2.status like 'Shipped%'
  and h1.msg_from=?
 ) as will_supply_to_shipped_hours,

 (select
  extract(day from avg(extract(epoch from h2.ts) - extract(epoch from h1.ts)) / (60*60*24) * interval '1 day') as shipped_to_received_average_days
 from
  requests_history as h1
  left join requests_history as h2 on h1.request_id=h2.request_id
 where
  h1.ts >= (now() - interval '3 months')
  and h1.status = 'Shipped'
  and h2.status = 'Received'
  and h1.msg_from=?
 ) as shipped_to_received_days,

 (select
  extract(day from avg(extract(epoch from h2.ts) - extract(epoch from h1.ts)) / (60*60*24) * interval '1 day') as renew_to_renew_answer_average_days
 from
  requests_history as h1
  left join requests_history as h2 on h1.request_id=h2.request_id
 where
  h1.ts >= (now() - interval '3 months')
  and h1.status = 'Renew'
  and h2.status like 'Renew-Answer%'
  and h1.msg_to=?
 ) as renew_to_renew_answer_days,

 (select
  extract(day from avg(extract(epoch from h2.ts) - extract(epoch from h1.ts)) / (60*60*24) * interval '1 day') as received_to_returned_average_days
 from
  requests_history as h1
  left join requests_history as h2 on h1.request_id=h2.request_id
 where
  h1.ts >= (now() - interval '3 months')
  and h1.status = 'Received'
  and h2.status = 'Returned'
  and h1.msg_to=?
 ) as received_to_returned_days,

 (select
  extract(day from avg(extract(epoch from h2.ts) - extract(epoch from h1.ts)) / (60*60*24) * interval '1 day') as returned_to_checked_in_average_days
 from
  requests_history as h1
  left join requests_history as h2 on h1.request_id=h2.request_id
 where
  h1.ts >= (now() - interval '3 months')
  and h1.status = 'Returned'
  and h2.status = 'Checked-in'
  and h1.msg_to=?
 ) as returned_to_checked_in_days
";
my $library_href = $dbh->selectrow_hashref($SQL, undef, $oid, $oid, $oid, $oid, $oid, $oid, $oid, $oid);
#print Dumper($library_href);
push @libraryStats, { %$library_href };
}

#print Dumper(@libraryStats);

my @sorted =  sort { $a->{library} <=> $b->{library} } @libraryStats;

unshift @sorted, { %$global_href };

$dbh->disconnect;

print "Content-Type:application/json\n\n" . to_json( { average => { %$global_href }, libraries => \@sorted } );
