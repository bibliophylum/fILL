#!/usr/bin/perl -w
##
##  CGI-Application "public"
##
use strict;
#use lib qw(.);
use lib "/opt/maplin3/modules";
use maplin3::public;
my $maplin3 = maplin3::public->new();
$maplin3->run();
