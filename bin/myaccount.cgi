#!/usr/bin/perl -w
##
##  CGI-Application admin
##
use strict;
#use lib qw(.);
use lib "/opt/fILL/modules";
use fILL::myaccount;
my $app = fILL::myaccount->new();
$app->run();
