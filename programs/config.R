# ###########################
# CONFIG: parameters affecting processing
# ###########################

## These control whether the external data is downloaded and processed.
process_raw <- TRUE
download_raw <- TRUE

## This pins the date of the to-be-processed file

extractday <- "12-06-2022"

## These define the start (and end) dates for processing of data
firstday <- "2021-12-01"
lastday  <- "2022-11-30"

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
  jirconf <- paste0(Sys.getenv("XDG_RUNTIME_DIR"),"/gvfs/dav:host=dav.box.com,ssl=true/dav/Office of AEA Data Editor/InternalData")
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



####################################
# global libraries used everywhere #
####################################

mran.date <- "2022-04-22"
options(repos=paste0("https://cran.microsoft.com/snapshot/",mran.date,"/"))


pkgTest <- function(x)
{
  if (!require(x,character.only = TRUE))
  {
    install.packages(x,dep=TRUE)
    if(!require(x,character.only = TRUE)) stop("Package not found")
  }
  return("OK")
}

pkgTest.github <- function(x,source)
{
  if (!require(x,character.only = TRUE))
  {
    install_github(paste(source,x,sep="/"))
    if(!require(x,character.only = TRUE)) stop(paste("Package ",x,"not found"))
  }
  return("OK")
}

