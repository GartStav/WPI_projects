setwd("~/Networks_Research_Project/cs513/dataintentimeintervels")
dat1 = read.csv("T01.csv", header=TRUE)
dat2 = read.csv("T02.csv", header=TRUE)
dat3 = read.csv("T03.csv", header=TRUE)
dat4 = read.csv("T04.csv", header=TRUE)
dat5 = read.csv("T05.csv", header=TRUE)
dat6 = read.csv("T06.csv", header=TRUE)
dat7 = read.csv("T07.csv", header=TRUE)
dat8 = read.csv("T08.csv", header=TRUE)
dat9 = read.csv("T09.csv", header=TRUE)
dat10 = read.csv("T010.csv", header=TRUE)

nbytes <- c( sum(dat1$ip_len), sum(dat2$ip_len), sum(dat3$ip_len), sum(dat4$ip_len), sum(dat5$ip_len), sum(dat6$ip_len), sum(dat7$ip_len), sum(dat8$ip_len), sum(dat9$ip_len), sum(dat10$ip_len) )
npacks <- c( length(dat1$ip_len), length(dat2$ip_len), length(dat3$ip_len), length(dat4$ip_len), length(dat5$ip_len), length(dat6$ip_len), length(dat7$ip_len), length(dat8$ip_len), length(dat9$ip_len), length(dat10$ip_len) )
nsyns <- c( sum(dat1$tcp_flags=="S"), sum(dat2$tcp_flags=="S"), sum(dat3$tcp_flags=="S"), sum(dat4$tcp_flags=="S"), sum(dat5$tcp_flags=="S"), sum(dat6$tcp_flags=="S"), sum(dat7$tcp_flags=="S"), sum(dat8$tcp_flags=="S"), sum(dat9$tcp_flags=="S"), sum(dat10$tcp_flags=="S") )

# change detection for number of bytes
dbytes <- numeric(10)
dbytes[1] <- 150000
for (i in 2:10){
  dbytes[i] <- abs(nbytes[i-1] - nbytes[i])
}

# change detection for number of packets
dpacks <- numeric(10)
dpacks[1] <- 4000
for (i in 2:10){
  dpacks[i] <- abs(npacks[i-1] - npacks[i])
}

# change detection for number of syns
dsyns <- numeric(10)
dsyns[1] <- 300
for (i in 2:10){
  dsyns[i] <- abs(nsyns[i-1] - nsyns[i])
}

# threshold calulcations

rej_bytes <- numeric(10)
rej_bytes[1] <- dbytes[1]
for (i in 2:10) {
  rej_bytes[i] <- dbytes[i] - sd(dbytes[1:i]) #+ mean(dbytes[1:i])
}

rej_packs <- numeric(10)
rej_packs[1] <- dpacks[1]
for (i in 2:10) {
  rej_packs[i] <- dpacks[i] - sd(dpacks[1:i]) #+ mean((dpacks[1:i]))
}

rej_syns <- numeric(10)
rej_syns[1] <- dsyns[1]
for (i in 2:10) {
  rej_syns[i] <- dsyns[i] - sd(dsyns[1:i]) #+ mean(dsyns[1:i])
}

par(mfrow=c(3,1))
x = 1:10
plot(x, rej_bytes, "s")
plot(x, rej_packs, "s")
plot(x, rej_syns, "s")

# choose time slots number 5,7 and 9 are found by change detection as exceeding the threshold


  