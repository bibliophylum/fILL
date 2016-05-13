#!/usr/bin/perl

use CGI;
use CGI::Session;
use DBI;
use JSON;
use GD::Barcode;
use GD::Barcode::Code39;
use MIME::Base64;

my $query = new CGI;
my $session;
if (($ENV{GATEWAY_INTERFACE}) && ($ENV{GATEWAY_INTERFACE} =~ /CGI/)) {  # only worry about session if we're a cgi
    $session = CGI::Session->load(undef, $query, {Directory=>"/tmp"});
    if (($session->is_expired) || ($session->is_empty)) {
        print "Content-Type:application/json\n\n" . to_json( { success => 0, message => 'invalid session' } );
        exit;
    }
}

my $oid = $query->param('oid');

# sql to get requests to this library, which this library has not responded to yet
my $SQL="select 
  b.barcode, 
  g.title, 
  g.author, 
  g.note, 
  date_trunc('second',ra.ts) as ts, 
  o.symbol as from, 
  o.org_name as library, 
  s.call_number,
  g.pubdate  
from requests_active ra
  left join request r on r.id=ra.request_id
  left join request_chain c on c.chain_id = r.chain_id
  left join request_group g on g.group_id = c.group_id
  left join library_barcodes b on (ra.msg_from = b.borrower and b.oid=?) 
  left join sources s on (s.group_id = g.group_id and s.oid = ra.msg_to) 
  left join org o on o.oid = ra.msg_from
where 
  ra.msg_to=? 
  and ra.status='ILL-Request' 
  and ra.request_id not in (select request_id from requests_active where msg_from=?) 
  and ra.request_id not in (select request_id from requests_active where msg_to=? and message='Trying next source') 
order by s.call_number
";

my $dbh = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
		       "mapapp",
		       "maplin3db",
		       {AutoCommit => 1, 
			RaiseError => 1, 
			PrintError => 0,
		       }
    ) or die $DBI::errstr;

$dbh->do("SET TIMEZONE='America/Winnipeg'");

my $pulls = $dbh->selectall_arrayref($SQL, { Slice => {} }, $oid, $oid, $oid, $oid );

# generate barcodes (code39 requires '*' as start and stop characters
foreach my $request (@$pulls) {
    if (( $request->{barcode} ) && ( $request->{barcode} =~ /\d+/)) {
	$request->{"barcode_image"} = encode_base64(GD::Barcode::Code39->new( '*' . $request->{barcode} . '*' )->plot->png);
    }
}

$dbh->disconnect;

print "Content-Type:application/json\n\n" . to_json( { pullList => $pulls } );
