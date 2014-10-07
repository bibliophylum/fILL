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
my $DEBUG = 0;
my %channels = ();
my $maxHistory = 20;
my %history = ();
my @colors = ("7FFF00","0000FF","A52A2A","FFD700","F08080","556B2F","FF8C00","9932CC","9ACD32","EE82EE");

Net::WebSocket::Server->new(
    listen => 8088,
    on_connect => sub {
        my ($serv, $conn) = @_;
	print LOG "on_connect\n";
        $conn->on(
	    handshake => sub {
		my ($handshake) = @_;
		print LOG "handshake\n" . Dumper($handshake) . "\n-----------\n" if ($DEBUG);
	    },
	    ready => sub {
		print LOG "ready\n-----------\n";
	    },
	    disconnect => sub {
		my ($code, $reason) = @_;
		print LOG "disconnect code\n" . Dumper($code) . "\nreason [$reason]\n-----------\n" if ($DEBUG);

		# remove connection from all channels
		my @del = ();
		foreach my $channel (keys %channels) {
		    foreach my $user (keys %{$channels{$channel}}) {
			if ($channels{$channel}{$user}{"conn"} == $conn) {
			    push @del, [ $channel, $user ];
			}
		    }
		}

		foreach my $cu (@del) {
		    print LOG "deleting " . $cu->[1] . " from " . $cu->[0] . "\n";
		    my $lid = $channels{$cu->[0]}{$cu->[1]}{"lid"};

		    if ($cu->[0] eq "syschan") {
			# return that color to the pool
			push @colors, $channels{"syschan"}{$cu->[1]}{"color"};

			# library leaving syschan message
			my $href = { 
			    'type' => 'usermsg',
			    'name' => $cu->[1],
			    'lid' => $lid,
			    'message' => "has left the conversation.",
			    'color' => "#A4A4A4"
			};
			my $outgoing_msg = encode_json $href;
			
			# add to history
			print LOG "add " . $cu->[1] . " leaving message to history\n";
			push @{ $history{"syschan"} }, $outgoing_msg;
			shift @{ $history{"syschan"} } if (scalar(@{ $history{"syschan"} }) > $maxHistory);
			
			# send the message to everyone (else) in the channel
			print LOG "tell syschan that " . $cu->[1] . " has left\n";
			foreach my $uid (keys %{$channels{"syschan"}} ) {
			    if ($uid ne $cu->[1]) {  # not safe to send to disconnected user
				$channels{"syschan"}{$uid}{"conn"}->send_utf8( $outgoing_msg );
			    }
			}
		    }

		    delete $channels{$cu->[0]}{$cu->[1]};

		    my $count = keys %{$channels{$cu->[0]}}; # keys evaluated in scalar context == count of keys
		    if (($cu->[0] ne "syschan") && ($count < 2)) {
			my @remaining_user = keys %{$channels{$cu->[0]}};
			my $lib = $remaining_user[0];
			# notify library that user has closed chat:
			# send a system message to library on syschan
			print LOG "informing $lib that " . $cu->[1] . " has left " . $cu->[0] . "\n";
			my %hash = ( 
			    'type' => 'close',
			    'message' => $cu->[0],
			    'name' => $cu->[1]
			    );
			$channels{$cu->[0]}{$lib}{"conn"}->send_utf8( encode_json \%hash );

			print LOG "deleting " . $lib . " from " . $cu->[0] . "\n";
			delete $channels{$cu->[0]}{$lib};
			delete $channels{$cu->[0]};
			delete $history{$cu->[0]};

		    }
		}

	    },
	    pong => sub {
		my ($message) = @_;
		print LOG "pong message\n" . Dumper($message) . "\n-----------\n" if ($DEBUG);
	    },

            utf8 => sub {
                my ($conn, $msg) = @_;
		print LOG "utf8\n";

		print LOG "$msg\n";
		my $hrefFromClient = decode_json $msg;

		my $channel = $hrefFromClient->{'channel'};
		my $user = $hrefFromClient->{'name'};
		my $lid  = $hrefFromClient->{'lid'};

		print LOG "add $user to $channel\n";

		# Add to known connections for this channel,
		# if it's not already there.
		# This will autovivify $channels{$channel}, which is good.
		unless (exists $channels{$channel}{$user}{"conn"}) {
		    $channels{$channel}{$user}{"conn"} = $conn;
		    $channels{$channel}{$user}{"lid"} = $lid;
		    if ($channel eq "syschan") {
			if (scalar @colors) {
			    $channels{"syschan"}{$user}{"color"} = shift @colors;
			} else {
			    $channels{"syschan"}{$user}{"color"} = "000000";
			}
		    } else {
			my $count = keys %{$channels{$channel}}; # keys evaluated in scalar context == count of keys
			if ($count == 1) {
			    $channels{$channel}{$user}{"color"} = "000000";
			} else {
			    $channels{$channel}{$user}{"color"} = "7FFF00";
			}
		    }
		    print LOG "set $user color\n";
		    my $href = { 'type' => 'color','name' => $user,'lid' => $lid,
				 'message' => "set color", 
				 'color' => $channels{$channel}{$user}{'color'}
		    };
		    my $outgoing_msg = encode_json $href;
		    $channels{$channel}{$user}{"conn"}->send_utf8( $outgoing_msg );



		    # new member will need to see history...
		    foreach my $histMsg (@{ $history{$channel} }) {
			$channels{$channel}{$user}{"conn"}->send_utf8( $histMsg );
		    }

		    my $count = keys %{$channels{$channel}}; # keys evaluated in scalar context == count of keys
		    if (($channel ne "syschan") && ($count < 2)) {
			# we need to figure out who the user's library is, and tell that library to
			# connect to this new channel, too.

			# find the connection for that library id
			my $libconn;
			foreach my $u (keys %{$channels{"syschan"}}) {
			    next if ($u eq $user); # skip if we're the library
			    if ($channels{"syschan"}{$u}{"lid"} == $lid) {

				$libconn = $channels{"syschan"}{$u}{"conn"};

				# notify library that user is opening a chat:
				# send a system message to library on syschan,
				# (library will create new connection)
				print LOG "asking $u to join $channel\n";
				my %hash = ( 
				    'type' => 'open',
				    'message' => $channel,
				    'name' => $user
				    );
				$libconn->send_utf8( encode_json \%hash );

				last; # remove this if there are more than 1 user per lib
			    }
			}
		    }
		}

		# turn the incomming message into an outgoing messag
		my $href = { 
		    'type' => 'usermsg',
		    'name' => $user,
                    'lid' => $lid,
		    'message' => $hrefFromClient->{'message'},
#		    'color' => $hrefFromClient->{'color'}
		    'color' => $channels{$channel}{$user}{'color'}
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

		print LOG "\n-----------\n" if ($DEBUG);
            },
        );
    },
    on_shutdown => sub {
	print LOG "shutting down\n";
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
