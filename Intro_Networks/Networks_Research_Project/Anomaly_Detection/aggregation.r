setwd("~/Networks_Research_Project/cs513/dataintentimeintervels")
dat = read.csv("T05.csv", header=TRUE)


# aggregate data before unsupervised anomaly detection (clustering)
# TODO add fraction of ICMP packages
agg_data <- ddply(dat, c("ip_src"), summarize, n_s_ip=length(unique(ip_src)), n_d_ip=length(unique(ip_dst)), n_s_p=length(unique(sport)), n_d_p=length(unique(dport)), ratio_sd=n_s_ip/n_d_ip, pck_rate=length(ip_src)/(max(dat$timestamp)-min(dat$timestamp)), pck_to_dst=length(ip_src)/n_d_ip, nsyns=sum(tcp_flags=="S")/length(ip_src), ratio_icmp=sum(ip_proto=="I")/length(ip_src), ts=min(timestamp))
sorted_agg <- agg_data[order(agg_data$ts),]
write.csv(sorted_agg[c(1:10)],"TO5_agg.csv", row.names=FALSE, quote=FALSE)


myvars <- c("ip_src","ip_len")
# aggregates data based on ip_src into the attributes #packets, #bytes and #syns and min(timestamp) to sort the data back
# as ddply sorting data by ip_src
cdata <- ddply(dat, c("ip_src"), summarize, npackets=length(ip_len), nbytes=sum(ip_len), nsyns=sum(tcp_flags=="S"), ts=min(timestamp))

# sort the data frame by the time
sorted <- cdata[order(cdata$ts),]

# this is the line to check the results
# d <- dat[ which(dat$ip_src=="0.51.92.179"),]

# helper fucntion to check the output of time with 15 digit precision
# print(sorted["ts"], digits=15)

# write files in a dataframe
write.csv(sorted[c(1:4)],"TO1_L1.csv", row.names=FALSE, quote=FALSE)

# string manipulations to add columns for prefixes


isrc <- lapply( sorted$ip_src, toString )
f2 <- function(s) unlist(strsplit(s, "\\."))
splits <- sapply( isrc, f2, simplify = "array" )

#splits <- unlist(strsplit(isrc[[1]], split="\\."))

prefix8 <- splits[1,]

f3 <- function (x, y) paste(x, y, sep=".")
prefix16 <- mapply(f3, x=prefix8, y = splits[2,])
prefix24 <- mapply(f3, x=prefix16, y = splits[3,])

sorted$src_prefix8 <- prefix8
sorted$src_prefix16 <- prefix16
sorted$src_prefix24 <- prefix24

# for dest

# idst <- lapply( sorted$ip_dst, toString )
# #f2 <- function(s) unlist(strsplit(s, "\\."))
# splits <- sapply( idst, f2, simplify = "array" )
# 
# #splits <- unlist(strsplit(isrc[[1]], split="\\."))
# 
# prefix8 <- splits[1,]
# 
# #f3 <- function (x, y) paste(x, y, sep=".")
# prefix16 <- mapply(f3, x=prefix8, y = splits[2,])
# prefix24 <- mapply(f3, x=prefix16, y = splits[3,])
# 
# sorted$dst_prefix8 <- prefix8
# sorted$dst_prefix16 <- prefix16
# sorted$dst_prefix24 <- prefix24

# prefix16 <- paste(prefix8, splits[[2]], sep=".")
# prefix24 <- paste(prefix16, splits[[3]], sep=".")