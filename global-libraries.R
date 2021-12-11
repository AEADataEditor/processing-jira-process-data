
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


global.libraries <- c("dplyr","stringr","tidyr","knitr","readr","here","splitstackshape")
results <- sapply(as.list(global.libraries), pkgTest)