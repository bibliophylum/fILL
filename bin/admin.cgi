#!/usr/bin/perl -w
##
##  CGI-Application public
##
use strict;
#use lib qw(.);
use lib "/opt/fILL/modules";
use fILL::admin;
my $admin = fILL::admin->new();
$admin->run();
