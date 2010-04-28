#!/usr/bin/perl

while (<>) {
    s/^(.*)\t(\d+)/<option value=\"$2\">$1/;
    print;
}
