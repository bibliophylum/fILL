#!/usr/bin/perl -w
##
##  CGI-Application myaccount
##
use strict;
use lib "/opt/fILL/modules";
use fILL::myaccount;
my $app = fILL::myaccount->new();
$app->run();
