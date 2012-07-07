#!/usr/bin/perl
open(OUT,">oml\.html");
print OUT "<html>\n <head>\n<meta http-equiv=\"refresh\" content=\"10\">\n</head>\n
<div style=\"float:center;\">\n
<img src=\"$ARGV[0].png\" alt=\"Iperf Source1\"/>\n
</div>\n
</html>";
close OUT;

