#!/usr/bin/perl -w -T

use lib "/opt/fILL/modules";
use fILLreporter;

my $reporter_server = fILLreporter->new(
    {
    conf_file => '/opt/fILL/conf/fILLreporter.conf',
    })->run;
