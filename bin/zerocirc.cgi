#!/usr/bin/perl -w
##
##  CGI-Application zerocirc
##
use strict;
#use lib qw(.);
use lib "/opt/maplin3/modules";
use maplin3::zerocirc;
my $app = maplin3::zerocirc->new();
$app->run();
