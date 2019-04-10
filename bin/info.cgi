#!/usr/bin/perl -w
##
##  CGI-Application info
##
use strict;
#use lib qw(.);
use lib "/opt/fILL/modules";
use lib "/opt/fILL/modules/fILL-stats/lib";
use lib "/opt/fILL/modules/fILL-charts/lib";
use fILL::info;
my $app = fILL::info->new();
$app->run();
