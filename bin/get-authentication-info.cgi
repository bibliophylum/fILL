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

my $dbh = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
		       "mapapp",
		       "maplin3db",
		       {AutoCommit => 1, 
			RaiseError => 1, 
			PrintError => 0,
		       }
    ) or die $DBI::errstr;

$dbh->do("SET TIMEZONE='America/Winnipeg'");

my $SQL = "select enabled,host,port,terminator,sip_server_login,sip_server_password,validate_using_info from library_sip2 where oid=?";
my $sip2_href = $dbh->selectrow_hashref($SQL, undef, $oid );

$SQL = "select enabled,auth_type,url from library_nonsip2 where oid=?";
my $nonsip2_href = $dbh->selectrow_hashref($SQL, undef, $oid );

$SQL = "select distinct patron_authentication_method from org order by patron_authentication_method";
my $authtypes_aref = $dbh->selectall_arrayref($SQL);

$SQL = "select oid, org_name from org where oid=?";
my $library_href = $dbh->selectrow_hashref($SQL, undef, $oid );



$dbh->disconnect;

print "Content-Type:application/json\n\n" . to_json( { library => $library_href,
						       sip2 => $sip2_href,
						       nonsip2 => $nonsip2_href,
						       authtypes => $authtypes_aref
						     } );
