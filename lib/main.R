# main part
load("/Users/Amyummy/Documents/Rstudio/ads_pro4/Project4_data/lyr.RData")
lyric=lyr[,-c(1,2,3,6:30)]


# now we will use random forest to do multiple classification
load("/Users/Amyummy/Documents/Rstudio/ads_pro4/Project4_data/outputdata/bars_s.RData")
load("/Users/Amyummy/Documents/Rstudio/ads_pro4/Project4_data/outputdata/beats_s.RData")
load("/Users/Amyummy/Documents/Rstudio/ads_pro4/Project4_data/outputdata/sections_s.RData")
load("/Users/Amyummy/Documents/Rstudio/ads_pro4/Project4_data/outputdata/segments_s.RData")
load("/Users/Amyummy/Documents/Rstudio/ads_pro4/Project4_data/outputdata/segments_l_m.RData")
load("/Users/Amyummy/Documents/Rstudio/ads_pro4/Project4_data/outputdata/segments_l_m_t.RData")
load("/Users/Amyummy/Documents/Rstudio/ads_pro4/Project4_data/outputdata/segments_l_s.RData")
load("/Users/Amyummy/Documents/Rstudio/ads_pro4/Project4_data/outputdata/segments_p.RData")
load("/Users/Amyummy/Documents/Rstudio/ads_pro4/Project4_data/outputdata/segments_t.RData")
load("/Users/Amyummy/Documents/Rstudio/ads_pro4/Project4_data/outputdata/tatums_s.RData")


bars_start <- as.data.frame(bars_s)
set.seed(123)

ind <- sample(2350,350)


lyric[["train_c"]] <- TRUE
lyric[["train_c"]][ind] <- FALSE
lyric_train <- as.matrix(lyric[lyric[["train_c"]]==TRUE,1:(ncol(lyric)-1)])
lyric_test <- as.matrix(lyric[lyric[["train_c"]]==FALSE,1:(ncol(lyric)-1)])

#### main part
# do clustering to cluster songs to 5 parts based on features
# calculate the probability on each words(4973).  5*4973
install.packages("flexclust")
library(flexclust)
train_data_prob <- function(feature,num_cluster,lyric_train){
  # use kmeans to do clustering
  
  feature[["train"]] <- TRUE
  feature[["train"]][ind] <- FALSE
  set.seed(1)
  clus <- kcca(feature[feature[["train"]]==TRUE,1:(ncol(feature)-1)], 
               num_cluster, family=kccaFamily("kmeans"))
  pred_train <- predict(clus)
  lyric4label <- cbind(lyric_train,pred_train)
  
  result <- matrix(NA, nrow = num_cluster,ncol = (ncol(lyric4label)-1))
  
  for(i in 1:num_cluster){
    row <- lyric4label[,dim(lyric4label)[2]]==i
    temp <- lyric4label[row,1:(ncol(lyric4label)-1)]
    temp[temp > 0]<-1
    for(j in 1:(ncol(lyric4label)-1)){
      result[i,j] <- sum(temp[,j])/dim(temp)[1]
      if(result[i,j]==0){
        result[i,j] <- 0.0001
      }
    }
  }
  return(list("model"=clus,"result"=result))
}



# use features to calculate pro matrix
bars_result <- train_data_prob(bars_start,5,lyric_train)
beats_result <- train_data_prob(beats_start,5,lyric_train)
sections_result <- train_data_prob(sections_start,5,lyric_train)
segments_result <- train_data_prob(segments_start,5,lyric_train)
segments_l_m_result <- train_data_prob(segments_l_m,5,lyric_train)
#segments_l_m_t_result <- train_data_prob(segments_l_m_t,5,lyric_train)
segments_l_s_result <- train_data_prob(segments_l_s,5,lyric_train)
segments_p_result <- train_data_prob(segments_p,5,lyric_train)
segments_t_result <- train_data_prob(segments_t,5,lyric_train)
tatums_s_result <- train_data_prob(tatums_s,5,lyric_train)



