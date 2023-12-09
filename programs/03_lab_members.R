# Export lab members worked during the designated period.
# Harry Son, Lars Vilhuber
# 2021-03-14

## Inputs: jira.assignees.Rds
## Outputs: file.path(basepath,"data","replicationlab_members.txt")



### Load libraries 
### Requirements: have library *here*
source(here::here("programs","config.R"),echo=TRUE)
source(here::here("global-libraries.R"),echo=TRUE)


name.exclusions <- c("Lars Vilhuber","Michael Darisse","Sofia Encarnacion",
                     "Linda Wang","Automation for Jira","LV (Data Editor)")


if (! file.exists(jira.conf.plus.rds)) {
  process_raw = FALSE
  warning("Input file with confidential information not found - setting global parameter to FALSE")
}

if ( process_raw == TRUE ) {
  jira.conf.plus <- readRDS(file=jira.conf.plus.rds)
  
  lab.member <- jira.conf.plus %>%
    filter(! Assignee %in% name.exclusions ) %>%
    filter(Assignee != "") %>%
    filter(date_created >= firstday, date_created < lastday) %>%
    distinct(Assignee) 
  
  write.table(lab.member, file = members.txt, sep = "\t",
              row.names = FALSE)
  
  ### Repeat process for external replicators
  external.member <- jira.conf.plus %>%
    filter(External.party.name!="") %>%
    filter(date_created >= firstday, date_created < lastday) %>%
    mutate(name_external=External.party.name) %>%
    distinct(name_external) 
  
  write.table(external.member, file = file.path(basepath,"data","external_replicators.txt"), sep = "\t",
              row.names = FALSE)
}