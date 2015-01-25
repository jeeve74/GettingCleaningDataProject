##Getting and Cleansing Data Course Project
The documentation below provides details regarding the steps taken to collect and cleanse data sets in order 
to produce 2 tidy data sets that can be used for later analysis. 

This repo contains the following files required for the Course Project:
* CodeBook.md
* run_analysis.R

###Data Definitions
The data linked to from the course website represents data collected from the accelerometers from the Samsung Galaxy S smartphone. 
A full description is available at the site where the data was obtained http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones 
The data used for the project can be obtain from https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 

The version of the data used for this project was current as of 1/24/2015.
The code book for the two files generated for this project can be found in CodeBook.md https://github.com/jeeve74/GettingCleaningDataProject/blob/master/CodeBook.md 

###Data Gathering and Cleansing Steps
#### Read in the files 
1. downloaded https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
2. unzip downloaded file
3. read the following files into their respective data frames

	```dfMeasurements ./UCI HAR Dataset/features.txt```
	```dfActivities ./UCI HAR Dataset/activity_labels.txt```
	```dfTestSubjects ./UCI HAR Dataset/test/subject_test.txt```
	```dfTestMeasurements ./UCI HAR Dataset/test/X_test.txt```
	```dfTestActivities ./UCI HAR Dataset/test/y_test.txt```
	```dfTrainSubjects ./UCI HAR Dataset/train/subject_train.txt```
	```dfTrainActivities ./UCI HAR Dataset/train/y_train.txt```
	
	While reading in the text files, I assigned variable names. The variable names for dfTestMeasurements and dfTrainMeasurements
	came from dfMeasurements[,2]

#### Project Step 1: Merges the training and the test sets to create one data set.
4. Column Bind "TRAIN", dfTrainSubjects, dfTrainActivities, and dfTrainMeasurements. This will combine factors of SubjectKey and
	ActivityKey with their associated measures. The constant "TRAIN" is added as the first factor so that later it can be distinquished
	from "TEST" values.
5. Rename the variable for "TRAIN" to UsageType
6. Column Bind "TEST ", dfTestSubjects, dfTestActivities, and dfTestMeasurements. This will combine factors of SubjectKey and
	ActivityKey with their associated measures. The constant "TEST " is added as the first factor so that later it can be distinquished
	from "TRAIN" values.
7. Rename the variable for "TEST " to UsageType
8. Row Bind the data frames from 4 and 6
9. Column Bind a unique sequential number to the front of data frame from 8. This produces dfStep1. Since the data frame did not 
	have a unique identifier for each row, I generated one for it in this step.

#### Project Step 2: Extracts only the measurements on the mean and standard deviation for each measurement.
10. Store in a vector the names of dfStep1
11. Using grepl find the index for variables that are factors or are the mean and std measures. I did not interpret the meanFreq 
	and gravityMean measurements as being part of the mean measures being requested. Therefore, I excluded them.
12. Use the above index to filter the columns of dfStep2 to produce dfStep2.

#### Project Step 3: Uses descriptive activity names to name the activities in the data set
13. Merge the Activities data set with dfStep2 so that the data frame includes the activity name.
14. Now that ActivityName is in the data frame, I removed ActivityKey in order to keep the data tidy.

#### Project Step 4: Appropriately labels the data set with descriptive variable names.
15. Rearrange the columns so measurements are last
16. Change the data types of ObservationKey and SubjectKey to factors to make the data more meaningful.
17. Strip out extraneous periods in variable names to make the variable names more meaningful.
18. Assign the new names to the data frame to produce dfStep4
19. Make the following factors fixed width fields: ObservationKey, UsageType, SubjectKey, and ActivityName
20. Sort the dfStep4 by ObservationKey and write the result to a text file named SmartPhoneStdAndMean.txt

#### Project Step 5: From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
21. Discard first 2 columns (ObservationKey and UsageType) as they are no longer needed.
22. Group the data frame by SubjectKey, ActivityName and summarize data using the mean.
23. Rename the variable names to be more meaningful.
24. Sort the data frame by SubjectKey, ActivityName producing dfStep5. Write the result to a text file named SmartPhoneAverageBySubjectActivity.txt
	