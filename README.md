# Project: Words 4 Music

### [Project Description](doc/Project4_desc.md)

![image](http://cdn.newsapi.com.au/image/v1/f7131c018870330120dbe4b73bb7695c?width=650)

Term: Fall 2016

+ [Data link](https://courseworks2.columbia.edu/courses/11849/files/folder/Project_Files?preview=763391)-(**courseworks login required**)
+ [Data description](doc/readme.html)
+ Contributor's name: Jingjing Feng
+ Projec title: Music and text mining
+ Project summary: In this project, I used H5 file and lyrics of 2350 songs to build an model to predict the probability of 5000 words. I used the 10 features from the H5 file and used K means to do clustering using these features. Then we can rank the probabilities of the words in each cluster.

+ How to run this code: Given H5 files of music, use the feature_extract.R to extract features from all the H5 file. Then use the main.R to calculate the rank of the probabilities of all the words.

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
