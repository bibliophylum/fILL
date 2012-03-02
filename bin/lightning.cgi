#!/usr/bin/perl -w
##
##  CGI-Application lightning
##
use strict;
#use lib qw(.);
use lib "/opt/fILL/modules";
use fILL::lightning;
my $lightning = fILL::lightning->new();
$lightning->run();
