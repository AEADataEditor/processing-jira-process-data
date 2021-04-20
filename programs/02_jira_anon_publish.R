# Anonymize JIRA process files and construct variables
# Harry Son
# 2021-02-17

## Inputs: file.path(jirbase,"temp.jira.conf.RDS"), 
## Outputs: 
### file.path(jirabase,"jira.conf.RDS") and file.path(jirabase,"jira.conf.csv")
### file.path(jiraanon,"jira.anon.RDS") and file.path(jiraanon,"jira.anon.csv")

### Cleans working environment.

### Load libraries 
### Requirements: have library *here*
source(here::here("programs","config.R"),echo=TRUE)
global.libraries <- c("dplyr","tidyr","splitstackshape","codebook")
results <- sapply(as.list(global.libraries), pkgTest)

# double-check

# Read in data extracted from Jira
#base <- here::here()
jira.manuscripts <- readRDS(file.path(jirabase,"temp.mc.number.RDS"))

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

## Now merge the MC number
jira.conf <- jira.anon %>% 
  left_join(jira.manuscripts,by="mc_number_anon")

saveRDS(jira.conf,file=file.path(jirabase,"jira.conf.RDS"))
write.csv(jira.conf,file=file.path(jirabase,"jira.conf.csv"))

## Create codebook
var_label(jira.anon) <- list(
  ticket	="The tracking number within the system. Project specific. Sequentially assigned upon receipt.",
  date_created=	"Date of a receipt",
  date_updated=	"Date of a transaction",
  Journal=	"Journal associated with an issue and manuscript. Derived from the manuscript number. Possibly updated by hand",
  Status=	"Status associated with a ticket at any point in time. The schema for these has changed over time. ",
  Changed.Fields=	"A transaction will change various fields. These are listed here.",
  Software.used=	"A list of software used to replicate the issue.",
  received=	"An indicator for whether the issue is just created and has not been assigned to a replicator yet.",
  external=	"An indicator for whether the issue required the external validation.",
  subtask=	"An indicator for whether the issue is a subtask of another task.",
  Resolution=	"Resolution associated with a ticket at the end of the replication process.",
  reason.failure=	"A list of reasons for failure to fully replicate.",
  MCRecommendation=	"Decision status when the issue is Revise and Resubmit.",
  MCRecommendationV2=	"Decision status when the issue is conditionally accepted.",
  mc_number_anon=	"The (anonymized) number assigned by the editorial workflow system (Manuscript Central/ ScholarOne) to a manuscript. This is purged by a script of any revision suffixes."
)

codebook <- codebook_table(jira.anon) %>%
  select(name, label)

write.csv(codebook,file=file.path(basepath,"data","jira","metadata","description_anon.csv"))
