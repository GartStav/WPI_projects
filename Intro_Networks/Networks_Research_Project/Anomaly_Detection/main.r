# set working directory to the folder with dump files in csv format
setwd("~/Networks_Research_Project/cs513/new_data/")

# read the dat into the data frame
#dat1 = read.table("1.csv", header=TRUE, sep="")
dat1 = read.table("1.csv", header=TRUE, sep="")

# SPLIT data into time slots
# first create a sequence of times
s <- seq(min(dat1$timestamp), max(dat1$timestamp), by = 20)
  # make cuts of the timestamp column based on sequence of times 
  c <- cut(dat1$timestamp, breaks = s)
# make slits of data based on cuts
timeslots <- split(dat1, c)

# CHANGE DETECTION BETWEEN TIME SLOTS
# collect statistics #bytes, #packets and #syns
nbytes <- sapply( timeslots, function(x) sum(x$ip_len) )
npacks <- sapply( timeslots, function(x) length(x$ip_len) )
nsyns <- sapply( timeslots, function(x) sum(x$tcp_flags=="S") )

# plot statistics data for the time slots
par(mfrow=c(3,1))
time_slots = 1:length(timeslots)
plot(time_slots, nbytes, "s")
plot(time_slots, npacks, "s")
plot(time_slots, nsyns, "s")

# absolute deltoids for number of bytes
d_nbytes <- numeric(length(timeslots))
d_nbytes[1] <- nbytes[[1]]
for (i in 2:length(timeslots)){
  d_nbytes[i] <- abs(nbytes[[i-1]] - nbytes[[i]])
}

# absolute deltoids for number of packets
d_npacks <- numeric(length(timeslots))
d_npacks[1] <- npacks[[1]]
for (i in 2:length(timeslots)){
  d_npacks[i] <- abs(npacks[[i-1]] - npacks[[i]])
}

# absolute deltoids for number of syns
d_nsyns <- numeric(length(timeslots))
d_nsyns[1] <- nsyns[[1]]
for (i in 2:length(timeslots)){
  d_nsyns[i] <- abs(nsyns[[i-1]] - nsyns[[i]])
}

# plot absolute deltoids for 3 statistics
par(mfrow=c(3,1))
time_slots = 1:length(timeslots)
plot(time_slots, d_nbytes, "s")
plot(time_slots, d_npacks, "s")
plot(time_slots, d_nsyns, "s")

# boolean for anomalous time slots
first_lvl_candidates <- logical(length(timeslots))

r_nbytes <- numeric(length(timeslots))
r_npacks <- numeric(length(timeslots))
r_nsyns <- numeric(length(timeslots))

# change detection core - compute the thresolds
for (i in 1:length(timeslots)) {
  if ( i < 11 ) {
    first_lvl_candidates[[i]] = TRUE
  }
  else {
    r_nbytes[i] <- d_nbytes[i] - sd(d_nbytes[(i-10):i]) #+ mean(dbytes[1:i])
    r_npacks[i] <- d_npacks[i] - sd(d_npacks[(i-10):i]) #+ mean((dpacks[1:i]))
    r_nsyns[i] <- d_nsyns[i] - sd(d_nsyns[(i-10):i]) #+ mean(dsyns[1:i])
    if ( (rej_bytes[i]>0) || (r_npacks[i]>0) || (r_nsyns[i]>0) ) { 
      first_lvl_candidates[[i]] = TRUE
    }
  }
}


# plot threshold values for 3 metrics
par(mfrow=c(4,1))
time_slots = 1:length(timeslots)
plot(time_slots, r_nbytes, "s")
plot(time_slots, r_npacks, "s")
plot(time_slots, r_nsyns, "s")
plot(time_slots, first_lvl_candidates, "h")

# length(which(first_lvl_candidates == FALSE))

# CHANGE DETECTION INSIDE TIME SLOTS

