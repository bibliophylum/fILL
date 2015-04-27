#!/usr/bin/perl
use warnings;
use strict;
use CGI;
use CGI::Session;
use DBI;

my $query = new CGI;
my $session = CGI::Session->load(undef, $query, {Directory=>"/tmp"});
if (($session->is_expired) || ($session->is_empty)) {
    print "Content-Type:application/json\n\n" . to_json( { success => 0, message => 'invalid session' } );
    exit;
}
my $user = $query->param("user");
my $lid = $query->param("lid");

my $dbh = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
                       "mapapp",
                       "maplin3db",
                       {AutoCommit => 1, 
                        RaiseError => 1, 
                        PrintError => 0,
                       }
    ) or die $DBI::errstr;

# When SIP2 user logs out, set the username and patron name to their barcode so
# the system isn't storing names (for privacy reasons).
my $href = $self->dbh->selectrow_hashref(
    "select pid, is_externally_authenticated from patrons where username=? and home_library_id=?",
    undef,
    $user, $lid
    );
my $rows_affected = 0;
if (defined $href) {
    if ($href->{"is_externally_authenticated"}) {
	$rows_affected = $self->dbh->do("update patrons set username=card, name=card where pid=?", undef, $pid);
    }
}

$dbh->disconnect;

print "Content-Type:application/json\n\n" . to_json( { success => $rows_affected } );
