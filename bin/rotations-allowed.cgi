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
my $lid = $query->param('lid');
my $isAllowed;

if ($lid =~ m/^\d+$/) {

    my $dbh = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
			   "mapapp",
			   "maplin3db",
			   {AutoCommit => 1, 
			    RaiseError => 1, 
			    PrintError => 0,
			   }
	) or die $DBI::errstr;
    
    $dbh->do("SET TIMEZONE='America/Winnipeg'");
    
    $isAllowed = $dbh->selectrow_array(
	"select count(*) from rotations_participants where lid=?", 
	undef,
	$lid
	);
    
    $dbh->disconnect;

} else {
    # param is not an int....
    $isAllowed = 0;
}

print "Content-Type:application/json\n\n" . to_json( { allowed => $isAllowed } );