# init lists of timeslots (data frames) for change detection for each aggregation level
timeslots_ip_src = list()
sorted_ip_src = list()
timeslots_ip_dst = list()
sorted_ip_dst = list()
timeslots_ip_src_8 = list()
sorted_ip_src_8 = list()
timeslots_ip_dst_8 = list()
sorted_ip_dst_8 = list()


f2 <- function(s) unlist(strsplit(s, "\\."))
f3 <- function (x, y) paste(x, y, sep=".")

# add ip_src prefixes to data
for (i in (1:length(timeslots))) {
  isrc <- lapply( timeslots[[i]]$ip_src, toString )
  splits <- sapply( isrc, f2, simplify = "array" )
  prefix8 <- splits[1,]
  prefix16 <- mapply(f3, x=prefix8, y = splits[2,])
  prefix24 <- mapply(f3, x=prefix16, y = splits[3,])

  timeslots[[i]]$src_prefix8 <- prefix8
  timeslots[[i]]$src_prefix16 <- prefix16
  timeslots[[i]]$src_prefix24 <- prefix24
}

# add ip_dst prefixes to data
for (i in (1:length(timeslots))) {
  idst <- lapply( timeslots[[i]]$ip_dst, toString )
  splits <- sapply( idst, f2, simplify = "array" )
  prefix8 <- splits[1,]
  prefix16 <- mapply(f3, x=prefix8, y = splits[2,])
  prefix24 <- mapply(f3, x=prefix16, y = splits[3,])
  
  timeslots[[i]]$dst_prefix8 <- prefix8
  timeslots[[i]]$dst_prefix16 <- prefix16
  timeslots[[i]]$dst_prefix24 <- prefix24
}

# fill them with the data (perform aggregation) 
for (i in 1:length(timeslots)) {
  # aggregate by ip source
  timeslots_ip_src[[i]] <- ddply(timeslots[[i]], c("ip_src"), summarize, npackets=length(ip_len), nbytes=sum(ip_len), nsyns=sum(tcp_flags=="S"), ts=min(timestamp))
  # sort the data frames by the time
  sorted_ip_src[[i]] <- timeslots_ip_src[[i]][order(timeslots_ip_src[[i]]$ts),]
  # aggregate by ip destination
  timeslots_ip_dst[[i]] <- ddply(timeslots[[i]], c("ip_dst"), summarize, npackets=length(ip_len), nbytes=sum(ip_len), nsyns=sum(tcp_flags=="S"), ts=min(timestamp))
  # sort the data frames by the time
  sorted_ip_dst[[i]] <- timeslots_ip_dst[[i]][order(timeslots_ip_dst[[i]]$ts),]
  
  # aggregate by ip source /24
  timeslots_ip_src_8[[i]] <- ddply(timeslots[[i]], c("src_prefix8"), summarize, npackets=length(ip_len), nbytes=sum(ip_len), nsyns=sum(tcp_flags=="S"), ts=min(timestamp))
  # sort the data frames by the time
  sorted_ip_src_8[[i]] <- timeslots_ip_src_8[[i]][order(timeslots_ip_src_8[[i]]$ts),]
  # aggregate by ip destination /24
  timeslots_ip_dst_8[[i]] <- ddply(timeslots[[i]], c("dst_prefix8"), summarize, npackets=length(ip_len), nbytes=sum(ip_len), nsyns=sum(tcp_flags=="S"), ts=min(timestamp))
  # sort the data frames by the time
  sorted_ip_dst_8[[i]] <- timeslots_ip_dst_8[[i]][order(timeslots_ip_dst_8[[i]]$ts),]
}

# CHANGE DETECTION FOR IP SOURCE

size <- list()
d_nbytes_ip_src <- list()
d_npacks_ip_src <- list()
d_nsyns_ip_src <- list()

r_nbytes_ip_src <- list()
r_npacks_ip_src <- list()
r_nsyns_ip_src <- list()
i <- 1
j <- 1

