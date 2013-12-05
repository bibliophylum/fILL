#!/usr/bin/perl -w
##
##  CGI-Application rotations
##
use strict;
#use lib qw(.);
use lib "/opt/fILL/modules";
use fILL::rotations;
my $app = fILL::rotations->new();
$app->run();
