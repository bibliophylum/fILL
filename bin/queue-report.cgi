#!/usr/bin/perl

use CGI;
use JSON;
use Net::Telnet;

my $query = new CGI;

# send to the reporter to queue and handle
my $obj = new Net::Telnet( Host => 'localhost',
			   Port => '20204',
#			   Dump_Log => '/opt/fILL/logs/telnet.log',
    );
my $ok = $obj->print( to_json( { rid => $query->param('rid'), 
				 lid => $query->param('lid'),
				 range_start => $query->param('start'),
				 range_end => $query->param('end')
			       } ));
my $response = $obj->getline();  # wait for a response....
$obj->close;
chomp $response;

print "Content-Type:application/json\n\n" . $response;
