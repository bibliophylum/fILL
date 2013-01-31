#!/usr/bin/perl -w
##
##  CGI-Application public
##
use strict;
#use lib qw(.);
use lib "/opt/fILL/modules";
use fILL::public;
my $public = fILL::public->new();
$public->run();
