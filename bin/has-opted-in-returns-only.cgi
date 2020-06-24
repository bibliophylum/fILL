#!/usr/bin/perl

use CGI;
use CGI::Session;
use DBI;
use JSON;


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
if (! defined $oid || $oid == '') {
    print "Content-Type:application/json\n\n" . to_json( { opt_in => JSON::false } );
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

my $aref = $dbh->selectrow_arrayref("select opt_in, opt_in_returns_only from org where oid=?", { Slice => {} }, $oid);
$dbh->disconnect;

my $ret = {
    opt_in => JSON::false,
    opt_in_returns_only => JSON::false
};

if (!defined $aref) {
    print "Content-Type:application/json\n\n" . to_json($ret);
    exit;
}

if ($aref->[0]) { $ret->{ opt_in } = JSON::true; }
if ($aref->[1]) { $ret->{ opt_in_returns_only } = JSON::true; }

print "Content-Type:application/json\n\n" . to_json($ret);
exit;
