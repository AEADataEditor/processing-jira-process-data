# ###########################
# CONFIG: parameters affecting processing
# ###########################

## These control whether the external data is downloaded and processed.
process_raw <- TRUE
download_raw <- TRUE

## These define the start (and end) dates for processing of data
firstday <- "2019-12-01"
lastday  <- "2020-11-30"

# ###########################
# CONFIG: define paths and filenames for later reference
# ###########################

# Change the basepath depending on your system

basepath <- here::here()
setwd(basepath)



# for Jira stuff
jirabase <- file.path(basepath,"data","jira","confidential")
jiraanon <- file.path(basepath,"data","jira","anon")
manual   <- file.path(basepath,"data","manual")

# for openICPSR stuff
icpsrbase <- file.path(basepath,"data","icpsr")

# local
images <- file.path(basepath, "images" )
tables <- file.path(basepath, "tables" )
programs <- file.path(basepath,"programs")
temp   <- file.path(basepath,"data","temp")


# parameters
latexnums.Rda <- file.path(tables,"latexnums.Rda")
latexnums.tex <- file.path(tables,"latexnums.tex")

for ( dir in list(images,tables,programs,temp)){
  if (file.exists(dir)){
  } else {
    dir.create(file.path(dir))
  }
}

set.seed(20201201)


####################################
# global libraries used everywhere #
####################################

mran.date <- "2021-01-01"
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


## Initialize a file that will be used at the end to write out LaTeX parameters for in-text 
## reference

pkgTest("tibble")
if (file.exists(latexnums.Rda)) {
  print(paste0("File for export to LaTeX found: ",latexnums.Rda))
} else {
  latexnums <- tibble(field="version",value=as.character(date()),updated=date())
  saveRDS(latexnums,latexnums.Rda)
}

update_latexnums <- function(field,value) {
  # should test if latexnums is in memory
  latexnums <- readRDS(latexnums.Rda)
  
  # find out if a field exists
  if ( any(latexnums$field == field) ) {
    message("Updating existing field")
    latexnums[which(latexnums$field == field), ]$value <- as.character(value)
    latexnums[which(latexnums$field == field), ]$updated <- date()
    #return(latexnums)
  } else {
    message("Adding new row")
    latexnums <- latexnums %>% add_row(field=field,value=as.character(value),updated=date())
    #return(latexnums)
  }
  saveRDS(latexnums,latexnums.Rda)
}
