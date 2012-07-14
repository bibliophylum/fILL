#!/usr/bin/perl -w
# report-dwm.pl
# daily/weekly/monthly stats

use strict;
use Getopt::Long;
use DBI;
use DateTime;
use Data::Dumper;

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
my $dbh = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
		       "mapapp",
		       "maplin3db",
		       {AutoCommit => 1, 
			RaiseError => 1, 
			PrintError => 0,
		       }
    ) or die $DBI::errstr;

my $library = $dbh->selectrow_arrayref("select library from libraries where lid=?",undef,$lid);

my $SQL_multiple_titles="select rc.title, rc.author, count(rc.title) as times_requested from request_closed rc join requests_history rh on rh.request_id = rc.id where rc.requester=? and (rh.ts >= ? and rh.ts < ?) and rh.status='ILL-Request' group by rc.title, rc.author order by count(rc.title) desc, rc.title";

my $ary = $dbh->selectall_arrayref($SQL_multiple_titles,undef,$lid,$range_start,$range_end);

open( OUTF, '>', $filename) or die "cannot open > $filename: $!";
print OUTF "Titles requested more than once between $range_start and $range_end (historical data only):\n";
print OUTF "Title\tAuthor\tRequests made\n";
print_stats($ary);
print OUTF "\n\n---current long-format date time goes here---\n";
print OUTF "$rid\t$lid\t$range_start\t$range_end\t$filename\t$submitted\n";
close OUTF;

$dbh->disconnect;
exit;

sub print_stats {
    my $aref = shift;
    foreach my $ary (@$aref) {
	foreach my $elm (@$ary) {
	    print OUTF "$elm\t";
	}
	print OUTF "\n";
    }
}
