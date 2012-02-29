#!/usr/bin/perl -w
##
##  CGI-Application maplin3
##
use strict;
#use lib qw(.);
use lib "/opt/fILL/modules";
use maplin3::lightning;
my $maplin3 = maplin3::lightning->new();
$maplin3->run();
