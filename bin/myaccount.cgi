#!/usr/bin/perl -w
##
##  CGI-Application admin
##
use strict;
#use lib qw(.);
use lib "/opt/fILL/modules";
use maplin3::myaccount;
my $app = maplin3::myaccount->new();
$app->run();
