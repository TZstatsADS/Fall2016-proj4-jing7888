#source("http://bioconductor.org/biocLite.R")
#biocLite("rhdf5")
library(rhdf5)
# set working path to training/test data folder
train_data_path <- "/Users/Amyummy/Documents/Rstudio/ads_pro4/Project4_data/data"
test_data_path <- ""
data_output_path <- "/Users/Amyummy/Documents/Rstudio/ads_pro4/Project4_data/outputdata"
setwd(train_data_path)
file_names <- list.files(recursive = T)
file_num <- length(file_names)


### find out median dimension of different features using training data###
data.bars = vector()
data.beats = vector()
data.sec = vector()
data.seg = vector()
data.tat = vector()
n = 1
for(i in 1:file_num){
  if(! i %in% ab_songs){
    data <- h5read(file_names[i], "analysis")
    H5close()
    data.bars[n] <- length(data$bars_confidence)
    data.beats[n] <- length(data$beats_confidence)
    data.sec[n] <- length(data$sections_confidence)
    data.seg[n] <- length(data$segments_confidence)
    data.tat[n] <- length(data$tatums_confidence)
    n = n+1
  }
}
# output
bars_dim <- floor(median(data.bars)*1.5) #180
beats_dim <- floor(median(data.beats)*1.5) #669
sec_dim <- floor(median(data.sec)*1.5) #13
seg_dim <- floor(median(data.seg)*1.5) #1116
tat_dim <- floor(median(data.tat)*1.5) #1474




### check whether songs in training set have 0 dim features ###
for(i in 1:file_num){
  data <- h5read(file_names[i], "analysis")
  H5close()
  if(length(data$bars_confidence) == 0){
    data$bars_start == rep(0, bars_dim)
  }
  if(length(data$beats_confidence) == 0){
    data$beats_start == rep(0, beats_dim)
  }
  if(length(data$sections_confidence) == 0){
    data$sections_start == rep(0, sec_dim)
  }
  if(length(data$segments_confidence) == 0){
    data$segments_start == rep(0, seg_dim)
  }
  if(length(data$tatums_confidence) == 0){
    data$tatums_start == rep(0, tat_dim)
  }
}


### define feature processing functions ###
feature_truncate_1d <- function(ls, len){
  if(length(ls) >= len){
    ls <- ls[1:len]
  }
  else{
    t <- ceiling(len/length(ls))
    ls <- rep(ls, t)
    ls <- ls[1:len]
  }
  return(ls)
}

feature_truncate_2d <- function(df, ncols){
  if(dim(df)[2] >= ncols){
    df <- df[,1:ncols]
  }
  else{
    t <- ceiling(ncols/dim(df)[2])
    df <- do.call("cbind", replicate(t, df, simplify = FALSE))
    df <- df[,1:ncols]
  }
  ls <- as.vector(t(df))
  return(ls)
}



### convert training data ###

bars_s <-matrix(NA,nrow = file_num, ncol=bars_dim)
beats_s <-matrix(NA,nrow = file_num, ncol=beats_dim)
sections_s <-matrix(NA,nrow = file_num, ncol=sec_dim)
segments_s <-matrix(NA,nrow = file_num, ncol=seg_dim)
segments_l_m <-matrix(NA,nrow = file_num, ncol=seg_dim)
segments_l_m_t <-matrix(NA,nrow = file_num, ncol=seg_dim)
segments_l_s <-matrix(NA,nrow = file_num, ncol=seg_dim)
segments_p <-matrix(NA,nrow = file_num, ncol=13392)
segments_t <-matrix(NA,nrow = file_num, ncol=13392)
tatums_s <-matrix(NA,nrow = file_num, ncol=tat_dim)

t1 <- Sys.time()
for(i in 1:file_num){
    data <- h5read(file_names[i], "analysis")
    H5close()
    song_id <- substring(file_names[i], 7, 24)
    bars_s[i,] <- feature_truncate_1d(data$bars_start, 180)
    beats_s[i,] <- feature_truncate_1d(data$beats_start, 669)
    sections_s[i,] <- feature_truncate_1d(data$sections_start, 13)
    segments_s[i,] <- feature_truncate_1d(data$segments_start, 1116)
    segments_l_m[i,] <- feature_truncate_1d(data$segments_loudness_max, 1116)
    segments_l_m_t[i,] <- feature_truncate_1d(data$segments_loudness_max_time, 1116)
    segments_l_s[i,] <- feature_truncate_1d(data$segments_loudness_start, 1116)
    segments_p[i,] <- feature_truncate_2d(data$segments_pitches, 1116)
    segments_t[i,] <- feature_truncate_2d(data$segments_timbre, 1116)
    tatums_s[i,] <- feature_truncate_1d(data$tatums_start, 1474)
  }
t2 <- Sys.time()
time1 <- t2 - t1



write.csv(bars_s, file = paste(data_output_path, "/bars_s.csv", sep=""))
write.csv(beats_s, file = paste(data_output_path, "/beats_s.csv", sep=""))
write.csv(sections_s, file = paste(data_output_path, "/sections_s.csv", sep=""))
write.csv(segments_s, file = paste(data_output_path, "/segments_s.csv", sep=""))
write.csv(segments_l_m, file = paste(data_output_path, "/segments_l_m.csv", sep=""))
write.csv(segments_l_m_t, file = paste(data_output_path, "/segments_l_m_t.csv", sep=""))
write.csv(segments_l_s, file = paste(data_output_path, "/segments_l_s.csv", sep=""))
write.csv(segments_p, file = paste(data_output_path, "/segments_p.csv", sep=""))
write.csv(segments_t, file = paste(data_output_path, "/segments_t.csv", sep=""))
write.csv(tatums_s, file = paste(data_output_path, "/tatums_s.csv", sep=""))
