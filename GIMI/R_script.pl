#!/usr/bin/perl
open(OUT,">R_script_viz.r");
print OUT "library(RSQLite)\n";
print OUT "con <- dbConnect(dbDriver(\"SQLite\"), dbname = \"$ARGV[0]\.sq3\")\n";
print OUT "dbListTables(con)\n";
print OUT "dbReadTable(con,\"iperf_transfer\")\n";
print OUT "mydata1 <- dbGetQuery(con, \"select oml_sender_id,begin_interval,size,end_interval from iperf_transfer where oml_sender_id=1\")\n";
print OUT "intervals1 <- mydata1\$end_interval - mydata1\$begin_interval\n";
print OUT "throughput1 <- abs(mydata1\$size)/intervals1/1024/1024*8\n";
print OUT "plot(throughput1,type=\"o\",col=\"red\",xlab=\"Experiment Interval\",ylab=\"Throughput (Mbps)\")\n";
print OUT "mydata2 <- dbGetQuery(con, \"select oml_sender_id,begin_interval,size,end_interval from iperf_transfer where oml_sender_id=2\")\n";
print OUT "intervals2 <- mydata2\$end_interval - mydata2\$begin_interval\n";
print OUT "throughput2 <- abs(mydata2\$size)/intervals2/1024/1024*8\n";


print OUT "png(filename=\"$ARGV[0].png\", height=650, width=900,
 bg=\"white\")\n";
#pdf("gimi20testing3.pdf")
print OUT "g_range <- range(0,throughput1,throughput2)\n";
print OUT "plot(throughput1,type=\"o\",col=\"red\",ylim= g_range, lty=2, xlab=\"Experiment Interval\",ylab=\"Throughput (Mbps)\")\n";
print OUT "lines(throughput2,type=\"o\",col=\"blue\",xlab=\"Experiment Interval\",ylab=\"Throughput (Mbps)\")\n";
print OUT "title(main=\"Iperf_Experiment on ExoGENI\", col.main=\"red\", font.main=4)\n";
print OUT "legend(1, g_range[2], c(\"192.168.3.12\",\"192.168.2.12\"), cex=0.8,
   col=c(\"red\",\"blue\"), pch=21:22, lty=1:2)\;\n";


print OUT "dev.off()";
close OUT;
