######################################################################################################################
###
### Coursera - John Hopkins University
### Data Science Specialisation Track
### Getting and Cleaning Data
###
### Stephen Coward
### May 2015
###
### Week 3 - Lectures
###
### Getting and Cleaning Data Course Project
### ----------------------------------------
###
### Script:             run_analysis.R
### Description:        This script performs the steps on the UCI Human Activity Recognition Using Smartphones 
###                     Data Set
###
###                     1. Merges the training and the test sets to create one data set.
###                     2. Extracts only the measurements on the mean and standard deviation for each measurement. 
###                     3. Uses descriptive activity names to name the activities in the data set
###                     4. Appropriately labels the data set with descriptive variable names. 
###                     5. From the data set in step 4, creates a second, independent tidy data set with the average of 
###                        each variable for each activity and each subject.
###
### Data:               https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
###
######################################################################################################################


######################################################################################################################
### Read in the data - training and test data sets
######################################################################################################################

### Note: The data should reside in a folder called 'data', in the working directory.

features <- read.table(file = "data/UCI HAR Dataset/features.txt", colClasses = "character")

### convert the names in the 2nd column of the features DF to a vector - this will be required for naming the columns in
### the training and test data sets.
varNames <- as.vector(features[,2]) 

### Column names for the Labels and Subject data sets
varLabel <- c("activityID")
varSubject <- c("subject")


### Read in all source data, and setting column names
activityLabels <- read.table(file = "data/UCI HAR Dataset/activity_labels.txt", 
                             col.names = c("activityID", "activityName"))

trainingSet <- read.table(file = "data/UCI HAR Dataset/train/X_train.txt", col.names = varNames)
trainingLabels <- read.table(file = "data/UCI HAR Dataset/train/y_train.txt", col.names = varLabel)
trainingSubject <- read.table(file = "data/UCI HAR Dataset/train/subject_train.txt", col.names = varSubject)

testSet <- read.table(file = "data/UCI HAR Dataset/test/X_test.txt", col.names = varNames)
testLabels <- read.table(file = "data/UCI HAR Dataset/test/y_test.txt", col.names = varLabel)
testSubject <- read.table(file = "data/UCI HAR Dataset/test/subject_test.txt", col.names = varSubject)



######################################################################################################################
### Merge the training and the test sets to create one data set.
######################################################################################################################

### Combine the columns for the subject, labels and training set for the training data
trainingDF <- cbind(trainingSubject, trainingLabels, trainingSet)

### Combine the columns for the subject, labels and test set for the test data
testDF <- cbind(testSubject, testLabels, testSet)

### Combine the rows for the training and test data sets
activityDF <- rbind(trainingDF, testDF)


######################################################################################################################
### Extract only the measurements on the mean and standard deviation for each measurement
######################################################################################################################

library(dplyr) ## load the dplyr package


measuresMeanSTD <- tbl_df(select(activityDF, 1:2, 
                                 contains("mean", ignore.case = FALSE), contains("std", ignore.case = FALSE)))


#######################################################################################################################
### Use descriptive activity names to name the activities in the data set
#######################################################################################################################

### Merge the measuresMeanSTD data set with the activityLabels data set to get the activity names
### Note: include the argument sort = FALSE, to prevent the merge function reordering the data
activityMeasures <- 
        merge(measuresMeanSTD, activityLabels, by = "activityID", sort = FALSE) %>%
        select(activityName, subject, 3:81)    


### Clean Up: remove objects to free up memory
rm(list = c("features", "trainingDF", "testDF", 
            "trainingSubject", "trainingLabels", "trainingSet", 
            "testSubject", "testLabels", "testSet",
            "activityDF", "measuresMeanSTD"))


#######################################################################################################################
### From the activityMeasures data set, create a second independent tidy data set with the average of each variable for 
### each activity and each subject.
#######################################################################################################################

measuresByActivitySubject <-
        activityMeasures %>%
        group_by(activityName, subject) %>%
        summarise_each(funs(mean))

### Output the tidy data set to the current working directory using write.table
write.table(measuresByActivitySubject, file = "./measuresByActivitySubject.txt", row.names = FALSE)
