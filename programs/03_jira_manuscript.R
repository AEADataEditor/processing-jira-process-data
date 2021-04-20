# Preserve some confidential data for internal analysis
# Lars Vilhuber, Harry Son
# 2021-02-17

## Inputs: file.path(jirabase,"temp.mc.number.RDS"))
##         file.path(jiraanon,"jira.anon.RDS")
## Outputs: 
### file.path(jirabase,"jira.conf.RDS") and file.path(jirabase,"jira.conf.csv")


### Load libraries 
### Requirements: have library *here*source(here::here("programs","config.R"),echo=TRUE)
global.libraries <- c("dplyr","tidyr")
results <- sapply(as.list(global.libraries), pkgTest)

# double-check

# Read in data extracted from Jira
#base <- here::here()
jira.manuscripts <- readRDS(file.path(jirabase,"temp.mc.number.RDS"))

## Now merge the MC number, and save a confidential file for internal use
jira.anon <- readRDS(file=file.path(jiraanon,"jira.anon.RDS"))

jira.conf <- jira.anon %>% 
  left_join(jira.manuscripts,by="mc_number_anon")

saveRDS(jira.conf,file=file.path(jirabase,"jira.conf.RDS"))
write.csv(jira.conf,file=file.path(jirabase,"jira.conf.csv"))

# not documented for external use
