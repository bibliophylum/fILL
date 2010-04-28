#!/usr/bin/perl -w
##
##  CGI-Application vendortest
##
use strict;
#use lib qw(.);
use lib "/opt/maplin3/modules";
use vendortest;
my $v = vendortest->new();
$v->run();
