#!/usr/bin/perl -w
#
# mydaemon.pl by Andrew Ault, www.andrewault.net
#
# Free software. Use this as you wish.
#
# Throughout this template "mydaemon" is used where the name of your daemon should
# be, replace occurrences of "mydaemon" with the name of your daemon.
#
# This name will also be the exact name to give this file (WITHOUT a ".pl" extension).
#
# It is also the exact name to give the start-stop script that will go into the
# /etc/init.d/ directory.
#
# It is also the name of the log file in the /var/log/ directory WITH a ".log"
# file extension.
#
# Replace "# do something" with your super useful code.
#
# Use "# logEntry("log something");" to log whatever your need to see in the log.
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
my $logFilePath   = "/var/log/";                           # log file path
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
my %rooms = ();
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

		my $room = $hrefFromClient->{'room'};
		my $user = $hrefFromClient->{'name'};

		# Add to known connections for this room,
		# if it's not already there.
		# This will autovivify $rooms{$room}, which is good.
		unless (exists $rooms{$room}{$user}) {
		    $rooms{$room}{$user} = $conn;

		    # new member will need to see history...
		    foreach my $histMsg (@{ $history{$room} }) {
			$rooms{$room}{$user}->send_utf8( $histMsg );
		    }
		}

		# turn the incomming message into an outgoing message
		my $href = { 
		    'type' => 'usermsg',
		    'name' => $user,
		    'message' => $hrefFromClient->{'message'},
		    'color' => $hrefFromClient->{'color'}
		};
		my $outgoing_msg = encode_json $href;

		# add to history
		push @{ $history{$room} }, $outgoing_msg;
		shift @{ $history{$room} } if (scalar(@{ $history{$room} }) > $maxHistory);

		# send the message to everyone in the room
		foreach my $uid (keys %{$rooms{$room}} ) {
		    $rooms{$room}{$uid}->send_utf8( $outgoing_msg );
		}

#		# test "system" messages....
#		my %hash = ( 
#		    'type' => 'system',
#		    'message' => 'System: your message has been sent.'
#		    );
#		# just back to the originator.
#               $rooms{$room}{$user}->send_utf8( encode_json \%hash );
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
