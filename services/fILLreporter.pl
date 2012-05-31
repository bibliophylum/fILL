#!/usr/bin/perl -w
package fILLreporter;

# To run this in background daemon mode, do:
# fILLreporter.pl --setsid=1
#
# To turn off the daemon, do:
# kill `cat /var/run/fILLreporter.pid`

use strict;
use base qw(Net::Server::Fork); # any personality will do
use JSON;
use DBI;
use Data::Dumper;

# sql to add to the report queue
my $SQL_enqueue = "insert into reports_queue (rid, lid, range_start, range_end) values (?,?,?,?)";

# Because, once a given library (lid) queues a report (rid) for a particular date range, that button is disabled, the following should be unique enough for our purposes.  If not, we'll clean this up later.
my $SQL_getTimestamp = "select ts from reports_queue where rid=? and lid=? and range_start=? and range_end=?";

my $SQL_getReportDetails = "select rtype, name, description, generator from reports where rid=?";

my $SQL_dequeue = "delete from reports_queue where ts=? and rid=? and lid=? and range_start=? and range_end=?";
my $SQL_complete = "insert into reports_complete (rid, lid, range_start, range_end, report_file) values (?,?,?,?,?)";


__PACKAGE__->run({ conf_file => '/opt/fILL/conf/fILLreporter.conf',
		 });
exit;

### over-ridden subs below

sub process_request {
    my $self = shift;
    eval {
	
	local $SIG{'ALRM'} = sub { die "Timed Out!\n" };
	my $timeout = 30; # give queue-report.cgi 30 secs to send us something

	my $json = JSON->new->allow_nonref;
	my $previous_alarm = alarm($timeout);
	while (<STDIN>) {
	    my $notice = $json->decode( $_ );
	    $self->log(4, "received: " . Dumper($notice));
	    my $dbh = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
				   "mapapp",
				   "maplin3db",
				   {AutoCommit => 1, 
				    RaiseError => 1, 
				    PrintError => 0,
				   }
		) or die $DBI::errstr;

	    my $retval = $dbh->do( $SQL_enqueue, undef, 
				   $notice->{rid}, 
				   $notice->{lid}, 
				   $notice->{range_start}, 
				   $notice->{range_end}
		);
	    # tell queue-report.cgi, so it can hang up.
	    print STDOUT to_json( { success => $retval } ) . "\n";
	    $self->log(4, "{ success => $retval }");
	    alarm($timeout);

	    my $ts = $dbh->selectrow_hashref( $SQL_getTimestamp, undef, 
					      $notice->{rid},
					      $notice->{lid}, 
					      $notice->{range_start}, 
					      $notice->{range_end}
		);
	    my $report = $dbh->selectrow_hashref( $SQL_getReportDetails, undef, $notice->{rid});
	    $self->log(4, Dumper($report));

	    # create a unique filename
#	    my $reportsdir = "/opt/fILL/htdocs/reports/"; # this would be visible in browser....
	    my $reportsdir = "/opt/fILL/report-output/"; 
	    my $filename = $ts->{ts} . $$;
	    $filename =~ s/\D//g;
	    $filename .= '.txt';
	    # hand off to the individual report generator
	    my @args = ("/opt/fILL/services/reports/" . $report->{generator} . ".pl",
			'--rid', $notice->{rid},
			'--lid', $notice->{lid},
			'--range_start', $notice->{range_start},
			'--range_end',   $notice->{range_end},
			'--filename',    "$reportsdir$filename",
			'--submitted',   $ts->{ts}
		);
	    $self->log(4, "calling " . $report->{generator});
	    system(@args) == 0 or die "calling $report failed: $?";

	    $retval = $dbh->do( $SQL_dequeue, undef,
				$ts->{ts},
				$notice->{rid}, 
				$notice->{lid}, 
				$notice->{range_start}, 
				$notice->{range_end}
		);
	    $retval = $dbh->do( $SQL_complete, undef, 
				$notice->{rid}, 
				$notice->{lid}, 
				$notice->{range_start}, 
				$notice->{range_end},
				$filename
		);
	    
	    $dbh->disconnect;
	}
	
	alarm($previous_alarm);
	
    };
    
    if ($@ =~ /timed out/i) {
	print STDOUT to_json( { success => 0, message => "Timed Out." } ) . "\n";
	return;
    }
    
}

1;