for (i in 1:length(timeslots)) {
  size[[i]] <- nrow(sorted_ip_src[[i]])
  d_nbytes_ip_src[[i]] <- numeric(size[[i]])
  d_npacks_ip_src[[i]] <- numeric(size[[i]])
  d_nsyns_ip_src[[i]] <- numeric(size[[i]])
  d_nbytes_ip_src[[i]][1] <- sorted_ip_src[[i]]$nbytes[1]
  d_npacks_ip_src[[i]][1] <- sorted_ip_src[[i]]$npackets[1]
  d_nsyns_ip_src[[i]][1] <- sorted_ip_src[[i]]$nsyns[1]
  for (j in 2:size[[i]]) {
    # change detection for number of bytes
    d_nbytes_ip_src[[i]][j] <- abs(sorted_ip_src[[i]]$nbytes[j-1] - sorted_ip_src[[i]]$nbytes[j])
    # change detection for number of packets
    d_npacks_ip_src[[i]][j] <- abs(sorted_ip_src[[i]]$npackets[j-1] - sorted_ip_src[[i]]$npackets[j])
    # change detection for number of syns
    d_nsyns_ip_src[[i]][j] <- abs(sorted_ip_src[[i]]$nsyns[j-1] - sorted_ip_src[[i]]$nsyns[j])
  }
}

second_lvl_candidates <- logical(length(timeslots))
ip_src_counts <- numeric(length(timeslots))
  
for (i in 1:length(timeslots)) {
    
  r_nbytes_ip_src[[i]] <- numeric(size[[i]])
  r_npacks_ip_src[[i]] <- numeric(size[[i]])
  r_nsyns_ip_src[[i]] <- numeric(size[[i]])
  r_nbytes_ip_src[[i]][1] <- d_nbytes_ip_src[[i]][1]
  r_npacks_ip_src[[i]][1] <- d_npacks_ip_src[[i]][1]
  r_nsyns_ip_src[[i]][1] <- d_nsyns_ip_src[[i]][1]
  

  
  
  if ( first_lvl_candidates[[i]] ) {
    for (j in 2:size[[i]]) {
      if ( j < 6 ) {
        r_nbytes_ip_src[[i]][j] <- d_nbytes_ip_src[[i]][j]
        # second_lvl_candidates[[j]] = FALSE
      } else {
        r_nbytes_ip_src[[i]][j] <- d_nbytes_ip_src[[i]][j] - sd(d_nbytes_ip_src[[i]][(j-5):j]) 
        r_npacks_ip_src[[i]][j] <- d_npacks_ip_src[[i]][j] - sd(d_npacks_ip_src[[i]][(j-5):j]) 
        r_nsyns_ip_src[[i]][j] <- d_nsyns_ip_src[[i]][j] - sd(d_nsyns_ip_src[[i]][(j-5):j]) 
        if ( (r_nbytes_ip_src[[i]][j]>400000) || (r_npacks_ip_src[[i]][j]>400) || (r_nsyns_ip_src[[i]][j]>20) ) {
          ip_src_counts[i] <- ip_src_counts[i] + 1
          second_lvl_candidates[[i]] = TRUE
        }
      }
    }
  }
}

index <- 180
par(mfrow=c(3,1))
x = 1:size[[index]]
plot(x, r_nbytes_ip_src[[180]], "h")
plot(x, r_npacks_ip_src[[180]], "h")
plot(x, r_nsyns_ip_src[[180]], "h")

which.max(ip_src_counts) # 168

# CHANGE DETECTION FOR IP DESTINATION

size <- list()
d_nbytes_ip_dst <- list()
d_npacks_ip_dst <- list()
d_nsyns_ip_dst <- list()

r_nbytes_ip_dst <- list()
r_npacks_ip_dst <- list()
r_nsyns_ip_dst <- list()
i <- 1
j <- 1

