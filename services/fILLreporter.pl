#!/usr/bin/perl -w
package fILLreporter;

use strict;
use base qw(Net::Server::Fork); # any personality will do

# To run this in background daemon mode, do:
# fILLreporter.pl --setsid=1
#
# To turn off the daemon, do:
# kill `cat /var/run/fILLreporter.pid`

__PACKAGE__->run({ conf_file => '/opt/fILL/conf/fILLreporter.conf',
		 });
exit;

### over-ridden subs below

sub process_request {
    my $self = shift;
    eval {
	
	local $SIG{'ALRM'} = sub { die "Timed Out!\n" };
	my $timeout = 30; # give the user 30 seconds to type some lines
	
	my $previous_alarm = alarm($timeout);
	while (<STDIN>) {
	    s/\r?\n$//;
	    print "You said '$_'\r\n";
	    alarm($timeout);
	}
	alarm($previous_alarm);
	
    };
    
    if ($@ =~ /timed out/i) {
	print STDOUT "Timed Out.\r\n";
	return;
    }
    
}

1;
