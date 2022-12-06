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
global.libraries <- c("dplyr","tidyr","splitstackshape")
results <- sapply(as.list(global.libraries), pkgTest)


jira.conf.plus <- readRDS(file=file.path(jiraconf,"jira.conf.plus.RDS"))

lab.member <- jira.conf.plus %>%
  filter(Change.Author!=""&Change.Author!="Automation for Jira"&Change.Author!="LV (Data Editor)") %>%
  mutate(date_created = as.Date(substr(Created, 1,10), "%m/%d/%Y")) %>%
  filter(date_created >= firstday, date_created < lastday) %>%
  mutate(name=Change.Author) %>%
  cSplit("Change.Author"," ")  %>%
  filter(ifelse(is.na(Change.Author_2),1,0)==0) %>%
  filter(!name %in% c("Lars Vilhuber","Michael Darisse","Sofia Encarnacion")) %>%
  distinct(name) 

write.table(lab.member, file = file.path(basepath,"data","replicationlab_members.txt"), sep = "\t",
            row.names = FALSE)
