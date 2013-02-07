#!/usr/bin/perl -w
##
##  CGI-Application patrons
##
use strict;
use lib "/opt/fILL/modules";
use fILL::patrons;
my $app = fILL::patrons->new();
$app->run();
