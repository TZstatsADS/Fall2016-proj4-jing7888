# Project: Words 4 Music

### [Project Description](doc/Project4_desc.md)

![image](http://cdn.newsapi.com.au/image/v1/f7131c018870330120dbe4b73bb7695c?width=650)

Term: Fall 2016

+ [Data link](https://courseworks2.columbia.edu/courses/11849/files/folder/Project_Files?preview=763391)-(**courseworks login required**)
+ [Data description](doc/readme.html)
+ Contributor's name: Jingjing Feng
+ Projec title: Music and text mining
+ Project summary: In this project, I used H5 file and lyrics of 2350 songs to build an model to predict the probability of 5000 words. I used the 10 features from the H5 file and used K means to do clustering using these features. Then we can rank the probabilities of the words in each cluster.
**Steps:

+ Step 1: The first step is to extract features from H5 files. I use all of the feathers in Group “analysis” except songs and every feathers related to confidence. Then I saved those features indivisually instead of combining them togather as just one vector.

+ Step 2: The second part is about feature engineering. After extracting all the features needed, I did some feature engineering, such as trying to make every feature in different songs has the same dimension, and finding missing values and setting them all to zero. Then I saved all the features to Rdata for further calculation.

+ Step 3: After these two steps, I divided data to training part and testing part. For the training dataset, I applied KNN to cluster songs to 5 parts based on features. And then calculate the probability of the appearance of each word in each cluster using training dataset. The probability of a specific word in a specific cluster is defined as: how many songs the word appears in / the number of the songs in this cluster. In my code, the number of the clusters can be changed, that is to say, the code is general enough to be used to meet different requirments.

+ Step 4: The final step is to use features from the testing dataset to predict the cluster and calculate the probability of each words. Then we can rank all the words based on their probability. Actually, I combined the result calculated by all the features together to make use of as much information as I can.


**How to run my code: 

+ Given H5 files of music, use the feature_extract.R to extract features from all the H5 file. Then use the main.R to calculate the rank of the probabilities of all the words.

Following [suggestions](http://nicercode.github.io/blog/2013-04-05-projects/) by [RICH FITZJOHN](http://nicercode.github.io/about/#Team) (@richfitz). This folder is orgarnized as follows.

```
proj/
├── lib/
├── data/
├── doc/
├── figs/
└── output/
```

Please see each subfolder for a README file.