for (i in 1:length(timeslots)) {
  size[[i]] <- nrow(sorted_ip_dst[[i]])
  d_nbytes_ip_dst[[i]] <- numeric(size[[i]])
  d_npacks_ip_dst[[i]] <- numeric(size[[i]])
  d_nsyns_ip_dst[[i]] <- numeric(size[[i]])
  d_nbytes_ip_dst[[i]][1] <- sorted_ip_dst[[i]]$nbytes[1]
  d_npacks_ip_dst[[i]][1] <- sorted_ip_dst[[i]]$npackets[1]
  d_nsyns_ip_dst[[i]][1] <- sorted_ip_dst[[i]]$nsyns[1]
  for (j in 2:size[[i]]) {
    # change detection for number of bytes
    d_nbytes_ip_dst[[i]][j] <- abs(sorted_ip_dst[[i]]$nbytes[j-1] - sorted_ip_dst[[i]]$nbytes[j])
    # change detection for number of packets
    d_npacks_ip_dst[[i]][j] <- abs(sorted_ip_dst[[i]]$npackets[j-1] - sorted_ip_dst[[i]]$npackets[j])
    # change detection for number of syns
    d_nsyns_ip_dst[[i]][j] <- abs(sorted_ip_dst[[i]]$nsyns[j-1] - sorted_ip_dst[[i]]$nsyns[j])
  }
}

second_lvl_candidates <- logical(length(timeslots))
ip_dst_counts <- numeric(length(timeslots))

for (i in 1:length(timeslots)) {
  
  r_nbytes_ip_dst[[i]] <- numeric(size[[i]])
  r_npacks_ip_dst[[i]] <- numeric(size[[i]])
  r_nsyns_ip_dst[[i]] <- numeric(size[[i]])
  r_nbytes_ip_dst[[i]][1] <- d_nbytes_ip_dst[[i]][1]
  r_npacks_ip_dst[[i]][1] <- d_npacks_ip_dst[[i]][1]
  r_nsyns_ip_dst[[i]][1] <- d_nsyns_ip_dst[[i]][1]
  
  if ( first_lvl_candidates[[i]] ) {
    for (j in 2:size[[i]]) {
      if ( j < 6 ) {
        r_nbytes_ip_dst[[i]][j] <- d_nbytes_ip_dst[[i]][j]
        # second_lvl_candidates[[j]] = FALSE
      } else {
        r_nbytes_ip_dst[[i]][j] <- d_nbytes_ip_dst[[i]][j] - sd(d_nbytes_ip_dst[[i]][(j-5):j]) 
        r_npacks_ip_dst[[i]][j] <- d_npacks_ip_dst[[i]][j] - sd(d_npacks_ip_dst[[i]][(j-5):j]) 
        r_nsyns_ip_dst[[i]][j] <- d_nsyns_ip_dst[[i]][j] - sd(d_nsyns_ip_dst[[i]][(j-5):j]) 
        if ( (r_nbytes_ip_dst[[i]][j]>300000) || (r_npacks_ip_dst[[i]][j]>300) || (r_nsyns_ip_dst[[i]][j]>13) ) {
          ip_dst_counts[i] <- ip_dst_counts[i] + 1
          second_lvl_candidates[[i]] = TRUE
        }
      }
    }
  }
}

index <- 180
par(mfrow=c(3,1))
x = 1:size[[index]]
plot(x, r_nbytes_ip_dst[[180]], "h")
plot(x, r_npacks_ip_dst[[180]], "h")
plot(x, r_nsyns_ip_dst[[180]], "h")

which.max(ip_dst_counts) # 30

# CHANGE DETECTION FOR IP SOURCE /8

size <- list()
d_nbytes_ip_src_8 <- list()
d_npacks_ip_src_8 <- list()
d_nsyns_ip_src_8 <- list()

r_nbytes_ip_src_8 <- list()
r_npacks_ip_src_8 <- list()
r_nsyns_ip_src_8 <- list()
i <- 1
j <- 1

