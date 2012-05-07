#!/usr/bin/perl -w

use strict;
use Getopt::Long;
use DBI;
use DateTime;
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
my $dbh = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
		       "mapapp",
		       "maplin3db",
		       {AutoCommit => 1, 
			RaiseError => 1, 
			PrintError => 0,
		       }
    ) or die $DBI::errstr;

my $library       = $dbh->selectrow_arrayref("select library from libraries where lid=?",undef,$lid);

# random thoughts:
# On the borrowing side, the number of items requested can be different than the number of ILL-Requests, if there are any message='Trying next source'
# Need to combine historic and active into one set of numbers
# Maybe a table format?
# Either way, need to order the stats (probably in lifecycle order) rather than just loop through DBI arrays - it's a little confusing :-)

my $hbreqs        = $dbh->selectall_arrayref("select status, message, count(distinct request_id) from requests_history where request_id in (select request_id from requests_history where msg_from=? and status='ILL-Request' and ts>=? and ts<?) group by status, message",undef,$lid,$range_start,$range_end);
my $hlreqs        = $dbh->selectall_arrayref("select status, message, count(distinct request_id) from requests_history where request_id in (select request_id from requests_history where msg_to=? and status='ILL-Request' and ts>=? and ts<?) group by status, message",undef,$lid,$range_start,$range_end);

my $abreqs        = $dbh->selectall_arrayref("select status, message, count(distinct request_id) from requests_active where request_id in (select request_id from requests_active where msg_from=? and status='ILL-Request' and ts>=? and ts<?) group by status, message",undef,$lid,$range_start,$range_end);
my $alreqs        = $dbh->selectall_arrayref("select status, message, count(distinct request_id) from requests_active where request_id in (select request_id from requests_active where msg_to=? and status='ILL-Request' and ts>=? and ts<?) group by status, message",undef,$lid,$range_start,$range_end);

$dbh->disconnect;

open( OUTF, '>', $filename) or die "cannot open > $filename: $!";

print OUTF $library->[0] . "\n\n";
print OUTF "Basic statistics.\n";
print OUTF "ILL requests initiated from $range_start up to (but not including) $range_end.\n\n";

print OUTF "Borrowing from other libraries\n";
#print OUTF Dumper($hbreqs) . "\n";
print OUTF "\nHistoric:\n";
foreach my $aref (@$hbreqs) {
    print OUTF $aref->[0] . " " . $aref->[1] . "\t" . $aref->[2] . "\n";
}
print OUTF "\nCurrently active requests:\n";
foreach my $aref (@$abreqs) {
    print OUTF $aref->[0] . " " . $aref->[1] . "\t" . $aref->[2] . "\n";
}

print OUTF "\n\nLending to other libraries\n\n";
#print OUTF Dumper($hlreqs) . "\n";
print OUTF "\nHistoric:\n";
foreach my $aref (@$hlreqs) {
    print OUTF $aref->[0] . " " . $aref->[1] . "\t" . $aref->[2] . "\n";
}
print OUTF "\nCurrently active requests:\n";
foreach my $aref (@$alreqs) {
    print OUTF $aref->[0] . " " . $aref->[1] . "\t" . $aref->[2] . "\n";
}

print OUTF "\n\n---current long-format date time goes here---\n";
print OUTF "$rid\t$lid\t$range_start\t$range_end\t$filename\t$submitted\n";
close OUTF;
exit;

