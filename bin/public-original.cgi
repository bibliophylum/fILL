#!/usr/bin/perl -w
##
##  CGI-Application public-original
##
use strict;
#use lib qw(.);
use lib "/opt/fILL/modules";
use fILL::public_original;
my $public = fILL::public_original->new();
$public->run();
