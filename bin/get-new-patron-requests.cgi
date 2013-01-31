#!/usr/bin/perl

use CGI;
use DBI;
use JSON;

my $query = new CGI;
my $lid = $query->param('lid');

# sql to get new (not yet handled) patron requests
my $SQL = "select 
  pr.prid, 
  date_trunc('second',pr.ts) as ts, 
  p.name, 
  p.card, 
  pr.title, 
  pr.author,
  p.is_verified
from 
  patron_request pr 
  left join patrons p on p.pid = pr.pid 
where 
  pr.lid = ? 
order by 
  name, ts";

my $dbh = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
                       "mapapp",
                       "maplin3db",
                       {AutoCommit => 1, 
                        RaiseError => 1, 
                        PrintError => 0,
                       }
    ) or die $DBI::errstr;

$dbh->do("SET TIMEZONE='America/Winnipeg'");

my $aref = $dbh->selectall_arrayref($SQL, { Slice => {} }, $lid );
$dbh->disconnect;

print "Content-Type:application/json\n\n" . to_json( { new_patron_requests => $aref } );
