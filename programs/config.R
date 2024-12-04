# ###########################
# CONFIG: parameters affecting processing
# ###########################

## These control whether the external data is downloaded and processed.
process_raw <- TRUE
download_raw <- TRUE

## This pins the date of the to-be-processed file

extractday <- "2024-12-04"

## These define the start (and end) dates for processing of data
firstday <- "2023-12-01"
lastday  <- "2024-11-30"

# ###########################
# CONFIG: define paths and filenames for later reference
# ###########################

# Change the basepath depending on your system

basepath <- here::here()
setwd(basepath)

# for Jira stuff
jiraconf <- file.path(basepath,"data","confidential")

# for local processing
jiraanon <- file.path(basepath,"data","anon")
jirameta <- file.path(basepath,"data","metadata")

# local
images <- file.path(basepath, "images" )
tables <- file.path(basepath, "tables" )
programs <- file.path(basepath,"programs")
temp   <- file.path(basepath,"data","temp")


for ( dir in list(images,tables,programs,temp)){
  if (file.exists(dir)){
  } else {
    dir.create(file.path(dir))
  }
}

# filenames
issue_history.prefix <- "issue_history_"
manuscript.lookup     <- "mc-lookup"
manuscript.lookup.rds <- file.path(jiraconf,paste0(manuscript.lookup,".RDS"))

assignee.lookup       <- "assignee-lookup"
assignee.lookup.rds   <- file.path(jiraconf,paste0(assignee.lookup,".RDS"))

# this is the augmented confidential file with all the non-confidential variables
jira.conf.plus.base   <- "jira.conf.plus"
jira.conf.plus.rds    <- file.path(jiraconf,paste0(jira.conf.plus.base,".RDS"))

jira.conf.names.csv   <- "jira_conf_names.csv"

# public files
members.txt <- file.path(jiraanon,"replicationlab_members.txt")

jira.anon.base <- "jira.anon"
jira.anon.rds  <- file.path(jiraanon,paste0(jira.anon.base,".RDS"))
jira.anon.csv  <- file.path(jiraanon,paste0(jira.anon.base,".csv"))


#mc.lookup.rds       <- file.path(jiraconf,"mc-lookup.RDS")

