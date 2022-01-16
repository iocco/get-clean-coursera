# get-clean-coursera
Getting and Cleaning Data Course Project

To download and unzip the original data run

```
source("run_analysis.R")
downloadAndUnzip()
```

Then to get the data, run

```
data <- cleanData()
```

That data will include only the necessary columns, to get the final `tidy dataset.txt` file, which includes means of every feature grouped by `participant` and `activity`

```
summarise_data_and_write(data)
```