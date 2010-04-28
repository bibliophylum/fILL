#!/usr/bin/perl -w
##
##  CGI-Application patrons
##
use strict;
#use lib qw(.);
use lib "/opt/maplin3/modules";
use maplin3::patrons;
my $app = maplin3::patrons->new();
$app->run();
