# Getting and Cleaning Data Course Project

## Data Set Information

The dataset includes the following files:

- 'features_info.txt': Shows information about the variables used on the feature vector.

- 'features.txt': List of all features.

- 'activity_labels.txt': Links the class labels with their activity name.

- `train/X_train.txt`: Training set.

- `train/y_train.txt`: Training labels.

- `test/X_test.txt`: Test set.

- `test/y_test.txt`: Test labels.

- 'train(or test)/subject_train.txt': Each row identifies the subject who performed the activity for each window sample. Its range is from 1 to 30.

## Working Script explanation:

The first step is to check if the working directory and the .zipper file have already been downloaded and if not, download them:
```
if(!file.exists(targetFolder)){
    if(!file.exists(filename)){
        download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",
                      destfile = filename
        )
    }
    # Unzip the file
    unzip(filename)
```

The next step was to read all the necessary files within the Global Environment of the project
```
X_test <- read.table(file.path(targetFolder, "test", "X_test.txt"))
y_test <- read.table(file.path(targetFolder, "test", "y_test.txt"))
subject_test <- read.table(file.path(targetFolder, "test", "subject_test.txt"))

X_train <- read.table(file.path(targetFolder, "train", "X_train.txt"))
y_train <- read.table(file.path(targetFolder, "train", "y_train.txt"))
subject_train <- read.table(file.path(targetFolder, "train", "subject_train.txt"))
```

and rename the variables in each table. Earlier we put the labels inside the `y_test` and `y_train` datasets, so now we use them to rename variables. We also rename the variables indicating subjects as `Subject` and those of the activity IDs `ActivityID`.
```
colnames(X_train) = features[,2]
colnames(y_train) = "ActivityID"
colnames(subject_train) = "Subject"

colnames(X_test) = features[,2]
colnames(y_test) = "ActivityID"
colnames(subject_test) = "Subject"
```

1. Merges the training and the test sets to create one data set.
```
# Merging the train/test tables

test_full <- cbind(y_test, subject_test, X_test)
train_full <- cbind(y_train, subject_train, X_train)

# Merging all the data in one table

data_full <- rbind(test_full, train_full)
```

2. Extracts only the measurements on the mean and standard deviation for each measurement.
```
library(dplyr)

data_full_sub <- select(data_full, ActivityID, Subject, contains("mean"), contains("std()"))
```

3. Uses descriptive activity names to name the activities in the data set

As described above, the feature labels are contained in the file `activity_labels.txt`, so we first need to read this file into the `activityLabels` dataset
```
activityLabels <- read.table(file.path(targetFolder, "activity_labels.txt"))
```
Now we have to rename the column of this dataset. For practical reasons, we rename the column of the IDs of the activities as before, `ActivityID` and the column of the labels of the activities `Activity`.
Only then we can update the `ActivityID` column (which corresponds to the `data_full_sub[, 1]` column) with the labels (`activityLabels[,2]`):
```
activityLabels <- read.table(file.path(targetFolder, "activity_labels.txt"))
colnames(activityLabels) <- c("ActivityID", "Activity")

data_full_sub[, 1] <- activityLabels[data_full_sub[, 1], 2]
```

** Step 4, "Appropriately labels the data set with descriptive variable names" had already done before. 

5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
```
tidy_data <- data_full_sub %>%
    group_by(ActivityID, Subject) %>%
    summarise_all(funs(mean))
```

Finally, I created the `tidyDataset.txt` file which corresponds to the tidy data that can be used for later analysis.