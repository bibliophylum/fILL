#!/usr/bin/perl
use warnings;
use strict;
use CGI;
use DBI;

my $query = new CGI;
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
    "select pid, is_sip2 from patrons where username=? and home_library_id=?",
    undef,
    $user, $lid
    );
my $rows_affected = 0;
if (defined $href) {
    if ($href->{"is_sip2"}) {
	$rows_affected = $self->dbh->do("update patrons set username=card, name=card where pid=?", undef, $pid);
    }
}

$dbh->disconnect;

print "Content-Type:application/json\n\n" . to_json( { success => $rows_affected } );