for (i in 1:length(timeslots)) {
  size[[i]] <- nrow(sorted_ip_src_8[[i]])
  d_nbytes_ip_src_8[[i]] <- numeric(size[[i]])
  d_npacks_ip_src_8[[i]] <- numeric(size[[i]])
  d_nsyns_ip_src_8[[i]] <- numeric(size[[i]])
  d_nbytes_ip_src_8[[i]][1] <- sorted_ip_src_8[[i]]$nbytes[1]
  d_npacks_ip_src_8[[i]][1] <- sorted_ip_src_8[[i]]$npackets[1]
  d_nsyns_ip_src_8[[i]][1] <- sorted_ip_src_8[[i]]$nsyns[1]
  for (j in 2:size[[i]]) {
    # change detection for number of bytes
    d_nbytes_ip_src_8[[i]][j] <- abs(sorted_ip_src_8[[i]]$nbytes[j-1] - sorted_ip_src_8[[i]]$nbytes[j])
    # change detection for number of packets
    d_npacks_ip_src_8[[i]][j] <- abs(sorted_ip_src_8[[i]]$npackets[j-1] - sorted_ip_src_8[[i]]$npackets[j])
    # change detection for number of syns
    d_nsyns_ip_src_8[[i]][j] <- abs(sorted_ip_src_8[[i]]$nsyns[j-1] - sorted_ip_src_8[[i]]$nsyns[j])
  }
}

second_lvl_candidates <- logical(length(timeslots))
ip_src_8_counts <- numeric(length(timeslots))

for (i in 1:length(timeslots)) {
  
  r_nbytes_ip_src_8[[i]] <- numeric(size[[i]])
  r_npacks_ip_src_8[[i]] <- numeric(size[[i]])
  r_nsyns_ip_src_8[[i]] <- numeric(size[[i]])
  r_nbytes_ip_src_8[[i]][1] <- d_nbytes_ip_src_8[[i]][1]
  r_npacks_ip_src_8[[i]][1] <- d_npacks_ip_src_8[[i]][1]
  r_nsyns_ip_src_8[[i]][1] <- d_nsyns_ip_src_8[[i]][1]
    
  if ( first_lvl_candidates[[i]] ) {
    for (j in 2:size[[i]]) {
      if ( j < 6 ) {
        r_nbytes_ip_src_8[[i]][j] <- d_nbytes_ip_src_8[[i]][j]
        # second_lvl_candidates[[j]] = FALSE
      } else {
        r_nbytes_ip_src_8[[i]][j] <- d_nbytes_ip_src_8[[i]][j] - sd(d_nbytes_ip_src_8[[i]][(j-5):j]) 
        r_npacks_ip_src_8[[i]][j] <- d_npacks_ip_src_8[[i]][j] - sd(d_npacks_ip_src_8[[i]][(j-5):j]) 
        r_nsyns_ip_src_8[[i]][j] <- d_nsyns_ip_src_8[[i]][j] - sd(d_nsyns_ip_src_8[[i]][(j-5):j]) 
        if ( (r_nbytes_ip_src_8[[i]][j]>300000) || (r_npacks_ip_src_8[[i]][j]>500) || (r_nsyns_ip_src_8[[i]][j]>25) ) {
          ip_src_8_counts[i] <- ip_src_8_counts[i] + 1
          second_lvl_candidates[[i]] = TRUE
        }
      }
    }
  }
}

index <- 180
par(mfrow=c(3,1))
x = 1:size[[180]]
plot(x, r_nbytes_ip_src_8[[180]], "h")
plot(x, r_npacks_ip_src_8[[180]], "h")
plot(x, r_nsyns_ip_src_8[[180]], "h")

which.max(ip_src_8_counts) # 180

# CHANGE DETECTION FOR IP DESTINATION /8

