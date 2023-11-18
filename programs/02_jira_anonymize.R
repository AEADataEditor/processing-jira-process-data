# Anonymize JIRA process files and construct variables
# Harry Son, Lars Vilhuber, Linda Wang
# 2021-05-20

## Inputs: export_(extractday).csv
## Outputs: file.path(jiraconf,"temp.jira.conf.RDS") file.path(jiraanon,"temp.jira.anon.RDS")


### Load libraries 
### Requirements: have library *here*
source(here::here("programs","config.R"),echo=TRUE)
if ( file.exists(here::here("programs","confidential-config.R"))) {
  source(here::here("programs","confidential-config.R"))
  # if not sourced, randomness will ensue
}
source(here::here("global-libraries.R"),echo=TRUE)


# double-check for existence of issue history file.

if (! file.exists(issues.file.csv)) {
  process_raw = FALSE
  print("Input file for anonymization not found - setting global parameter to FALSE")
}

if ( process_raw == TRUE ) {
  # Read in data extracted from Jira

  jira.conf.raw <- read.csv(issues.file.csv, stringsAsFactors = FALSE) %>%
    # the first field name can be iffy. It is the Key (sic)...
    rename(ticket=issue_key) %>%
    mutate(mc_number = sub('\\..*', '', Manuscript.Central.identifier)) 

  # anonymize mc_number
  jira.tmp <- jira.conf.raw %>% 
    select(mc_number) %>% 
    filter(mc_number!="") %>%
    distinct()  

  jira.manuscripts <- jira.tmp %>%
    mutate(rand = runif(nrow(jira.tmp))) %>%
    arrange(rand) %>%
    mutate(mc_number_anon = row_number()) %>%
    select(-rand) %>%
    arrange(mc_number)

  # Create anonymized Assignee number
  jira.assignees <- jira.conf.raw %>%
    select(Assignee) %>%
    filter(Assignee!="")  %>%
    filter(Assignee != "Automation for Jira") %>%
    filter(Assignee != "LV (Data Editor)") %>%
    distinct() %>%
    mutate(rand = runif(1),
           rand = if_else(Assignee=="Lars Vilhuber",0,rand)) %>%
    arrange(rand) %>%
    mutate(assignee_anon = row_number()) %>%
    select(-rand) %>%
    arrange(Assignee)
    
  
  # Save files
  saveRDS(jira.manuscripts,file=manuscript.lookup.rds)
  saveRDS(jira.assignees,  file=assignee.lookup.rds)
  
  # Now merge the anonymized data on
  jira.conf.plus <- jira.conf.raw %>% 
    left_join(jira.manuscripts,by="mc_number") %>%
    left_join(jira.assignees,by="Assignee") %>%
    #left_join(jira.assignees %>% rename(change.author.anon=assignee_anon),by=c("Change.Author"="Assignee"))
    # a few extra fields
    mutate(date_created = as.Date(substr(created, 1,10), "%Y-%m-%d"))
  
  # save anonymized and confidential data
  
  saveRDS(jira.conf.plus,
          file=jira.conf.plus.rds)
  
  
  #saveRDS(jira.conf.plus %>% select(-mc_number,-Assignee,-Change.Author),
  saveRDS(jira.conf.plus %>% select(-mc_number,-Assignee),
    file=file.path(jiraanon,"temp.jira.anon.RDS"))
  
} else { 
  print("Not processing anonymization due to global parameter.")
}
