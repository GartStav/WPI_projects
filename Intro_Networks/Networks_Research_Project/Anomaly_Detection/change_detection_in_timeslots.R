library(plyr)

setwd("~/Networks_Research_Project/cs513/dataintentimeintervels")
dat5 = read.csv("T05.csv", header=TRUE)
dat7 = read.csv("T07.csv", header=TRUE)
dat9 = read.csv("T09.csv", header=TRUE)

# change detection in 5th time slot
cdata <- ddply(dat9, c("ip_src"), summarize, npackets=length(ip_len), nbytes=sum(ip_len), nsyns=sum(tcp_flags=="S"), ts=min(timestamp))

# sort the data frame by the time
sorted <- cdata[order(cdata$ts),]

size <- nrow(sorted)

# change detection for number of bytes
dbytes <- numeric(size)
dbytes[1] <- 0
for (i in 2:size){
  dbytes[i] <- abs(sorted$nbytes[i-1] - sorted$nbytes[i])
}

# change detection for number of packets
dpacks <- numeric(size)
dpacks[1] <- 0
for (i in 2:size){
  dpacks[i] <- abs(sorted$npackets[i-1] - sorted$npackets[i])
}

# change detection for number of syns
dsyns <- numeric(size)
dsyns[1] <- 0
for (i in 2:size){
  dsyns[i] <- abs(sorted$nsyns[i-1] - sorted$nsyns[i])
}

# threshold calulcations

rej_bytes <- numeric(size)
rej_bytes[1] <- dbytes[1]
for (i in 500:size) {
  rej_bytes[i] <- dbytes[i] - sd(dbytes[1:i]) #+ mean(dbytes[1:i])
}

rej_packs <- numeric(size)
rej_packs[1] <- dpacks[1]
for (i in 500:size) {
  rej_packs[i] <- dpacks[i] - sd(dpacks[1:i]) #+ mean((dpacks[1:i]))
}

rej_syns <- numeric(size)
rej_syns[1] <- dsyns[1]
for (i in 500:size) {
  rej_syns[i] <- dsyns[i] - sd(dsyns[1:i]) #+ mean(dsyns[1:i])
}

par(mfrow=c(3,1))
x = 1:size
plot(x, rej_bytes, "h")
plot(x, rej_packs, "h")
plot(x, rej_syns, "h")