size <- list()
d_nbytes_ip_dst_8 <- list()
d_npacks_ip_dst_8 <- list()
d_nsyns_ip_dst_8 <- list()

r_nbytes_ip_dst_8 <- list()
r_npacks_ip_dst_8 <- list()
r_nsyns_ip_dst_8 <- list()
i <- 1
j <- 1

for (i in 1:length(timeslots)) {
  size[[i]] <- nrow(sorted_ip_dst_8[[i]])
  d_nbytes_ip_dst_8[[i]] <- numeric(size[[i]])
  d_npacks_ip_dst_8[[i]] <- numeric(size[[i]])
  d_nsyns_ip_dst_8[[i]] <- numeric(size[[i]])
  d_nbytes_ip_dst_8[[i]][1] <- sorted_ip_dst_8[[i]]$nbytes[1]
  d_npacks_ip_dst_8[[i]][1] <- sorted_ip_dst_8[[i]]$npackets[1]
  d_nsyns_ip_dst_8[[i]][1] <- sorted_ip_dst_8[[i]]$nsyns[1]
  for (j in 2:size[[i]]) {
    # change detection for number of bytes
    d_nbytes_ip_dst_8[[i]][j] <- abs(sorted_ip_dst_8[[i]]$nbytes[j-1] - sorted_ip_dst_8[[i]]$nbytes[j])
    # change detection for number of packets
    d_npacks_ip_dst_8[[i]][j] <- abs(sorted_ip_dst_8[[i]]$npackets[j-1] - sorted_ip_dst_8[[i]]$npackets[j])
    # change detection for number of syns
    d_nsyns_ip_dst_8[[i]][j] <- abs(sorted_ip_dst_8[[i]]$nsyns[j-1] - sorted_ip_dst_8[[i]]$nsyns[j])
  }
}

second_lvl_candidates <- logical(length(timeslots))
ip_dst_8_counts <- numeric(length(timeslots))

for (i in 1:length(timeslots)) {
  
  r_nbytes_ip_dst_8[[i]] <- numeric(size[[i]])
  r_npacks_ip_dst_8[[i]] <- numeric(size[[i]])
  r_nsyns_ip_dst_8[[i]] <- numeric(size[[i]])
  r_nbytes_ip_dst_8[[i]][1] <- d_nbytes_ip_dst_8[[i]][1]
  r_npacks_ip_dst_8[[i]][1] <- d_npacks_ip_dst_8[[i]][1]
  r_nsyns_ip_dst_8[[i]][1] <- d_nsyns_ip_dst_8[[i]][1]
  
  if ( first_lvl_candidates[[i]] ) {
    for (j in 2:size[[i]]) {
      if ( j < 6 ) {
        r_nbytes_ip_dst_8[[i]][j] <- d_nbytes_ip_dst_8[[i]][j]
        # second_lvl_candidates[[j]] = FALSE
      } else {
        r_nbytes_ip_dst_8[[i]][j] <- d_nbytes_ip_dst_8[[i]][j] - sd(d_nbytes_ip_dst_8[[i]][(j-5):j]) 
        r_npacks_ip_dst_8[[i]][j] <- d_npacks_ip_dst_8[[i]][j] - sd(d_npacks_ip_dst_8[[i]][(j-5):j]) 
        r_nsyns_ip_dst_8[[i]][j] <- d_nsyns_ip_dst_8[[i]][j] - sd(d_nsyns_ip_dst_8[[i]][(j-5):j]) 
        if ( (r_nbytes_ip_dst_8[[i]][j]>250000) || (r_npacks_ip_dst_8[[i]][j]>400) || (r_nsyns_ip_dst_8[[i]][j]>15) ) {
          ip_dst_8_counts[i] <- ip_dst_8_counts[i] + 1
          second_lvl_candidates[[i]] = TRUE
        }
      }
    }
  }
}

