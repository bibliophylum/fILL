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

my $SQL = "select 
  pid,
  name,
  card,
  username,
  email_address,
  CASE WHEN is_enabled=1 THEN 'yes' ELSE 'no' END as is_enabled,
  CASE WHEN is_verified=1 THEN 'yes' ELSE 'no' END as is_verified,
  to_char(last_login,'YYYY-MM-DD') as last_login,
  ill_requests
from patrons
where home_library_id=? 
order by name
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

my $aref = $dbh->selectall_arrayref($SQL, { Slice => {} }, $oid );
$dbh->disconnect;

print "Content-Type:application/json\n\n" . to_json( { patrons => $aref } );
