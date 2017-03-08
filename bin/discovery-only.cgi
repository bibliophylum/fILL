#!/usr/bin/perl -w
##
##  CGI-Application discovery-only
##
use strict;
#use lib qw(.);
use lib "/opt/fILL/modules";
use fILL::discovery_only;
my $discoveryOnly = fILL::discovery_only->new();
$discoveryOnly->run();
