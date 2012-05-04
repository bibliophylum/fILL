#!/usr/bin/perl -w

use strict;
use Getopt::Long;
use DBI;
#use Data::Dumper;

my $rid;
my $lid;
my $range_start;
my $range_end;
my $filename;
my $submitted;
my $result = GetOptions("rid=i" => \$rid,
			"lid=i" => \$lid,
			"range_start=s" => \$range_start,
			"range_end=s"   => \$range_end,
			"filename=s"    => \$filename,
			"submitted=s"   => \$submitted
    );

# should probably get this info from a conf file....
#my $dbh = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
#		       "mapapp",
#		       "maplin3db",
#		       {AutoCommit => 1, 
#			RaiseError => 1, 
#			PrintError => 0,
#		       }
#    ) or die $DBI::errstr;
#
#
#$dbh->disconnect;

open( OUTF, '>', $filename) or die "cannot open > $filename: $!";

print OUTF "This is a test.\n";
print OUTF "$rid\t$lid\t$range_start\t$range_end\t$filename\t$submitted\n";
close OUTF;
exit;

