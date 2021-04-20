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
global.libraries <- c("dplyr","tidyr","splitstackshape")
results <- sapply(as.list(global.libraries), pkgTest)

# double-check

# Read in data extracted from Jira
#base <- here::here()

jira.anon.raw <- readRDS(file.path(jiraanon,"temp.jira.anon.RDS")) %>%
  rename(reason.failure=Reason.for.Failure.to.Fully.Replicate) %>%
  rename(external=External.validation) %>%
  rename(subtask=Sub.tasks) %>%
  mutate(training = grepl("TRAINING", ticket, fixed = TRUE)) %>%
  filter(training == FALSE) %>% # filter out training cases
  filter(Issue.Type=="Task") %>% # leave issue type "Task"
  mutate(date_created = as.Date(substr(Created, 1,10), "%m/%d/%Y"),
         date_resolved = as.Date(substr(Resolved, 1,10), "%m/%d/%Y"),
         date_updated = as.Date(substr(As.Of.Date, 1,10), "%m/%d/%Y")) %>%
  mutate(received = ifelse(Status=="Open"&Change.Author=="","Yes","No")) %>%
  mutate(has_subtask=ifelse(subtask!="","Yes","No")) %>%
  filter(! date_updated=="2020-12-22") %>% #export is counted as an action, drop
  filter(ticket!="AEAREP-365") %>% # duplicate with aearep-364
  filter(ticket!="AEAREP-1589") %>% ## Decision notice of aearep-1523
  select(-training) 

## object to filter out subtask
jira.conf.subtask <- jira.anon.raw %>%
  select(ticket, subtask) %>%
  cSplit("subtask",",")  %>%
  distinct() %>%
  pivot_longer(!ticket, names_to = "n", values_to = "value") %>%
    mutate(subtask=ifelse(!value=="","Yes","No")) %>%
  select(subtask,value) %>%
  rename(ticket=value) 

jira.anon <- jira.anon.raw %>%
  select(ticket, mc_number_anon) %>%
  distinct(ticket, .keep_all = TRUE) %>%
  filter(mc_number_anon!=is.na(mc_number_anon)) %>%
  left_join(jira.anon.raw,by="ticket") %>%
  select(-subtask) %>%
  left_join(jira.conf.subtask) %>%
  select(-mc_number_anon.y) %>%
  rename(mc_number_anon=mc_number_anon.x) %>%
  select(ticket,date_created,date_updated,mc_number_anon,Journal,Status,
         Software.used,received,Changed.Fields,external,subtask,Resolution,reason.failure,
         MCRecommendation,MCRecommendationV2)

## export it as a csv file
saveRDS(jira.anon,file=file.path(jiraanon,"jira.anon.RDS"))
write.csv(jira.anon,file=file.path(jiraanon,"jira.anon.csv"))

