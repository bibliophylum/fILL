#!/usr/bin/perl

use CGI;
use CGI::Session;
use DBI;
use JSON;

my $query = new CGI;
#my $session = CGI::Session->load(undef, $query, {Directory=>"/tmp"});
#if (($session->is_expired) || ($session->is_empty)) {
#    print "Content-Type:application/json\n\n" . to_json( { success => 0, message => 'invalid session' } );
#    exit;
#}
my $pid = $query->param('pid');
my $oid = $query->param('oid');
my $library = $query->param('library');
my $is_enabled = $query->param('is_enabled');
my $lang = $query->param('lang') || 'en';

my $dbh = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
		       "mapapp",
		       "maplin3db",
		       {AutoCommit => 1, 
			RaiseError => 1, 
			PrintError => 0,
		       }
    ) or die $DBI::errstr;

$dbh->do("SET TIMEZONE='America/Winnipeg'");

# get i18n translations for statuses
#my @keys = qw( id stage );
#my $href_i18n = $dbh->selectall_hashref("select id,stage,text from i18n where page='public/current.tmpl' and lang=? and category='status'", \@keys, undef, $lang );

# sql to get this patron's current borrowing
my $SQL="select 
  c.chain_id as cid,
  g.title, 
  g.author, 
  (case when (ra.msg_to=?) then o1.org_name else o2.org_name end) as lender, 
  (case when ra.message is null then i18n.text
        when ra.status like 'ILL-Answer|Hold-Placed%' then i18n.text||ra.message
	when ra.status like 'Renew-Answer|Ok' then i18n.text||ra.message
        else i18n.text
	end) as status,
  (select text from i18n where page='public/current.tmpl' and lang=? and category='status' and id='Loan-requests to')||' '||count(s.request_id)||' '||(select text from i18n where page='public/current.tmpl' and lang=? and category='status' and id='Loan-requests of')||' '||max(s.sequence_number)||' '||(select text from i18n where page='public/current.tmpl' and lang=? and category='status' and id='Loan-requests libraries') as details,
  date_trunc('second',ra.ts) as ts,
  -1 as declined_id 
from requests_active ra
  left join request r on r.id=ra.request_id
  left join request_chain c on c.chain_id = r.chain_id
  left join request_group g on g.group_id = c.group_id
  left join org o1 on (o1.oid=ra.msg_from) 
  left join org o2 on (o2.oid=ra.msg_to) 
  left join patrons p on (p.home_library_id=g.requester and p.card=g.patron_barcode)
  left join sources s on (s.group_id=g.group_id) 
  left join i18n on (i18n.id like ra.status||'%') 
where 
  g.patron_barcode=(select card from patrons where pid=?)
  and g.requester=?
  and ra.ts=(select max(ts) from requests_active ra2 left join request r2 on r2.id=ra2.request_id left join request_chain rc2 on rc2.chain_id=r2.chain_id where r2.chain_id=c.chain_id) 
  and i18n.page='public/current.tmpl' and i18n.lang=? and i18n.category='status'  
group by g.title, g.author, ts, ra.status, ra.message, c.chain_id, ra.msg_to, o1.org_name, o2.org_name, i18n.text 
order by ra.ts desc
";
# There will be one row per request in the chain
my $aref_borr = $dbh->selectall_arrayref($SQL, { Slice => {} }, 
					 $oid, $lang, $lang, $lang, $pid, $oid, $lang );

# Get patron requests that the library hasn't handled yet:
$SQL = "select 
  '-1' as cid,
  title,
  author,
  '-1' as lender,
(select text from i18n where page='public/current.tmpl' and category='status' and lang=? and id='New request' and stage='status') as status,
  (select text from i18n where page='public/current.tmpl' and category='status' and lang=? and id='New request' and stage='detail') as details,
  date_trunc('second',ts) as ts,
  -1 as declined_id
from
  patron_request
where 
  oid=?
  and pid=?
order by ts desc";

my $aref = $dbh->selectall_arrayref($SQL, { Slice => {} }, $lang, $lang, $oid, $pid );

# add to aref_borr:
foreach my $href (@$aref) {
    push @$aref_borr, $href;
}



# Get patron requests that the library has declined to create:
$SQL = "select 
  '-1' as cid,
  title,
  author,
  '-1' as lender,
  (select text from i18n where page='public/current.tmpl' and i18n.lang=? and i18n.category='status' and i18n.stage='status' and i18n.id=patron_requests_declined.status) as status,
  (case when reason='wish-list' then i18n.text||' '||message
        when reason='held-locally' then 'held-locally'||' '||message 
        when reason='blocked' then 'blocked'||' '||message
        when reason='on-order' then i18n.text||' '||message
        when reason='other' then i18n.text||' '||message
        else reason||'. '||message
  end) as details,
  date_trunc('second',ts) as ts,
  prid as declined_id
from
  patron_requests_declined left join i18n on (i18n.id=reason) 
where 
  oid=?
  and pid=?
  and i18n.page='public/current.tmpl' and i18n.lang=?and i18n.category='status' and i18n.stage='detail' 
order by ts desc";

$aref = $dbh->selectall_arrayref($SQL, { Slice => {} }, $lang, $oid, $pid, $lang );
# add to aref_borr:
foreach my $href (@$aref) {
    push @$aref_borr, $href;
}


$dbh->disconnect;

print "Content-Type:application/json\n\n" . to_json( { active => $aref_borr } );
