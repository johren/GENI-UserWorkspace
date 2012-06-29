#!/usr/bin/perl
open(OUT,">oml\.html");
print OUT "<html>\n <head>\n<meta http-equiv=\"refresh\" content=\"10\">\n</head>\n<img src=\"$ARGV[0]\.jpg\" alt=\"Iperf\"  />\n </html>";
close OUT;

