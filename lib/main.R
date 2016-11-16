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
# save the matrix
save(bars_result, file = paste(data_output_path, "/bars_result.RData", sep=""))



# a function to predict the cluster and calculate probability#
# 5* 4973 matrix. input    350*4973

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


