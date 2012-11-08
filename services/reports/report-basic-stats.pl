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

$dbh->do("SET TIMEZONE='America/Winnipeg'");

my $library = $dbh->selectrow_arrayref("select library from libraries where lid=?",undef,$lid);

open( OUTF, '>', $filename) or die "cannot open > $filename: $!";

print OUTF $library->[0] . "\n\n";
print OUTF "Basic statistics.\n";
print OUTF "ILL requests initiated from $range_start up to (but not including) $range_end.\n\n";

my $aryref;

# Borrowing
# Note: counting stats for requests initiated within the date range, regardless of when the answers came.
my $booksRequested = 0;
my $requestsMade = 0;
my $respondedUnfilled = 0;
my $lenderShipped = 0;
my $weCancelled;
foreach my $tbl (qw/active history/) {
    $aryref = $dbh->selectrow_arrayref("select count(distinct request_id), count(request_id) from requests_$tbl where msg_from=? and status='ILL-Request' and request_id in (select request_id from requests_$tbl where ts>=? and ts<?)", undef, $lid, $range_start, $range_end);
    $booksRequested += $aryref->[0];
    $requestsMade += $aryref->[1];

    $aryref = $dbh->selectrow_arrayref("select count(request_id) from requests_$tbl where msg_to=? and status like 'ILL-Answer|Unfilled%' and request_id in (select request_id from requests_$tbl where ts>=? and ts<?)", undef, $lid, $range_start, $range_end);
    $respondedUnfilled += $aryref->[0];

    $aryref = $dbh->selectrow_arrayref("select count(request_id) from requests_$tbl where msg_to=? and status='Shipped' and request_id in (select request_id from requests_$tbl where ts>=? and ts<?)", undef, $lid, $range_start, $range_end);
    $lenderShipped += $aryref->[0];

    # To calculate the # of requests that we cancelled before receiving a reply:
    # 1. Find the requests we initiated in that time frame (status = 'ILL-Request')
    # 2. Ignore the requests that someone replied to (status like 'ILL-Answer%')
    # 3. Count the entries where status = 'Cancelled'
    $aryref = $dbh->selectrow_arrayref("select count(request_id) from requests_$tbl where msg_from=? and status='Cancelled' and ts>=? and ts<? and request_id in (select request_id from requests_$tbl where msg_from=? and status='ILL-Request' and ts>=? and ts<?) and request_id not in (select request_id from requests_$tbl where msg_to=? and status like 'ILL-Answer%' and ts>=? and ts<?)", undef, $lid, $range_start, $range_end, $lid, $range_start, $range_end, $lid, $range_start, $range_end);
    $weCancelled += $aryref->[0];
}
print OUTF "Borrowing\tbooks requested\trequests made\tlender unfilled\tlender shipped\twe cancelled\n";
print OUTF "\t$booksRequested\t$requestsMade\t$respondedUnfilled\t$lenderShipped\t$weCancelled\n";

# Lending
# Counting answers made within the date range, regardless of when the request was initiated.
my $requestsToLend = 0;
my $couldNotFill = 0;
my $shipped = 0;
my $forwardToBranch = 0;
my $borrowerCancelled = 0;
foreach my $tbl (qw/active history/) {
    $aryref = $dbh->selectrow_arrayref("select count(request_id) from requests_$tbl where msg_to=? and status='ILL-Request' and ts>=? and ts<?", undef, $lid, $range_start, $range_end);
    $requestsToLend += $aryref->[0];

    $aryref = $dbh->selectrow_arrayref("select count(request_id) from requests_$tbl where msg_from=? and status like 'ILL-Answer|Unfilled%' and ts>=? and ts<?", undef, $lid, $range_start, $range_end);
    $couldNotFill += $aryref->[0];

    $aryref = $dbh->selectrow_arrayref("select count(request_id) from requests_$tbl where msg_from=? and status='Shipped' and ts>=? and ts<?", undef, $lid, $range_start, $range_end);
    $shipped += $aryref->[0];

    $aryref = $dbh->selectrow_arrayref("select count(request_id) from requests_$tbl where msg_from=? and status like 'ILL-Answer|Locations-provided%' and ts>=? and ts<?", undef, $lid, $range_start, $range_end);
    $forwardToBranch += $aryref->[0];

    $aryref = $dbh->selectrow_arrayref("select count(request_id) from requests_$tbl where msg_to=? and status='Cancelled' and ts>=? and ts<?", undef, $lid, $range_start, $range_end);
    $borrowerCancelled += $aryref->[0];
}
print OUTF "Lending\trequests\tcould not fill\tshipped\tforward\tborrower cancelled\n";
print OUTF "\t$requestsToLend\t$couldNotFill\t$shipped\t$forwardToBranch\t$borrowerCancelled\n";

$dbh->disconnect;


print OUTF "\n\n---current long-format date time goes here---\n";
print OUTF "$rid\t$lid\t$range_start\t$range_end\t$filename\t$submitted\n";
close OUTF;
exit;

