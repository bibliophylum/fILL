#!/usr/bin/perl -w
##
##  CGI-Application info
##
use strict;
#use lib qw(.);
use lib "/opt/fILL/modules";
use fILL::training;
my $app = fILL::training->new();
$app->run();
