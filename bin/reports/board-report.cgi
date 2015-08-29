#!/usr/bin/perl
use strict;
use warnings;

use CGI;
use CGI::Session;
#use DBI;
use fILL::stats;
use fILL::charts;
use JSON;
use Data::Dumper;

my $query = new CGI;
my $session;
if (($ENV{GATEWAY_INTERFACE}) && ($ENV{GATEWAY_INTERFACE} =~ /CGI/)) {  # only worry about session if we're a cgi
    $session = CGI::Session->load(undef, $query, {Directory=>"/tmp"});
    if (($session->is_expired) || ($session->is_empty)) {
        print "Content-Type:application/json\n\n" . to_json( { success => 0, message => 'invalid session' } );
        exit;
    }
}

my $oid = $query->param('oid');
my $year = $query->param('year');
my $month = $query->param('month');

exit unless $oid;
exit unless $year;
exit unless $month;

my @months = qw( January February March April May June July August September October November December );
my $month_name = $months[$month-1];

if ($month) { $month = sprintf("%02d",$month); }

my $s = fILL::stats->new('oid' => $oid, 'year' => $year, 'month' => $month);
my $stats = $s->get_stats();
$stats->{month_name} = $month_name;

my $charts = fILL::charts->new('stats' => $stats);
$charts->create_report(); # create the charts
$stats->{charts}{borrowing} = $charts->get_borrowing_chart();
$stats->{charts}{lending}   = $charts->get_lending_chart();

my $sPrev = fILL::stats->new('oid' => $oid, 'year' => ($year - 1), 'month' => $month);
my $statsPrev = $sPrev->get_stats();
my $borrowingChange = undef;
if ((exists $statsPrev->{borrowing}{requests}{books_requested}{total})
    && ($statsPrev->{borrowing}{requests}{books_requested}{total} > 0)) {
    my $bc = ($stats->{borrowing}{requests}{books_requested}{total} - $statsPrev->{borrowing}{requests}{books_requested}{total}) / $statsPrev->{borrowing}{requests}{books_requested}{total} * 100.0;
    if ($bc > 0.0) {
	$borrowingChange = sprintf("%.0f%% increase ",$bc);
    } else {
	$borrowingChange = sprintf("%.0f%% decrease ",-$bc);
    }
}
$stats->{borrowing}{change_over_previous_year} = $borrowingChange;


my $lendingRequestsChange = undef;
if ((exists $statsPrev->{lending}{requests_to_lend}{total})
    && ($statsPrev->{lending}{requests_to_lend}{total} > 0)) {
    my $lch = ($stats->{lending}{requests_to_lend}{total} - $statsPrev->{lending}{requests_to_lend}{total}) / $statsPrev->{lending}{requests_to_lend}{total} * 100.0;
    if ($lch > 0.0) {
	$lendingRequestsChange = sprintf("%.0f%% increase ",$lch);
    } else {
	$lendingRequestsChange = sprintf("%.0f%% decrease ",-$lch);
    }
}
$stats->{lending}{change_over_previous_year}{requests} = $lendingRequestsChange;

my $lendingShippedChange = undef;
if ((exists $statsPrev->{lending}{shipped}{total})
    && ($statsPrev->{lending}{shipped}{total} > 0)) {
    my $lch = ($stats->{lending}{shipped}{total} - $statsPrev->{lending}{shipped}{total}) / $statsPrev->{lending}{shipped}{total} * 100.0;
    if ($lch > 0.0) {
	$lendingShippedChange = sprintf("%.0f%% increase ",$lch);
    } else {
	$lendingShippedChange = sprintf("%.0f%% decrease ",-$lch);
    }
}
$stats->{lending}{change_over_previous_year}{shipped} = $lendingShippedChange;

my @borrowingTypes;
my $bt = $stats->{borrowing}{requests}{books_requested}{type};
foreach my $key (sort keys %{$bt}) {
    push @borrowingTypes, { 'type' => $key, 'count' => $bt->{$key} };
}

$stats->{borrowing}{value} = $stats->{borrowing}{we_received}{total} * 25.00;

#print Dumper($stats);
print "Content-Type:application/json\n\n" . to_json( { report => {%$stats} } );
