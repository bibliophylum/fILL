#!/usr/bin/perl -w
##
##  CGI-Application info
##
use strict;
#use lib qw(.);
use lib "/opt/maplin3/modules";
use maplin3::supplemental;
my $app = maplin3::supplemental->new();
$app->run();
