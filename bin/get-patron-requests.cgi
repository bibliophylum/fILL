#!/usr/bin/perl

use CGI;
use DBI;
use JSON;

my $query = new CGI;
my $pid = $query->param('pid');
my $lid = $query->param('lid');
my $library = $query->param('library');
my $is_enabled = $query->param('is_enabled');

my $dbh = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
		       "mapapp",
		       "maplin3db",
		       {AutoCommit => 1, 
			RaiseError => 1, 
			PrintError => 0,
		       }
    ) or die $DBI::errstr;

$dbh->do("SET TIMEZONE='America/Winnipeg'");

# sql to get this patron's current borrowing
my $SQL="select 
  c.chain_id as cid,
  g.title, 
  g.author, 
  (case when (ra.msg_to=?) then l1.library else l2.library end) as lender, 
  (case when ra.status='ILL-Request' then 'Your library has requested it.'
        when ra.status like 'ILL-Answer|Will-Supply%' then 'The lender will lend it.'
        when ra.status like 'ILL-Answer|Hold-Placed%' then 'The lender has placed a hold for you. They expect to have it for you by '||ra.message 
        when ra.status='ILL-Answer|Unfilled' then 'The lender cannot lend it.  Your library will try another lender if possible.'
        when ra.status='Shipped' then 'The lender has shipped it to your library.'
        when ra.status='Received' then 'Your library has received it from the lender, and should be contacting you soon.'
        when ra.status='Returned' then 'Your library has returned it to the lender.'
        when ra.status='Checked-in' then 'The lender has received the returned book.'
        when ra.status='Cancelled' then 'Your library has cancelled the request to that lender.  They may try again with a different lender.'
        else ra.status
  end) as status,
  date_trunc('second',ra.ts) as ts, 
  'Loan requests have been made to '||count(s.request_id)||' of '||max(s.sequence_number)||' libraries.' as libraries_tried
from requests_active ra
  left join request r on r.id=ra.request_id
  left join request_chain c on c.chain_id = r.chain_id
  left join request_group g on g.group_id = c.group_id
  left join libraries l1 on (l1.lid=ra.msg_from) 
  left join libraries l2 on (l2.lid=ra.msg_to) 
  left join patrons p on (p.home_library_id=g.requester)
  left join sources s on (s.group_id=g.group_id)
where 
  g.patron_barcode=(select card from patrons where pid=?)
  and g.requester=?
  and ra.ts=(select max(ts) from requests_active ra2 left join request r2 on r2.id=ra2.request_id left join request_chain rc2 on rc2.chain_id=r2.chain_id where r2.chain_id=c.chain_id)
group by g.title, g.author, ts, ra.status, ra.message, c.chain_id, ra.msg_to, l1.library, l2.library 
order by ra.ts desc
";
# There will be one row per request in the chain
my $aref_borr = $dbh->selectall_arrayref($SQL, { Slice => {} }, $lid, $pid, $lid );


$dbh->disconnect;

print "Content-Type:application/json\n\n" . to_json( { active => $aref_borr } );