# save the matrix
save(bars_result, file = paste(data_output_path, "/bars_result.RData", sep=""))
save(beats_result, file = paste(data_output_path, "/beats_result.RData", sep=""))
save(sections_result, file = paste(data_output_path, "/sections_result.RData", sep=""))
save(segments_result, file = paste(data_output_path, "/segments_result.RData", sep=""))
save(segments_l_m_result, file = paste(data_output_path, "/segments_l_m_result.RData", sep=""))
#save(segments_l_m_t_result, file = paste(data_output_path, "/segments_l_m_t_result.RData", sep=""))
save(segments_l_s_result, file = paste(data_output_path, "/segments_l_s_result.RData", sep=""))
save(segments_p_result, file = paste(data_output_path, "/segments_p_result.RData", sep=""))
save(segments_t_result, file = paste(data_output_path, "/segments_t_result.RData", sep=""))
save(tatums_s_result, file = paste(data_output_path, "/tatums_s_reuslt.RData", sep=""))


# a function to predict the cluster and calculate probability
################ use one feature to predict the cluster and calculate probability ################ 
feature <- bars_start
feature[["train"]] <- TRUE
feature[["train"]][ind] <- FALSE
new_feature<-feature[feature[["train"]]==FALSE,1:(ncol(feature)-1)]

test_data_prob <- function(newfeature,train_result){
  feature <- newfeature
  pred_test <- predict(train_result$model,newfeature)
  # it's a vector of labels for new data
  pred_prob <- matrix(NA, nrow = nrow(newfeature),ncol = 4973)
  for(i in 1:nrow(newfeature)){
    temp_clus <- pred_test[i]
    prob <- train_result$result[temp_clus,]
    pred_prob[i,] <- prob
    }
  return(list("cluster"=pred_test,"pred_prob"=pred_prob))
  }
  
test_prob<-test_data_prob(new_feature,bars_result)
  
prob_bars <- test_prob$pred_prob

# final result
rank_bars<-apply(-prob_bars,1,rank)
rank_bars <- round(rank_bars)
save(rank_bars,file = paste(data_output_path, "/rank_bars.RData", sep=""))
########### end of using one feature to predict the cluster and calculate probability ###########

############## combine all feature to predict the cluster and calculate probability ##############
feature <- bars_start
feature[["train"]] <- TRUE
feature[["train"]][ind] <- FALSE


new_feature<-feature[feature[["train"]]==FALSE,1:(ncol(feature)-1)]


test_data_prob <- function(newfeature,train_result){
  feature <- newfeature
  pred_test <- predict(train_result$model,newfeature)
  # it's a vector of labels for new data
  pred_prob <- matrix(NA, nrow = nrow(newfeature),ncol = 4973)
  for(i in 1:nrow(newfeature)){
    temp_clus <- pred_test[i]
    prob <- train_result$result[temp_clus,]
    pred_prob[i,] <- prob
  }
  return(list("cluster"=pred_test,"pred_prob"=pred_prob))
}

# 
prob1<-test_data_prob(new_feature,bars_result)
prob11 <- prob1$pred_prob
prob2<-test_data_prob(new_feature,beats_result)
prob22 <- prob2$pred_prob
prob3<-test_data_prob(new_feature,sections_result)
prob33 <- prob3$pred_prob
prob4<-test_data_prob(new_feature,segments_result)
prob44 <- prob4$pred_prob
prob5<-test_data_prob(new_feature,segments_l_m_result)
prob55 <- prob5$pred_prob
prob6<-test_data_prob(new_feature,segments_l_s_result)
prob66 <- prob6$pred_prob
prob7<-test_data_prob(new_feature,segments_p_result)
prob77 <- prob7$pred_prob
prob8<-test_data_prob(new_feature,segments_t_result)
prob88 <- prob8$pred_prob
prob9<-test_data_prob(new_feature,tatums_s_result)
prob99 <- prob9$pred_prob

all_feature_prob <-log(prob11)+log(prob22)+log(prob33)+log(prob44)+log(prob55)
all_feature_prob <-all_feature_prob+log(prob66)+log(prob77)+log(prob88)+log(prob99)

# final result
rank_all<-apply(-all_feature_prob,1,rank)
rank_all <- round(rank_all)
# dim(rank_bars) is 4973*350(then number of words*the number of testing songs)

save(rank_all,file = paste(data_output_path, "/rank_all.RData", sep=""))





