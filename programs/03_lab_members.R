# Export lab members worked during the designated period.
# Harry Son
# 2021-03-14

## Inputs: export_12-22-2020.csv
## Outputs: file.path(basepath,"data","replicationlab_members.txt")

### Cleans working environment.
rm(list = ls())
gc()

### Load libraries 
### Requirements: have library *here*
source(here::here("programs","config.R"),echo=TRUE)
source(here::here("global-libraries.R"),echo=TRUE)


name.exclusions <- c("Lars Vilhuber","Michael Darisse","Sofia Encarnacion", "Linda Wang","Automation for Jira","LV (Data Editor)")

jira.conf.plus <- readRDS(file=jira.conf.plus.rds)

lab.member <- jira.conf.plus %>%
  filter(! Assignee %in% name.exclusions ) %>%
  filter(date_created >= firstday, date_created < lastday) %>%
  cSplit("Assignee"," ")  %>%
  filter(ifelse(is.na(Assignee_2),1,0)==0) %>%
  distinct(Assignee) 

write.table(lab.member, file = members.txt, sep = "\t",
            row.names = FALSE)

### Repeat process for external replicators
external.member <- jira.conf.plus %>%
  filter(External.party.name!="") %>%
  mutate(date_created = as.Date(substr(Created, 1,10), "%m/%d/%Y")) %>%
  filter(date_created >= firstday, date_created < lastday) %>%
  mutate(name_external=External.party.name) %>%
  cSplit("name_external",",",direction="long")  %>%
  distinct(name_external) 

write.table(external.member, file = file.path(basepath,"data","external_replicators.txt"), sep = "\t",
            row.names = FALSE)
