#!/usr/bin/perl
use Data::Dumper;

my @args;
#@args = ("../bin/change-request-status.cgi", "reqid=20", "lid=101", "msg_to=85", 'status=ILL-Answer|Unfilled|in-use-on-loan', 'message=');

@args = ("../bin/change-request-status.cgi", "reqid=20", "lid=101", "msg_to=85", 'status=ILL-Answer|Will-Supply|being-processed-for-supply', 'message=due 2011-12-31');
system(@args) == 0
    or die "system @args failed: $?";

@args = ("../bin/change-request-status.cgi", "reqid=20", "lid=101", "msg_to=85", 'status=Shipped', 'message=');
system(@args) == 0
    or die "system @args failed: $?";

@args = ("../bin/change-request-status.cgi", "reqid=20", "lid=85", "msg_to=101", 'status=Received', 'message=');
system(@args) == 0
    or die "system @args failed: $?";

@args = ("../bin/change-request-status.cgi", "reqid=20", "lid=85", "msg_to=101", 'status=Returned', 'message=');
system(@args) == 0
    or die "system @args failed: $?";

#@args = ("../bin/change-request-status.cgi", "reqid=20", "lid=101", "msg_to=85", 'status=Checked-in', 'message=');
#system(@args) == 0
#    or die "system @args failed: $?";

#@args = ("../bin/move-to-history.cgi", "reqid=20");
#system(@args) == 0
#    or die "system @args failed: $?";

