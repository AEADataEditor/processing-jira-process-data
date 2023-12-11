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
#base <- here::here()

jira.anon.raw <- readRDS(file.path(jiraanon,"temp.jira.anon.RDS")) %>%
  rename(reason.failure=Reason.for.Failure.to.be.Fully.Reproducible) %>%
  rename(external=External.validation) %>%
  rename(subtask=Sub.tasks) %>%
  mutate(date_created = as.Date(substr(Created, 1,10), "%m/%d/%Y"),
         date_resolved = as.Date(substr(Resolved, 1,10), "%m/%d/%Y"),
         date_updated = as.Date(substr(As.Of.Date, 1,10), "%m/%d/%Y")) %>%
  mutate(received = ifelse(Status=="Open","Yes","No")) %>%
  mutate(has_subtask=ifelse(subtask!="","Yes","No")) %>%
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
  anti_join(jira.conf.subtask) %>%
  select(ticket,date_created,date_updated,mc_number_anon,Journal,Status,
         Software.used,received,Changed.Fields,external,Resolution,reason.failure,MCStatus,
         MCRecommendation,MCRecommendationV2)

## export it as a csv file
saveRDS(jira.anon,file=file.path(jiraanon,"jira.anon.RDS"))
write.csv(jira.anon,file=file.path(jiraanon,"jira.anon.csv"))

