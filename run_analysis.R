## Getting and Cleaning Data Course Project
## The below code downloads a zip file and then unzips the file
## The data in that file is then merged and cleansed into 2 tidy files based on the project specs
## The file CodeBook.md contains the data dictionary of the 2 tidy files and the steps taken
## for gathering the cleansing the data to produce the tidy files.
## The REARDME.md contains instructions on running this program.

library(dplyr)
rm(list = ls()) #cleans out all variables
dateDownloaded <- date()        #time the file was downloaded - initial date was 1/24/2015
dateDownloaded

## Download data file and unzip it
download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", destfile = "./getdata-projectfiles-UCI HAR Dataset.zip")
unzip("getdata-projectfiles-UCI HAR Dataset.zip")
# list.files(".")

## Read in the necessary datasets
dfMeasurements <- read.table("./UCI HAR Dataset/features.txt",sep="",col.names=c("MeasurementKey","MeasurementName"))
dfActivities <- read.table("./UCI HAR Dataset/activity_labels.txt",sep="",col.names=c("ActivityKey","ActivityName"))

dfTestSubjects <- read.table("./UCI HAR Dataset/test/subject_test.txt",col.names=c("SubjectKey"))
dfTestMeasurements <- read.table("./UCI HAR Dataset/test/X_test.txt",sep="",col.names=dfMeasurements[,2])
dfTestActivities <- read.table("./UCI HAR Dataset/test/y_test.txt",col.names=c("ActivityKey"))

dfTrainSubjects <- read.table("./UCI HAR Dataset/train/subject_train.txt",col.names=c("SubjectKey"))
dfTrainMeasurements <- read.table("./UCI HAR Dataset/train/X_train.txt",sep="",col.names=dfMeasurements[,2])
dfTrainActivities <- read.table("./UCI HAR Dataset/train/y_train.txt",col.names=c("ActivityKey"))


## 1. Merges the training and the test sets to create one data set.
dfTrain <- cbind("TRAIN",dfTrainSubjects,dfTrainActivities,dfTrainMeasurements) # combine 3 Train data sets
names(dfTrain)[1] <- "UsageType"
dfTest <- cbind("TEST ",dfTestSubjects,dfTestActivities,dfTestMeasurements) # combine 3 Test data sets
names(dfTest)[1] <- "UsageType"
dfTrainAndTest <- rbind(dfTrain,dfTest) # combind Train and Test data sets
index <- data.frame(ObservationKey=1:nrow(dfTrainAndTest))
dfStep1 <- cbind(index,dfTrainAndTest) # add unique rownumber to the data set


## 2. Extracts only the measurements on the mean and standard deviation for each measurement.
colNames1 <- names(dfStep1)
colIndex1 <- (grepl("std",colNames1) | grepl("mean",colNames1) | colNames1 %in% c("ObservationKey","UsageType","SubjectKey","ActivityKey")) & !(grepl("meanFreq",colNames1))
dfStep2 <- dfStep1[,colIndex1]


## 3. Uses descriptive activity names to name the activities in the data set
dfStep2Merged <- merge(dfStep2,dfActivities,by="ActivityKey")           # merge the Activities data set with dfStep2
dfStep3 <- dfStep2Merged[,!(names(dfStep2Merged)=="ActivityKey")]       # Remove the ActivityKey because ActivityName is now in table


## 4. Appropriately labels the data set with descriptive variable names.
# Rearrange the columns so measurements are last
# Then create more descriptive column names by removing redundate periods
colOrder <- c(1:3,70,4:69)
dfStep4 <- dfStep3[,colOrder]
dfStep4$ObservationKey <- as.factor(dfStep4$ObservationKey)     #  changing data type to make more meaningful
dfStep4$SubjectKey <- as.factor(dfStep4$SubjectKey)             #changing data type to make more meaningful
colNames3 <- names(dfStep4)
colNames3 <- gsub("[.][.][.]",".",colNames3)    # remove 3 consequitive periods
colNames3 <- gsub("[.][.]","",colNames3)        # remove ending periods
names(dfStep4) <- colNames3                     # assign new column names to data set

# Reformat character variables to fixed length strings
dfStep4$ObservationKey <- sprintf("% 5s", dfStep4$ObservationKey)
dfStep4$UsageType <- sprintf("%-5s", dfStep4$UsageType)
dfStep4$SubjectKey <- sprintf("% 2s", dfStep4$SubjectKey)
dfStep4$ActivityName <- sprintf("%-18s", dfStep4$ActivityName)
dfStep4 <- arrange(dfStep4,ObservationKey)              #sort by ObservationKey

write.table(dfStep4, file = "SmartPhoneStdAndMean.txt", sep = " ", row.name=FALSE)        #Write the data to txt file



# 5. From the data set in step 4, creates a second, independent tidy data set with the average of 
#       each variable for each activity and each subject.
dfGrouping <- dfStep4[,3:ncol(dfStep4)]                 #discard first 2 columns as they are no longer needed
dfMean <- dfGrouping %>%
        group_by(SubjectKey,ActivityName) %>%
        summarise_each(funs(mean(., na.rm = TRUE)))     #group and summarize data using the mean

names(dfMean) <- paste("mean.of.",names(dfGrouping),sep="")     #rename the variable names
names(dfMean)[1] <- "SubjectKey"
names(dfMean)[2] <- "ActivityName"
dfStep5 <- arrange(dfMean,SubjectKey,ActivityName)              #sort by SubjectKey, ActivityName

write.table(dfStep5, file = "SmartPhoneAverageBySubjectActivity.txt", sep = " ", row.name=FALSE)        #Write the data to txt file


