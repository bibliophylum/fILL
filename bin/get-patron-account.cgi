#!/usr/bin/perl

use CGI;
use DBI;
use JSON;

my $query = new CGI;
my $lid = $query->param('lid');
my $pid = $query->param('pid');
my $SQL = "select 
  pid,
  name,
  card,
  username,
  email_address,
  is_enabled,
  is_verified,
  to_char(last_login,'YYYY-MM-DD') as last_login,
  ill_requests
from patrons
where home_library_id=? and pid=?
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

my $href = $dbh->selectrow_hashref($SQL, { Slice => {} }, $lid, $pid );
$dbh->disconnect;

my @settings;
foreach my $key (sort keys %$href) {
    my %setting = ( "pid" => $pid, "setting" => $key, "value" => $href->{$key} );
    push @settings, \%setting;
}

print "Content-Type:application/json\n\n" . to_json( { account => \@settings } );
