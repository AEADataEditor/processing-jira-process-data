# ###########################
# CONFIG: parameters affecting processing
# ###########################

## These control whether the external data is downloaded and processed.
process_raw <- TRUE
download_raw <- TRUE

## This pins the date of the to-be-processed file

extractday <- "12-09-2023"

## These define the start (and end) dates for processing of data
firstday <- "2022-12-01"
lastday  <- "2023-11-30"

# ###########################
# CONFIG: define paths and filenames for later reference
# ###########################

# Change the basepath depending on your system

basepath <- here::here()
setwd(basepath)



# for Jira stuff
jiraconf <- file.path(basepath,"data","confidential")

# for local processing
if ( Sys.getenv("HOSTNAME") == "zotique3" ) {
  jiraconf <- paste0(Sys.getenv("XDG_RUNTIME_DIR"),"/gvfs/dav:host=dav.box.com,ssl=true/dav/Office of AEA Data Editor/InternalData")
}
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

# Files

jira.conf.plus.rds <- file.path(jiraconf,"jira.conf.plus.RDS")
assignee.lookup.rds <- file.path(jiraconf,"assignee-lookup.RDS")
mc.lookup.rds       <- file.path(jiraconf,"mc-lookup.RDS")

