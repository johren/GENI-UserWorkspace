#!/usr/bin/perl
open(OUT,">R_script_viz.r");
print OUT "library(RSQLite)\n";
print OUT "con <- dbConnect(dbDriver(\"SQLite\"), dbname = \"$ARGV[0]\.sq3\")\n";
print OUT "dbListTables(con)\n";
print OUT "dbReadTable(con,\"iperf_transfer\")\n";
print OUT "mydata <- dbGetQuery(con, \"select begin_interval,size,end_interval from iperf_transfer\")\n";
print OUT "intervals <- mydata\$end_interval - mydata\$begin_interval\n";
print OUT "throughput <- mydata\$size/intervals/1024/1024*8\n";
print OUT "pdf(\"$ARGV[0]\.pdf\")\n";
print OUT "plot(throughput,type=\"o\",col=\"red\",xlab=\"Experiment Interval\",ylab=\"Throughput (Mbps)\")\n";
print OUT "title(main=\"Iperf_Experiment\", col.main=\"blue\", font.main=4)\n";
print OUT "dev.off()";
close OUT;
