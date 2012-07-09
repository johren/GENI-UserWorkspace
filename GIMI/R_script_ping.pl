#!/usr/bin/perl
open(OUT,">R_script_ping_viz.r");
print OUT "library(RSQLite)\n";
print OUT "con <- dbConnect(dbDriver(\"SQLite\"), dbname = \"$ARGV[0]\.sq3\")\n";
print OUT "dbListTables(con)\n";
print OUT "dbReadTable(con,\"pingmonitor_myping\")\n";
print OUT "mydata1 <- dbGetQuery(con, \"select dest_addr,rtt from pingmonitor_myping where dest_addr='192.168.3.12'\")\n";
print OUT "rtt1 <- mydata1\$rtt\n";
print OUT "mydata2 <- dbGetQuery(con, \"select dest_addr,rtt from pingmonitor_myping where dest_addr='192.168.2.12'\")\n";
print OUT "rtt2 <- mydata2\$rtt\n";

print OUT "png(filename=\"$ARGV[0].png\", height=650, width=900,
 bg=\"white\")\n";
#pdf("gimi20testing3.pdf")
print OUT "g_range <- range(0,rtt1,rtt2)\n";
print OUT "plot(rtt1,type=\"o\",col=\"red\",ylim= g_range, lty=2, xlab=\"Experiment Interval\",ylab=\"RTT (ms)\")\n";
print OUT "lines(rtt2,type=\"o\",col=\"blue\",xlab=\"Experiment Interval\",ylab=\"RTT (ms)\")\n";
print OUT "title(main=\"Ping Experiment on ExoGENI\", col.main=\"red\", font.main=4)\n";
print OUT "legend(1, g_range[2], c(\"192.168.3.12\",\"192.168.2.12\"), cex=0.8,
   col=c(\"red\",\"blue\"), pch=21:22, lty=1:2)\;\n";


print OUT "dev.off()";
close OUT;
