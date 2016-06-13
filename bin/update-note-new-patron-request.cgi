#!/usr/bin/perl

use CGI;
use CGI::Session;
use DBI;
use JSON;
use Data::Dumper;

my $query = new CGI;
#my $session = CGI::Session->load(undef, $query, {Directory=>"/tmp"});
#if (($session->is_expired) || ($session->is_empty)) {
#    print "Content-Type:application/json\n\n" . to_json( { success => 0, message => 'invalid session' } );
#    exit;
#}

my $note = scalar $query->param('value');
my $reqid = scalar $query->param('prid');
$reqid = substr( $reqid, 2 );  # lose the leading "pr"
my $private_to = scalar $query->param('private_to');

my $dbh = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
		       "mapapp",
		       "maplin3db",
		       {AutoCommit => 1, 
			RaiseError => 1, 
			PrintError => 0,
		       }
    ) or die $DBI::errstr;

$dbh->do("SET TIMEZONE='America/Winnipeg'");

my $retval;

$retval = $dbh->do( "update patron_request set note=? where prid=?", undef, $note, $reqid );

$dbh->disconnect;

print "Content-Type:application/json\n\n" . to_json( { success => $retval, data => $note, prid => $reqid } );
