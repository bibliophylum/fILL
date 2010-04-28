#!/usr/bin/perl -w
##
##  CGI-Application admin
##
use strict;
#use lib qw(.);
use lib "/opt/maplin3/modules";
use maplin3::myaccount;
my $app = maplin3::myaccount->new();
$app->run();
