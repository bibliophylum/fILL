#!/usr/bin/perl
use warnings;
use strict;
use JSON;
use CGI;
use DBI;

my $query = new CGI;

my $dbh = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
                       "mapapp",
                       "maplin3db",
                       {AutoCommit => 1, 
                        RaiseError => 1, 
                        PrintError => 0,
                       }
    ) or die $DBI::errstr;
#$dbh->do("SET TIMEZONE='America/Winnipeg'");

my $SQL = "select enabled, l.lid from libraries l left join library_sip2 s on s.lid=l.lid where l.city=?";
my $aref = $dbh->selectrow_hashref($SQL, { Slice => {} }, $query->param('city'));
$dbh->disconnect;

print "Content-Type:application/json\n\n" . to_json( { sip2 => $aref } );
