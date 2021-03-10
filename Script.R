targetFolder <- 'UCI HAR Dataset'
filename <- 'UCI_HAR_Dataset.zip'

# checking for data directory/file and creating it if it doesn’t exist

if(!file.exists(targetFolder)){
    if(!file.exists(filename)){
        download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",
                      destfile = filename
        )
    }
    # Unzip the file
    unzip(filename)
}

# 1. Merges the training and the test sets to create one data set.

# Create tables from txt's
X_test <- read.table(file.path(targetFolder, "test", "X_test.txt"))
y_test <- read.table(file.path(targetFolder, "test", "y_test.txt"))
subject_test <- read.table(file.path(targetFolder, "test", "subject_test.txt"))

X_train <- read.table(file.path(targetFolder, "train", "X_train.txt"))
y_train <- read.table(file.path(targetFolder, "train", "y_train.txt"))
subject_train <- read.table(file.path(targetFolder, "train", "subject_train.txt"))

# Rename the columns
features <- read.table(file.path(targetFolder, "features.txt"))

colnames(X_train) = features[,2]
colnames(y_train) = "ActivityID"
colnames(subject_train) = "Subject"

colnames(X_test) = features[,2]
colnames(y_test) = "ActivityID"
colnames(subject_test) = "Subject"

# Merging the train/test tables

test_full <- cbind(y_test, subject_test, X_test)
train_full <- cbind(y_train, subject_train, X_train)

# Merging all the data in one table

data_full <- rbind(test_full, train_full)

# 2. Extracts only the measurements on the mean and standard deviation for each measurement.
library(dplyr)

data_full_sub <- select(data_full, ActivityID, Subject, contains("mean"), contains("std()"))

# 3. Uses descriptive activity names to name the activities in the data set

activityLabels <- read.table(file.path(targetFolder, "activity_labels.txt"))
colnames(activityLabels) <- c("ActivityID", "Activity")

data_full_sub[, 1] <- activityLabels[data_full_sub[, 1], 2]

# 4. Appropriately labels the data set with descriptive variable names.

# Already done before. See `Rename the columns`

# 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

tidy_data <- data_full_sub %>%
    group_by(ActivityID, Subject) %>%
    summarise_all(funs(mean))

write.table(tidy_data, file = "tidyDataset.txt", row.names = FALSE)
