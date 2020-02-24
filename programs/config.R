# ###########################
# CONFIG: parameters affecting processing
# ###########################

process_raw <- FALSE


# ###########################
# CONFIG: define paths and filenames for later reference
# ###########################

# Change the basepath depending on your system

basepath <- here::here()
setwd(basepath)

# Main directories

# for Jira stuff
jirabase <- file.path(basepath,"data","confidential")
jiraanon <- file.path(basepath,"data","anon")
jirameta <- file.path(basepath,"data","metadata")

# local
images <- file.path(basepath, "images" )
tables <- file.path(basepath, "tables" )
programs <- file.path(basepath,"programs")

for ( dir in list(images,tables,programs)){
  if (file.exists(dir)){
  } else {
    dir.create(file.path(dir))
  }
}

set.seed(20200201)

####################################
# global libraries used everywhere #
####################################

# Not using it here
# mran.date <- "2019-09-01"
# options(repos=paste0("https://cran.microsoft.com/snapshot/",mran.date,"/"))


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

