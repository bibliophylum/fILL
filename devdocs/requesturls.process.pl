#!/usr/bin/perl
use warnings;
use strict;

print "<html>\n<head>\n</head>\n<body>\n";
while (<>) {
    chomp;
    my ($file,$data) = split/:/,$_,2;
    print STDERR "$data\n";
    $data =~ s|^.*value=\"(.*)\"/>$|$1|;
    print STDERR "\t$data\n";
    print "<p>$file <a href=\"$data\" target=\"_blank\">$data</a></p>\n";
}
print "</body>\n</html>\n";
