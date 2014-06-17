#!/usr/bin/perl -w
##
##  CGI-Application rotations_admin
##
use strict;
#use lib qw(.);
use lib "/opt/fILL/modules";
use fILL::rotations_admin;
my $app = fILL::rotations_admin->new();
$app->run();
