#!/usr/bin/perl
use strict;
use warnings;

use CGI;
use CGI::Session;
use DBI;
use fILL::stats;
#use fILL::charts;
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
exit unless $oid;

my @months = qw( January February March April May June July August September October November December );

my ($earliestYear,$earliestMonth,$latestYear,$latestMonth) = get_bounds($oid);

my @allStats;

for my $y ($earliestYear .. $latestYear) {
    my $mstart = ($y == $earliestYear) ? $earliestMonth : 1;
    my $mend = ($y == $latestYear) ? $latestMonth : 12;
    for my $m ($mstart .. $mend) {
	#print STDERR "$y:$m\n";
	my $s = fILL::stats->new('oid' => $oid, 'year' => $y, 'month' => $m);
	my $stats = $s->get_stats();
	$stats->{month_name} = $months[$m - 1];
	$stats->{borrowing}{value} = $stats->{borrowing}{we_received}{total} * 25.00;

	# build our array to pass to HTML::Template
	my $repdata = {};
	$repdata->{year} = $y;
	$repdata->{monthnum} = $m;
	$repdata->{month} = $months[$m - 1];
	$repdata->{books_requested} = $stats->{borrowing}{requests}{books_requested}{total};
	$repdata->{requests_made} = $stats->{borrowing}{requests}{requests_made};
	$repdata->{responded_unfilled} = $stats->{borrowing}{responded_unfilled}{total};
	$repdata->{lender_shipped} = $stats->{borrowing}{lender_shipped}{total};
	$repdata->{we_cancelled} = $stats->{borrowing}{we_cancelled}{total};

	$repdata->{requests_to_lend} = $stats->{lending}{requests_to_lend}{total};
	$repdata->{could_not_fill} = $stats->{lending}{responded_unfilled}{total};
	$repdata->{shipped} = $stats->{lending}{shipped}{total};
	$repdata->{forward_to_branch} = $stats->{lending}{forward_to_branch}{total};
	$repdata->{borrower_cancelled} = $stats->{lending}{borrower_cancelled}{total};

	push @allStats, $repdata;

    }
}




#print Dumper($stats);
print "Content-Type:application/json\n\n" . to_json( { report => \@allStats } );


#---------------------------------------------------------------------------
sub get_bounds {
    my $oid = shift;

    my $dbh = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
			   "mapapp",
			   "maplin3db",
			   {AutoCommit => 1, 
			    RaiseError => 1, 
			    PrintError => 0,
			   }
	) or die $DBI::errstr;

    my $SQL = "select date_part('YEAR',ts) as year, date_part('MONTH',ts) as month from requests_history where ((msg_from = ?) or (msg_to = ?)) order by ts limit 1";
    my $href = $dbh->selectrow_hashref($SQL, undef, $oid, $oid);

    my $earliestYear;
    my $earliestMonth;
    if ($href) {
	$earliestYear = $href->{"year"};
	$earliestMonth = $href->{"month"};
    }

    $SQL = "select date_part('YEAR',ts) as year, date_part('MONTH',ts) as month from requests_history where ((msg_from = ?) or (msg_to = ?)) order by ts desc limit 1";
    $href = $dbh->selectrow_hashref($SQL, undef, $oid, $oid);

    my $latestYear;
    my $latestMonth;
    if ($href) {
	$latestYear = $href->{"year"};
	$latestMonth = $href->{"month"};
    }

    $dbh->disconnect;
    return ($earliestYear, $earliestMonth, $latestYear, $latestMonth);
}
