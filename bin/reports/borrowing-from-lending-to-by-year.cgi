#!/usr/bin/perl
use strict;
use warnings;

use CGI;
use CGI::Session;
use DBI;
use JSON;
#use Data::Dumper;

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
my $mtype = $query->param('mtype');

exit unless $oid;
exit unless $year;

if ($month) { $month = sprintf("%02d",$month); }

my $dbh = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
                       "mapapp",
                       "maplin3db",
                       {AutoCommit => 1, 
                        RaiseError => 1, 
                        PrintError => 0,
                       }
    ) or die $DBI::errstr;

$dbh->do("SET TIMEZONE='America/Winnipeg'");

my $aryref;
my %Stats;

#my $period = ($month) ? "YYYY-MM" : "YYYY";
#my $dateRange = ($month) ? "$year-$month" : $year;
my $period;
my $dateSelect;
my $dateRange;
if ($mtype eq "all") {
    $period = "YYYY-MM";
    $dateSelect = "YYYY";
    $dateRange = $year;
} elsif ($mtype eq "one") {
    $period = "YYYY-MM";
    $dateSelect = "YYYY-MM";
    $dateRange = "$year-$month";
} else {
    # $mtype eq "none" - year summary, no month breakdown
    $period = "YYYY";
    $dateSelect = "YYYY";
    $dateRange = $year;
}

# Borrowing
# Note: counting stats for items shipped within the period
foreach my $tbl (qw/active history/) {
    my $req_tbl = ($tbl eq 'active') ? "requests_active" : "requests_history";

    my $SQL = "select to_char(t.ts, '" . $period . "') as period, o.org_name, count(t.request_id) as borrowed_from from " . $req_tbl . " t left join org o on o.oid=t.msg_from where t.msg_to=? and t.status='Shipped' and to_char(t.ts, '" . $dateSelect . "')='" . $dateRange . "' group by period, org_name order by period, org_name";

    $aryref = $dbh->selectall_arrayref($SQL, { Slice => {} }, $oid);

    foreach my $row (@$aryref) {
	$Stats{ $row->{period} }{ $row->{org_name} }{we_borrowed} = 0 unless (exists $Stats{ $row->{period} }{ $row->{org_name} }{we_borrowerd});
	$Stats{ $row->{period} }{ $row->{org_name} }{we_borrowed} += $row->{borrowed_from};
    }
}

# Lending
# Counting stats for items shipped within the period
foreach my $tbl (qw/active history/) {  
    my $req_tbl = ($tbl eq 'active') ? "requests_active" : "requests_history";

    $aryref = $dbh->selectall_arrayref("select to_char(t.ts, '" . $period . "') as period, o.org_name, count(t.request_id) as loaned_to from $req_tbl t left join org o on o.oid=t.msg_to where t.msg_from=? and t.status='Shipped' and to_char(t.ts, '" . $dateSelect . "')='" . $dateRange . "' group by period, org_name order by period, org_name", { Slice => {} }, $oid);

    foreach my $row (@$aryref) {
	$Stats{ $row->{period} }{ $row->{org_name} }{we_loaned} = 0 unless (exists $Stats{ $row->{period} }{ $row->{org_name} }{we_loaned});
	$Stats{ $row->{period} }{ $row->{org_name} }{we_loaned} += $row->{loaned_to};
    }
}

$dbh->disconnect;

#print Dumper(%Stats);

my @allStats;
foreach my $period (sort keys %Stats) {
    my $href = $Stats{$period};
    foreach my $org_name (sort keys %{$href}) {
	$href->{$org_name}{period} = $period;
	$href->{$org_name}{org_name} = $org_name;
	$href->{$org_name}{we_borrowed} = 0 unless $href->{$org_name}{we_borrowed};
	$href->{$org_name}{we_loaned} = 0 unless $href->{$org_name}{we_loaned};
	push @allStats, $href->{$org_name};
    }
}
#    print STDERR Dumper(@allStats);

print "Content-Type:application/json\n\n" . to_json( { report => [ @allStats ] } );
