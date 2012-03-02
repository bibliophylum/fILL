#!/usr/bin/perl -w
##
##  CGI-Application admin
##
use strict;
#use lib qw(.);
use lib "/opt/fILL/modules";
use fILL::admin;
my $app = fILL::admin->new();
$app->run();
