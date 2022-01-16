##
## To start the script, downloads the data and unzips it
##
downloadAndUnzip <- function() {
  download.file(url="https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", 
                destfile = "dataset.zip", method="curl")
  unzip("dataset.zip", overwrite = FALSE)
}

##
## Main function of the script, gets the data from the files, 
## merges it and filters the desired columns
##
cleanData <- function() {
  library(dplyr) ## Loads library to perform table operations
  library(stringr) ## for str_replace
  
  test <- readFilesFromFolder("test")
  train <- readFilesFromFolder("train")
  
  total <- rbind(test, train) ## add both sources
  
  ## gets name of the columns and give change to more readable names
  features <- sapply(readColNames(), cleanNames) 
  total <- updateColNames(total, features)
  
  ## Translate name of activity to label values
  total$activity <- apply(total["y_field"], 1, translateActivity)
  
  ## Filters only mean and std columns
  filterOnlyMeanAndStd(total)
}

## Groups by activity and participant and summarise the mean for the other columns.
## data -> cleaned table
summarise_data_and_write <- function(data) {
  gp <- group_by(data, activity, participant)
  tidy <- summarise_all(gp, mean)
  write.table(tidy, file="tidy dataset.txt", row.names = FALSE)
}

## switch function for activity labels
## value -> value of the activity column
translateActivity <- function(value) {
  switch (value, "WALKING", "WALKING_UPSTAIRS", "WALKING_DOWNSTAIRS", 
          "WALKING_DOWNSTAIRS","SITTING","STANDING", "LAYING")
}

## Select only desired columns, mean, std, participants and activity
## data -> dataFrame
filterOnlyMeanAndStd <- function(data) {
  columns <- colnames(data)
  filtered_col <- columns[grepl("(_mean$|_std$|participant|activity)", columns)]
  select(data, filtered_col)
}

## Read all the content from a folder and merges it on a table
## folder -> name of the folder, could be "test" or "train"

readFilesFromFolder <- function(folder) {
  subject <- read.csv(
    file.path("UCI HAR Dataset", folder, paste("subject_", folder, ".txt", sep = "")),
    header = FALSE)
  x <- read.fwf(
    file.path("UCI HAR Dataset", folder, paste("X_", folder, ".txt",  sep="")),
              widths = rep(16, 561), header = FALSE)
  y <- read.csv(
    file.path("UCI HAR Dataset", folder, paste("y_", folder, ".txt", sep="")),
    header = FALSE)
  x$participant <- subject["V1"]
  x$y_field <- y["V1"]
  x
}

## Changes names for the names of the features
## data -> table 
## features -> vector of names from the file
updateColNames <- function(data, features) {
  new_names <- append(features, c("participant", "y_field"))
  colnames(data) <- new_names
  data
}

## makes the columns more readable
## x-> a columns
cleanNames <- function(x) {
  x %>% 
    str_replace_all("mean()", "_mean") %>% 
    str_replace_all("std()", "_std") %>% 
    str_replace_all("\\(\\)", "") %>% 
    str_replace_all("-", "_") %>% 
    str_replace_all(",", "_") %>% 
    str_replace_all("\\(", "_") %>% 
  str_replace_all("\\)", "")
}

## Read all the features from file, which will be used as column names
##
readColNames <- function() {
  features <- read.csv("UCI HAR Dataset/features.txt", sep = " ", header = FALSE)
  features[,2]
}
