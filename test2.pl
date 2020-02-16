#!/usr/bin/perl
use strict;
use CGI qw(:standard);
use CGI::Carp qw(warningsToBrowser fatalsToBrowser);

print "Content-type: text/html\r\n\r\n";

foreach my $key (sort(keys(%ENV))) {
    print "$key = $ENV{$key}<br>\n";
}

print end_html;
