#!/usr/bin/perl

use DBI;

open(ADDR,'<','addresses.txt') or die;

my $SQL = "update libraries set city=?, province=?, post_code=? where lid=?";

my $dbh = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
                       "mapapp",
                       "maplin3db",
                       {AutoCommit => 1, 
                        RaiseError => 1, 
                        PrintError => 0,
                       }
    ) or die $DBI::errstr;

while (<ADDR>) {
    print;
    chomp;
    my ($lid, $city, $prov, $post) = split/\t/;
    $post =~ s/ //;
    my $retval = $dbh->do( $SQL, undef, $city, $prov, $post, $lid );
}

$dbh->disconnect;
close ADDR;
