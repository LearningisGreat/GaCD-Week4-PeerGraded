

# Start by downloading the zip
download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", "w4zip.zip")

# Merges the training and the test sets to create one data set.

files_to_read <- c(
  "UCI HAR Dataset/test/X_test.txt", # Test set.
  "UCI HAR Dataset/train/X_train.txt", #Train set.
  "UCI HAR Dataset/features.txt", #List of all features.
  "UCI HAR Dataset/activity_labels.txt", #Links the class labels with their activity name.
  "UCI HAR Dataset/train/y_train.txt", # Training labels.
  "UCI HAR Dataset/test/y_test.txt", #Test labels. 
  "UCI HAR Dataset/test/subject_test.txt", #subjects test
  "UCI HAR Dataset/train/subject_train.txt") #subjects train
file_collection <- list()

for (i in files_to_read) {
  
file_collection[[i]] <-
  read.table(unzip(
    "w4zip.zip",
    files = i))
}


full_dataset <- rbind(file_collection[[1]], file_collection[[2]])
full_subjects <- rbind(file_collection[[7]], file_collection[[8]])



# ----------------------------------------------------------------

# 2. Extracts only the measurements on the mean and standard deviation for each measurement. 
# Name the columns, this is also the answer to point 4 in the assignment
names(full_dataset) <- file_collection[[3]]$V2

# add subjects to the dataset
full_dataset$Subject <- full_subjects$V1

sd_and_mean_index <- grepl("-std()|-mean()|Subject", names(full_dataset))
sd_and_mean <- full_dataset[,sd_and_mean_index]

# 3. Name the activities in the dataset
# ---------------------------------------------------------------

all_labels <- rbind(file_collection[[6]], file_collection[[5]])

sd_and_mean$Labels <- all_labels$V1
activity_labels <- file_collection[[4]]

sd_and_mean_activities_named <- merge(activity_labels, sd_and_mean, by.x = "V1", by.y = "Labels")

names(sd_and_mean_activities_named)[1:2] <-c("ActivityNumber", "ActivityDescription")

# Make the tidy dataset
# ---------------------------------------------------------------

# use the aggregate function to group by activity and subject, 
# then take the average of all measure columns using grepl to separate them out in the data.frame
tidy_data <- aggregate(sd_and_mean_activities_named[grepl("-std()|-mean()",names(sd_and_mean_activities_named))],
   list("Activity" =
     sd_and_mean_activities_named$ActivityDescription,
     "Subject" =
     sd_and_mean_activities_named$Subject
   ),
   mean)

write.table(tidy_data, "tiny_data", row.names = FALSE)
