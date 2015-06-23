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

my $libsym = $query->param('libsym');

my $dbh = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
		       "mapapp",
		       "maplin3db",
		       {AutoCommit => 1, 
			RaiseError => 1, 
			PrintError => 0,
		       }
    ) or die $DBI::errstr;

my $SQL;
my $libraries_aref;

if ($libsym) {
    $SQL = "select o.oid,o.symbol,o.org_name,z.enabled,z.server_address,z.server_port,z.database_name,z.request_syntax,z.elements,z.nativesyntax,z.xslt,z.index_keyword,z.index_author,z.index_title,z.index_subject,z.index_isbn,z.index_issn,z.index_date,z.index_series from library_z3950 z left join org o on z.oid=o.oid where o.symbol=? order by o.org_name";
    $libraries_aref = $dbh->selectall_arrayref($SQL, { Slice => {} }, $libsym );

} else {
    $SQL = "select o.lid,o.symbol,o.org_name,z.enabled,z.server_address,z.server_port,z.database_name,z.request_syntax,z.elements,z.nativesyntax,z.xslt,z.index_keyword,z.index_author,z.index_title,z.index_subject,z.index_isbn,z.index_issn,z.index_date,z.index_series from library_z3950 z left join org o on z.oid=o.oid order by o.org_name";
    $libraries_aref = $dbh->selectall_arrayref($SQL, { Slice => {} } );
}


$dbh->disconnect;

print "Content-Type:application/json\n\n" . to_json( { data => $libraries_aref } );
