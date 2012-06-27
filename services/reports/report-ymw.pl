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

my $library       = $dbh->selectrow_arrayref("select library from libraries where lid=?",undef,$lid);

# random thoughts:
# On the borrowing side, the number of items requested can be different than the number of ILL-Requests, if there are any message='Trying next source'
# Need to combine historic and active into one set of numbers
# Maybe a table format?
# Either way, need to order the stats (probably in lifecycle order) rather than just loop through DBI arrays - it's a little confusing :-)

#my $hlreqs        = $dbh->selectall_arrayref("select status, message, count(distinct request_id) from requests_history where request_id in (select request_id from requests_history where msg_to=? and status='ILL-Request' and ts>=? and ts<?) group by status, message",undef,$lid,$range_start,$range_end);
#my $alreqs        = $dbh->selectall_arrayref("select status, message, count(distinct request_id) from requests_active where request_id in (select request_id from requests_active where msg_to=? and status='ILL-Request' and ts>=? and ts<?) group by status, message",undef,$lid,$range_start,$range_end);

my $SQL_borrow_history="select date_trunc(?,ts) as period, substring(status from '((ILL-Request|ILL-Answer.*(Will-Supply|Unfilled))).*') as status, count(distinct request_id) from requests_history where request_id in (select request_id from requests_history where msg_from=? and status='ILL-Request' and ts>=? and ts<?) and (status='ILL-Request' or status like 'ILL-Answer%') group by period, status order by period, idx(array['ILL-Request','ILL-Answer|Will-Supply','ILL-Answer|Unfilled'], substring(status from '((ILL-Request|ILL-Answer.*(Will-Supply|Unfilled))).*'))";

my $SQL_lend_history="select date_trunc(?,ts) as period, substring(status from '((ILL-Request|ILL-Answer.*(Will-Supply|Unfilled))).*') as status, count(distinct request_id) from requests_history where request_id in (select request_id from requests_history where msg_to=? and status='ILL-Request' and ts>=? and ts<?) and (status='ILL-Request' or status like 'ILL-Answer%') group by period, status order by period, idx(array['ILL-Request','ILL-Answer|Will-Supply','ILL-Answer|Unfilled'], substring(status from '((ILL-Request|ILL-Answer.*(Will-Supply|Unfilled))).*'))";

my $SQL_borrow_active="select date_trunc(?,ts) as period, substring(status from '((ILL-Request|ILL-Answer.*(Will-Supply|Unfilled))).*') as status, count(distinct request_id) from requests_active where request_id in (select request_id from requests_active where msg_from=? and status='ILL-Request' and ts>=? and ts<?) and (status='ILL-Request' or status like 'ILL-Answer%') group by period, status order by period, idx(array['ILL-Request','ILL-Answer|Will-Supply','ILL-Answer|Unfilled'], substring(status from '((ILL-Request|ILL-Answer.*(Will-Supply|Unfilled))).*'))";

my $SQL_lend_active="select date_trunc(?,ts) as period, substring(status from '((ILL-Request|ILL-Answer.*(Will-Supply|Unfilled))).*') as status, count(distinct request_id) from requests_active where request_id in (select request_id from requests_active where msg_to=? and status='ILL-Request' and ts>=? and ts<?) and (status='ILL-Request' or status like 'ILL-Answer%') group by period, status order by period, idx(array['ILL-Request','ILL-Answer|Will-Supply','ILL-Answer|Unfilled'], substring(status from '((ILL-Request|ILL-Answer.*(Will-Supply|Unfilled))).*'))";

open( OUTF, '>', $filename) or die "cannot open > $filename: $!";
print OUTF "YEARLY\n------\n";
period('year');
print OUTF "\n\nMONTHLY\n-------\n";
period('month');
print OUTF "\n\nWEEKLY\n------\n";
period('week');
print OUTF "\n\n---current long-format date time goes here---\n";
print OUTF "$rid\t$lid\t$range_start\t$range_end\t$filename\t$submitted\n";
close OUTF;

$dbh->disconnect;
exit;

sub period {
    my $interval = shift;

    my $a_borrow = $dbh->selectall_arrayref($SQL_borrow_active,undef,$interval,$lid,$range_start,$range_end);
    my $a_lend = $dbh->selectall_arrayref($SQL_lend_active,undef,$interval,$lid,$range_start,$range_end);
    my $h_borrow = $dbh->selectall_arrayref($SQL_borrow_history,undef,$interval,$lid,$range_start,$range_end);
    my $h_lend = $dbh->selectall_arrayref($SQL_lend_history,undef,$interval,$lid,$range_start,$range_end);

    print OUTF "BORROWING\n";
    print OUTF "Active:\n";
    print_stats($a_borrow);
    print OUTF "History:\n";
    print_stats($h_borrow);
    print OUTF "\n";
    print OUTF "LENDING\n";
    print OUTF "Active:\n";
    print_stats($a_lend);
    print OUTF "History:\n";
    print_stats($h_lend);
}

sub print_stats {
    my $aref = shift;
    foreach my $ary (@$aref) {
	foreach my $elm (@$ary) {
	    print OUTF "$elm\t";
	}
	print OUTF "\n";
    }
}
