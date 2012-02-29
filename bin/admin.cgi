#!/usr/bin/perl -w
##
##  CGI-Application admin
##
use strict;
#use lib qw(.);
use lib "/opt/fILL/modules";
use maplin3::admin;
my $app = maplin3::admin->new();
$app->run();
