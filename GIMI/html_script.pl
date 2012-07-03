#!/usr/bin/perl
open(OUT,">oml\.html");
print OUT "<html>\n <head>\n<meta http-equiv=\"refresh\" content=\"10\">\n</head>\n
<div style=\"float:left;\">\n
<img src=\"$ARGV[0]1.jpg\" alt=\"Iperf Source1\"/>\n
</div>\n

<div style=\"float:right;\">\n
<img src=\"$ARGV[0]2.jpg\" alt=\"Iperf Source2\"  />\n
</div>\n


</html>";
close OUT;

