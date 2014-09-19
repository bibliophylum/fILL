#!/usr/bin/perl -w
#
# fILL chat-server.pl
#
#    fILL - Free/Open-Source Interlibrary Loan management system
#    Copyright (C) 2012  Government of Manitoba
#
#    chat-server.pl is a part of fILL.
#
#    fILL is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    fILL is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# daemonization based on
# mydaemon.pl by Andrew Ault, www.andrewault.net
#
#
use strict;
use warnings;
use POSIX;
use File::Pid;
use Net::WebSocket::Server;
use JSON;
use Data::Dumper;
 
# make "chat-server.pl.log" file in /var/log/ with "chown root:adm chat-server.pl"
 
# TODO: change "mydaemon" to the exact name of your daemon.
my $daemonName    = "chat-server.pl";
#
my $dieNow        = 0;                                     # used for "infinte loop" construct - allows daemon mode to gracefully exit
my $sleepMainLoop = 120;                                    # number of seconds to wait between "do something" execution after queue is clear
my $logging       = 1;                                     # 1= logging is on
#my $logFilePath   = "/var/log/";                           # log file path
my $logFilePath   = "/opt/fILL/logs/";                     # log file path
my $logFile       = $logFilePath . $daemonName . ".log";
my $pidFilePath   = "/var/run/";                           # PID file path
my $pidFile       = $pidFilePath . $daemonName . ".pid";
 
# daemonize
use POSIX qw(setsid);
chdir '/';
umask 0;
open STDIN,  '/dev/null'   or die "Can't read /dev/null: $!";
open STDOUT, '>>/dev/null' or die "Can't write to /dev/null: $!";
open STDERR, '>>/dev/null' or die "Can't write to /dev/null: $!";
defined( my $pid = fork ) or die "Can't fork: $!";
exit if $pid;
 
# dissociate this process from the controlling terminal that started it and stop being part
# of whatever process group this process was a part of.
POSIX::setsid() or die "Can't start a new session.";
 
# callback signal handler for signals.
$SIG{INT} = $SIG{TERM} = $SIG{HUP} = \&signalHandler;
$SIG{PIPE} = 'ignore';
 
# create pid file in /var/run/
my $pidfile = File::Pid->new( { file => $pidFile, } );
 
$pidfile->write or die "Can't write PID file, /dev/null: $!";
 
# turn on logging
if ($logging) {
	open LOG, ">>$logFile";
	select((select(LOG), $|=1)[0]); # make the log file "hot" - turn off buffering
}
 
# "infinite" loop where some useful process happens
#until ($dieNow) {
#	sleep($sleepMainLoop);
# 
#	# TODO: put your custom code here!
#	# do something
# 
#	# logEntry("log something"); # use this to log whatever you need to
#}
 
#--- the actual server code -------------------------------------------------
my %channels = ();
my $maxHistory = 20;
my %history = ();

Net::WebSocket::Server->new(
    listen => 8088,
    on_connect => sub {
        my ($serv, $conn) = @_;
        $conn->on(
            utf8 => sub {
                my ($conn, $msg) = @_;

		print LOG "$msg\n";
		my $hrefFromClient = decode_json $msg;

		my $channel = $hrefFromClient->{'channel'};
		my $user = $hrefFromClient->{'name'};
		my $lid  = $hrefFromClient->{'lid'};

		# Add to known connections for this channel,
		# if it's not already there.
		# This will autovivify $channels{$channel}, which is good.
		unless (exists $channels{$channel}{$user}{"conn"}) {
		    $channels{$channel}{$user}{"conn"} = $conn;
		    $channels{$channel}{$user}{"lid"} = $lid;

		    # new member will need to see history...
		    foreach my $histMsg (@{ $history{$channel} }) {
			$channels{$channel}{$user}{"conn"}->send_utf8( $histMsg );
		    }

		    unless ($channel eq "syschan") {
			# find the connection for that library id
			my $libconn;
			foreach my $u (keys %{$channels{"syschan"}}) {
			    next if ($u eq $user); # skip if we're the library
			    if ($channels{"syschan"}{$u}{"lid"} == $lid) {

				$libconn = $channels{"syschan"}{$u}{"conn"};

				# notify library that user is opening a chat:
				# send a system message to library on syschan,
				# (library will create new connection)
				my %hash = ( 
				    'type' => 'system',
				    'message' => $channel,
				    'name' => $user
				    );
				$libconn->send_utf8( encode_json \%hash );

				last; # remove this if there are more than 1 user per lib
			    }
			}
		    }
		}

		# turn the incomming message into an outgoing message
		my $href = { 
		    'type' => 'usermsg',
		    'name' => $user,
                    'lid' => $lid,
		    'message' => $hrefFromClient->{'message'},
		    'color' => $hrefFromClient->{'color'}
		};
		my $outgoing_msg = encode_json $href;

		# add to history
		push @{ $history{$channel} }, $outgoing_msg;
		shift @{ $history{$channel} } if (scalar(@{ $history{$channel} }) > $maxHistory);

		# send the message to everyone in the channel
		foreach my $uid (keys %{$channels{$channel}} ) {
		    $channels{$channel}{$uid}{"conn"}->send_utf8( $outgoing_msg );
		}

#		# test "system" messages....
#		my %hash = ( 
#		    'type' => 'system',
#		    'message' => 'System: your message has been sent.'
#		    );
#		# just back to the originator.
#               $channels{$channel}{$user}{"conn"}->send_utf8( encode_json \%hash );
            },
        );
    },
)->start;

#------------------------------------------------------------------------------

# add a line to the log file
sub logEntry {
	my ($logText) = @_;
	my ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) = localtime(time);
	my $dateTime = sprintf "%4d-%02d-%02d %02d:%02d:%02d", $year + 1900, $mon + 1, $mday, $hour, $min, $sec;
	if ($logging) {
		print LOG "$dateTime $logText\n";
	}
}
 
# catch signals and end the program if one is caught.
sub signalHandler {
	$dieNow = 1;    # this will cause the "infinite loop" to exit
}
 
# do this stuff when exit() is called.
END {
	if ($logging) { close LOG }
	$pidfile->remove if defined $pidfile;
}
