##Load the needed libraries
library(data.table)
library(dplyr)

##Name the file
filename <- "dataset.zip"
##See if file exists already
if (!file.exists(filename)){
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(fileURL, filename, method="curl")
}  
##See if data has been downloaded previously
if (!file.exists("UCI HAR Dataset")) { 
  unzip(filename) 
}

##Put data into data frames
Features <- read.table("UCI HAR Dataset/Features.txt", col.names = c("FnNo","Functions"))
ActivityLabels <- read.table("UCI HAR Dataset/activity_labels.txt", col.names = c("CodeNo", "Activity"))
TestSubject <- read.table("UCI HAR Dataset/test/subject_test.txt", col.names = "Subject")
Test <- read.table("UCI HAR Dataset/test/X_test.txt", col.names = Features$Functions)
TestActivities <- read.table("UCI HAR Dataset/test/y_test.txt", col.names = "CodeNo")
TrainSubject <- read.table("UCI HAR Dataset/train/subject_train.txt", col.names = "Subject")
Train <- read.table("UCI HAR Dataset/train/X_train.txt", col.names = Features$Functions)
TrainActivities <- read.table("UCI HAR Dataset/train/y_train.txt", col.names = "CodeNo")

##Merge the training and the test sets to create one data set
X_Data <- rbind (Train, Test)
Y_Data <- rbind (TrainActivities, TestActivities)
Subject_Data <- rbind(TrainSubject, TestSubject)
Merged_Data <- cbind(Subject_Data, Y_Data, X_Data)

##Extract only measurements on the mean and standard deviation for each measurement
NeededData <- Merged_Data %>% select(Subject, CodeNo, contains("mean"), contains("std"))

##Use descriptive activity names to name the activities in the data set
NeededData$CodeNo <- ActivityLabels[NeededData$CodeNo, 2]

##Appropriately label the data set with descriptive variable names
names(NeededData)[2] = "Activity"
names(NeededData) <- gsub("Acc", "Accelerometer", names(NeededData), ignore.case = TRUE)
names(NeededData) <- gsub("BodyBody", "Body", names(NeededData), ignore.case = TRUE)
names(NeededData) <- gsub("^f", "Frequency", names(NeededData), ignore.case = TRUE)
names(NeededData) <- gsub("Gyro", "Gyroscope", names(NeededData), ignore.case = TRUE)
names(NeededData) <- gsub("Mag", "Magnitude", names(NeededData), ignore.case = TRUE)
names(NeededData) <- gsub("-mean()", "Mean", names(NeededData), ignore.case = TRUE)
names(NeededData) <- gsub("-std()", "StD", names(NeededData), ignore.case = TRUE)
names(NeededData) <- gsub("^t", "Time", names(NeededData), ignore.case = TRUE)

##From NeededData, create a second, independent tidy data set with the average of each variable for each activity and each subject
TidyData <- NeededData %>%
  group_by(Subject, Activity) %>%
  summarize_all(list(mean))
write.table(TidyData, "tidy_data.txt", row.name=FALSE)