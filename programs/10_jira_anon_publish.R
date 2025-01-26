# Anonymize JIRA process files and construct variables
# Harry Son
# 2021-02-17

## Inputs: file.path(jirbase,"temp.jira.conf.RDS"), 
## Outputs: 
### file.path(jirabase,"jira.conf.RDS") and file.path(jirabase,"jira.conf.csv")

### Cleans working environment.

### Load libraries 
### Requirements: have library *here*

source(here::here("programs","config.R"),echo=TRUE)
source(here::here("global-libraries.R"),echo=TRUE)

# double-check

# Read in data extracted from Jira

jira.anon.raw <- readRDS(file.path(jiraanon,"temp.jira.anon.RDS")) %>%
  filter(ticket!="AEAREP-365") %>% # duplicate with aearep-364
  filter(ticket!="AEAREP-1589")  ## Decision notice of aearep-1523

## object to filter out subtasks
jira.conf.subtask <- jira.anon.raw %>%
  filter(subtask != "") %>%
  select(ticket, subtask) %>%
  separate_longer_delim(subtask,delim=",") %>%
  select(ticket = subtask) %>%
  distinct()

jira.anon <- jira.anon.raw %>%
  filter(!is.na(mc_number_anon)) %>%
  anti_join(jira.conf.subtask) 

## export it as a csv file
saveRDS(jira.anon,jira.anon.rds)
write.csv(jira.anon,jira.anon.csv)

