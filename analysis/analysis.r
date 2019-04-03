library(data.table)
library(ggplot2)

read_block <- function(filename) {
  fread(filename)
}

read_subject <- function(foldername) {
  blk_names <- dir(foldername,  pattern = '*.csv', full.names = TRUE)
  res <- list()
  for (i in 1:length(blk_names)) {
    res[[i]] <- read_block(blk_names[i])
    base_name <- basename(blk_names[i])
    split_name <- strsplit(base_name, "(\\s+)|(?!-)(?=[[:punct:]])", perl = TRUE)[[1]]
    res[[i]]$subject <- as.character(res[[i]]$subject)
    res[[i]]$datetime <- split_name[1]
    res[[i]]$block <- as.numeric(gsub("[^0-9]", "", split_name[[5]]))
    res[[i]]$choices <- as.numeric(gsub("[^0-9]", "", split_name[[7]]))
    res[[i]]$trial <- 1:nrow(res[[i]])
  }
  rbindlist(res, use.names = TRUE, fill = TRUE)
}

read_all <- function(foldername) {
  subject_names <- dir(foldername, pattern='1*', full.names=TRUE)
  subject_names <- subject_names[!grepl('001', subject_names)] # remove dummy person
  res <- list()
  for (i in 1:length(subject_names)) {
    res[[i]] <- read_subject(subject_names[i])
  }
  rbindlist(res, use.name = TRUE)
}

dat <- read_all('~/python/adrian-mab/data')
dat <- dat[block != 0]

# max value per trial
cols <- as.character(0:25)
dat[, max_on_trial := do.call(max, list(.SD, na.rm=TRUE)), .SDcols = cols, .(subject, block, trial)]


ggplot(dat, aes(x = trial, y= choice, colour=subject)) + geom_point(size=0.5) + facet_grid(subject~block)