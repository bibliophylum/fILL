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

my $dbh = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
		       "mapapp",
		       "maplin3db",
		       {AutoCommit => 1, 
			RaiseError => 1, 
			PrintError => 0,
		       }
    ) or die $DBI::errstr;

$dbh->do("SET TIMEZONE='America/Winnipeg'");

my $z3950_href = $dbh->selectrow_hashref("select o.oid,o.symbol,o.org_name,z.enabled,z.server_address,z.server_port,z.database_name,z.request_syntax,z.elements,z.nativesyntax,z.xslt,z.index_keyword,z.index_author,z.index_title,z.index_subject,z.index_isbn,z.index_issn,z.index_date,z.index_series from library_z3950 z left join org o on z.oid=o.oid where o.oid=? order by o.org_name", undef, scalar $query->param('oid') );

my $SQL = "update library_z3950 set server_address=?,server_port=?,database_name=?,request_syntax=?,elements=?,nativesyntax=?,xslt=?,index_keyword=?,index_author=?,index_title=?,index_subject=?,index_isbn=?,index_issn=?,index_date=?,index_series=?,enabled=? where oid=?";

my $isEnabled;
if (defined($query->param('enabled'))) {
    $isEnabled = $query->param('enabled') ? 1 : 0;
} else {
    $isEnabled = $z3950_href->{enabled};
}

my $retval = $dbh->do( $SQL, undef, 
		       $query->param('server') || $z3950_href->{server_address},
		       $query->param('port') || $z3950_href->{server_port},
		       $query->param('database') || $z3950_href->{database_name},
		       $query->param('request_syntax') || $z3950_href->{request_syntax},
		       $query->param('elements') || $z3950_href->{elements},
		       $query->param('nativesyntax') || $z3950_href->{nativesyntax},
		       $query->param('xslt') || $z3950_href->{xslt},
		       $query->param('index_keyword') || $z3950_href->{index_keyword},
		       $query->param('index_author') || $z3950_href->{index_author},
		       $query->param('index_title') || $z3950_href->{index_title},
		       $query->param('index_subject') || $z3950_href->{index_subject},
		       $query->param('index_isbn') || $z3950_href->{index_isbn},
		       $query->param('index_issn') || $z3950_href->{index_issn},
		       $query->param('index_date') || $z3950_href->{index_date},
		       $query->param('index_series') || $z3950_href->{index_series},
		       $isEnabled,
		       $query->param('oid') || $z3950_href->{oid}
    );

$dbh->disconnect;

print "Content-Type:application/json\n\n" . to_json( { success => $retval } );
