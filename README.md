# Getting and Cleaning Data - Course Project
Stephen Coward  
24/05/2015  



This is the repository containing the code or performing analysis on the [UCI HAR data set][1], as part of the Course Project (Getting and Cleaning Data - via Coursera).

The data is from experiments relating to Human Activity Recognition Using Smartphones Data - [further information][2]


## Project Overview

The purpose of this project is to demonstrate the ability to collect, work with, and clean a data set. The goal is to prepare tidy data that can be used for later analysis. 

**Outputs:**   
1. A tidy data set as described below (task summary) 
2. A  link to a Github repository with your script for performing the analysis
3. A code book that describes the variables, the data, and any transformations or work that was performed to clean up the data called CodeBook.md. You should also include a README.md in the repo with the script. 


## Task Summary

1. Merges the training and the test sets to create one data set.
2. Extracts only the measurements on the mean and standard deviation for each measurement. 
3. Uses descriptive activity names to name the activities in the data set
4. Appropriately labels the data set with descriptive variable names. 
5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.


## Steps

1. Download and extract the extract the [data set][1] to folder named "data" in your current working directory.
2. Run the R scrip - 'run_analysis.R'


### run_analysis.R:

The script performs all the required tasks to merge, clean and output a tidy data set ready for analysis   

**Read in the data - training and test data sets**

*Note: Appropriate labels were sourced from the features.txt file, and applied to the column names via the read.table functions - this aids readability and minimises any confusion when preparing the data in later steps* 


```r
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
```

  
**Merge the training and the test sets to create one data set.**

This step combines all the training related data sets into one data set; then combines all the test related data sets into one data set; and finally combines both the training and test data sets into one consolidated data set consisting of all activity recognistion data.  


```r
### Combine the columns for the subject, labels and training set for the training data
trainingDF <- cbind(trainingSubject, trainingLabels, trainingSet)

### Combine the columns for the subject, labels and test set for the test data
testDF <- cbind(testSubject, testLabels, testSet)

### Combine the rows for the training and test data sets
activityDF <- rbind(trainingDF, testDF)
```

  
**Extract only the measurements on the mean and standard deviation for each measurement**

Reduce the data set, to retain only the variables required for creation of the final tidy data set. This consists of only the measurements on the mean abnd standard deviation for each measurement, along with the activity id and subject.  


```r
library(dplyr) ## load the dplyr package
```

```
## 
## Attaching package: 'dplyr'
## 
## The following object is masked from 'package:stats':
## 
##     filter
## 
## The following objects are masked from 'package:base':
## 
##     intersect, setdiff, setequal, union
```

```r
measuresMeanSTD <- tbl_df(select(activityDF, 1:2, 
                                 contains("mean", ignore.case = FALSE), contains("std", ignore.case = FALSE)))
```

  
**Use descriptive activity names to name the activities in the data set**

Add descriptive names for the activities, to replace the integer values, which on there own are not self explanatory.  


```r
### Merge the measuresMeanSTD data set with the activityLabels data set to get the activity names
### Note: include the argument sort = FALSE, to prevent the merge function reordering the data
activityMeasures <- 
        merge(measuresMeanSTD, activityLabels, by = "activityID", sort = FALSE) %>%
        select(activityName, subject, 3:81)    
```



  
**From the activityMeasures data set, create a second independent tidy data set with the average of each variable for each activity and each subject.**   

The tidy data meets the principles of tidy data, also discussed in the course [forum][3] and laid out by [Hadley Wickham][4] in his [paper][5].  
The resulting data set, has the average (mean) value for each of the measures grouped by activity and subject.  


```r
measuresByActivitySubject <-
        activityMeasures %>%
        group_by(activityName, subject) %>%
        summarise_each(funs(mean))
```

  
**Output the tidy data set to your current working directory**

The final tidy set is output as a text file to the current working directory.  


```r
write.table(measuresByActivitySubject, file = "./measuresByActivitySubject.txt", row.names = FALSE)
```



[1]: https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "Human Activity Recognition Smartphone Data"
[2]: http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones "UCI Machine Learning Repository - Human Activity Recognition Using Smartphones Data Set"
[3]: https://class.coursera.org/getdata-014/forum/thread?thread_id=31 "Tidy data and the Assignment"
[4]: http://had.co.nz/ "Website of Hadley Wickham"
[5]: http://vimeo.com/33727555 "Journal of Statistical Software - Tidy Data"
