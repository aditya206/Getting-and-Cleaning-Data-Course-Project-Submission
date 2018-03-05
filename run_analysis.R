#Start of with loading the dplyr package
library(dplyr)
#Creating a directory named data within the working directory
if(!file.exists("./data")){
  dir.create("./data")
}

fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./data/Dataset.zip")

# Unzip dataSet to /data directory
unzip(zipfile="./data/Dataset.zip",exdir="./data")

#Reading of training and testing data sets
X_train<-read.table("./data/UCI HAR Dataset/train/X_train.txt",sep = "")
Y_train<-read.table("./data/UCI HAR Dataset/train/y_train.txt",sep = "")
subject_train<-read.table("./data/UCI HAR Dataset/train/subject_train.txt",sep = "")

X_test<-read.table("./data/UCI HAR Dataset/test/X_test.txt",sep = "")
Y_test<-read.table("./data/UCI HAR Dataset/test/y_test.txt",sep = "")
subject_test<-read.table("./data/UCI HAR Dataset/test/subject_test.txt",sep = "")

#Reading feature vector and activity labels vector
features <- read.table("./data/UCI HAR Dataset/features.txt",sep="")
activityLabels = read.table("./data/UCI HAR Dataset/activity_labels.txt",sep="")

#Assigning column names:
colnames(subject_train)<-"VolunteerId"
colnames(X_train)<-features$V2 
colnames(Y_train)<-"activityId"

colnames(subject_test)<-"VolunteerId"
colnames(X_test)<-features$V2 
colnames(Y_test)<-"activityId"

colnames(activityLabels) <- c("activityId","activityType")

#Merging of Training Data into one dataset using cbind
merge_training<-cbind(Y_train,subject_train,X_train)
merge_testing<-cbind(Y_test, subject_test, X_test)
CmbndData<-rbind(merge_training,merge_testing)

#Creating a character vector of Column Names and then creating a logical vector containing certain keywords
colNames <- colnames(CmbndData)
MeanStd<-grepl("activityId|VolunteerId|mean|std",colNames)

#Subsetting the Combined Data using the logical vector
subset_MeanStd <- CmbndData[,MeanStd]

#Merging with activityLables dataset to give descriptive activity names
MeanStd_withNames<-merge(subset_MeanStd,activityLabels,by="activityId")

#Creating a second dataset with the mean of each variable for each activity and each subject
aggdata<-aggregate(MeanStd_withNames,by=list(MeanStd_withNames$VolunteerId,MeanStd_withNames$activityId),mean)
aggdata <- aggdata[order(aggdata$VolunteerId, aggdata$activityId),]
aggdata<-aggdata[,-(1:2)]

#Writing the data to a text file
write.table(aggdata,"second_TidySet.txt",row.names = FALSE)
