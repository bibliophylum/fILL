#!/usr/bin/perl
use strict;
use warnings;

use CGI;
use CGI::Session;
use JSON;
use File::Copy;
#use Data::Dumper;

my $query = new CGI;
my $session = CGI::Session->load(undef, $query, {Directory=>"/tmp"});
if (($session->is_expired) || ($session->is_empty)) {
    print "Content-Type:application/json\n\n" . to_json( { success => 0, message => 'invalid session' } );
    exit;
}

# touch /tmp/pazpar-restart-requested file
open(FH,'>','/tmp/pazpar-restart-requested');
print FH $$;
close FH;
my $retval = utime(undef, undef, '/tmp/pazpar-restart-requested');

print "Content-Type:application/json\n\n" . to_json( { success => $retval } );
