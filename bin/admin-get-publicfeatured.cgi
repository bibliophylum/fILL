#!/usr/bin/perl
use strict;
use warnings;

use CGI;
use CGI::Session;
use DBI;
use JSON;
#use Data::Dumper;

my $query = new CGI;
my $session = CGI::Session->load(undef, $query, {Directory=>"/tmp"});
if (($session->is_expired) || ($session->is_empty)) {
    print "Content-Type:application/json\n\n" . to_json( { success => 0, message => 'invalid session' } );
    exit;
}

my $fid = $query->param('fid');

my $dbh = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
		       "mapapp",
		       "maplin3db",
		       {AutoCommit => 1, 
			RaiseError => 1, 
			PrintError => 0,
		       }
    ) or die $DBI::errstr;

my $SQL;
my $featured_aref;

if ($fid) {
    $SQL = "select fid,isbn,title,author,cover,added from featured where fid=?";
    $featured_aref = $dbh->selectall_arrayref($SQL, { Slice => {} }, $fid );

} else {
    $SQL = "select fid,isbn,title,author,cover,added from featured order by title";
    $featured_aref = $dbh->selectall_arrayref($SQL, { Slice => {} } );
}


$dbh->disconnect;

print "Content-Type:application/json\n\n" . to_json( { data => $featured_aref } );