par(mfrow=c(3,1))
x = 1:size[[180]]
plot(x, r_nbytes_ip_dst_8[[180]], "h")
plot(x, r_npacks_ip_dst_8[[180]], "h")
plot(x, r_nsyns_ip_dst_8[[180]], "h")

which.max(ip_dst_8_counts) # 12

x = 1:180
par(mfrow=c(4,1))
plot(x, ip_src_counts, "h")
plot(x, ip_dst_counts, "h")
plot(x, ip_src_8_counts, "h")
plot(x, ip_dst_8_counts, "h")

# aggregate data before unsupervised anomaly detection (clustering) #12 #30 #168 #180
agg_data <- ddply(timeslots[[12]], c("dst_prefix24"), summarize, n_s_ip=length(unique(ip_src)), n_d_ip=length(unique(ip_dst)), n_s_p=length(unique(sport)), n_d_p=length(unique(dport)), ratio_sd=n_s_ip/n_d_ip, pck_rate=length(ip_src)/(max(timeslots[[12]]$timestamp)-min(timeslots[[12]]$timestamp)), pck_to_dst=length(ip_src)/n_d_ip, nsyns=sum(tcp_flags=="S")/length(ip_src), ratio_icmp=sum(ip_proto=="I")/length(ip_src), ts=min(timestamp))
sorted_agg <- agg_data[order(agg_data$ts),]
write.csv(sorted_agg[c(1:10)],"T12_agg.csv", row.names=FALSE, quote=FALSE)

agg_data <- ddply(timeslots[[30]], c("dst_prefix24"), summarize, n_s_ip=length(unique(ip_src)), n_d_ip=length(unique(ip_dst)), n_s_p=length(unique(sport)), n_d_p=length(unique(dport)), ratio_sd=n_s_ip/n_d_ip, pck_rate=length(ip_src)/(max(timeslots[[12]]$timestamp)-min(timeslots[[12]]$timestamp)), pck_to_dst=length(ip_src)/n_d_ip, nsyns=sum(tcp_flags=="S")/length(ip_src), ratio_icmp=sum(ip_proto=="I")/length(ip_src), ts=min(timestamp))
sorted_agg <- agg_data[order(agg_data$ts),]
write.csv(sorted_agg[c(1:10)],"T30_agg.csv", row.names=FALSE, quote=FALSE)

agg_data <- ddply(timeslots[[168]], c("dst_prefix24"), summarize, n_s_ip=length(unique(ip_src)), n_d_ip=length(unique(ip_dst)), n_s_p=length(unique(sport)), n_d_p=length(unique(dport)), ratio_sd=n_s_ip/n_d_ip, pck_rate=length(ip_src)/(max(timeslots[[12]]$timestamp)-min(timeslots[[12]]$timestamp)), pck_to_dst=length(ip_src)/n_d_ip, nsyns=sum(tcp_flags=="S")/length(ip_src), ratio_icmp=sum(ip_proto=="I")/length(ip_src), ts=min(timestamp))
sorted_agg <- agg_data[order(agg_data$ts),]
write.csv(sorted_agg[c(1:10)],"T168_agg.csv", row.names=FALSE, quote=FALSE)

agg_data <- ddply(timeslots[[180]], c("dst_prefix24"), summarize, n_s_ip=length(unique(ip_src)), n_d_ip=length(unique(ip_dst)), n_s_p=length(unique(sport)), n_d_p=length(unique(dport)), ratio_sd=n_s_ip/n_d_ip, pck_rate=length(ip_src)/(max(timeslots[[12]]$timestamp)-min(timeslots[[12]]$timestamp)), pck_to_dst=length(ip_src)/n_d_ip, nsyns=sum(tcp_flags=="S")/length(ip_src), ratio_icmp=sum(ip_proto=="I")/length(ip_src), ts=min(timestamp))
sorted_agg <- agg_data[order(agg_data$ts),]
write.csv(sorted_agg[c(1:10)],"T180_agg.csv", row.names=FALSE, quote=FALSE)