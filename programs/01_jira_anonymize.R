# Anonymize JIRA process files and construct variables
# Harry Son, Lars Vilhuber
# 2021-05-20

## Inputs: export_(extractday).csv
## Outputs: file.path(jiraconf,"temp.jira.conf.RDS") file.path(jiraanon,"temp.jira.anon.RDS")

### Cleans working environment.
rm(list = ls())
gc()

### Load libraries 
### Requirements: have library *here*
source(here::here("programs","config.R"),echo=TRUE)
if ( file.exists(here::here("programs","confidential-config.R"))) {
  source(here::here("programs","confidential-config.R"))
  # if not sourced, randomness will ensue
}
global.libraries <- c("dplyr","tidyr","splitstackshape")
results <- sapply(as.list(global.libraries), pkgTest)

# double-check
exportfile <- paste0("export_",extractday,".csv")

if (! file.exists(file.path(jiraconf,exportfile))) {
  process_raw = FALSE
  print("Input file for anonymization not found - setting global parameter to FALSE")
}

if ( process_raw == TRUE ) {
  # Read in data extracted from Jira
  #base <- here::here()
  
  jira.conf.raw <- read.csv(file.path(jiraconf,exportfile), stringsAsFactors = FALSE) %>%
    rename(ticket=Key) %>%
    mutate(mc_number = sub('\\..*', '', Manuscript.Central.identifier)) 
  
  # anonymize mc_number
  jira.tmp <- jira.conf.raw %>% 
    select(mc_number) %>% 
    filter(mc_number!="") %>%
    distinct()  
  
  jira.tmp <- jira.tmp %>%
    bind_cols(as.data.frame(runif(nrow(jira.tmp))))
  names(jira.tmp)[2] <- c("rand")
  
  # keep matched MC number and the anonymized MC number 
  jira.manuscripts <- jira.tmp %>%
    arrange(rand) %>%
    mutate(mc_number_anon = row_number()) %>%
    select(-rand) %>%
    arrange(mc_number)
  
  # Create anonymized Assignee number
  jira.assignees1 <- jira.conf.raw %>%
    select(Assignee) %>%
    filter(Assignee!="") 
  jira.assignees2 <- jira.conf.raw %>%
    select(Assignee=Change.Author) %>%
    filter(Assignee!="") 
  
  jira.assignees <- bind_rows(jira.assignees2,jira.assignees1)%>%
    filter(Assignee!="Automation for Jira") %>%
    filter(Assignee!="LV (Data Editor)") %>%
    distinct() 
  jira.assignees <- jira.assignees %>%
    bind_cols(as.data.frame(runif(nrow(jira.assignees))))
  names(jira.assignees)[2] <- c("rand")
  jira.assignees <- jira.assignees %>%
    mutate(rand = if_else(Assignee=="Lars Vilhuber",0,rand)) %>%
    arrange(rand) %>%
    mutate(assignee_anon = row_number()) %>%
    select(-rand) %>%
    arrange(Assignee)
    
  
  # Save files
  saveRDS(jira.manuscripts,file=file.path(jiraconf,"mc-lookup.RDS"))
  saveRDS(jira.assignees,file=file.path(jiraconf,"assignee-lookup.RDS"))
  
  # Now merge the anonymized data on
  jira.conf.plus <- jira.conf.raw %>% 
    left_join(jira.manuscripts,by="mc_number") %>%
    left_join(jira.assignees,by="Assignee") %>%
    left_join(jira.assignees %>% rename(change.author.anon=assignee_anon),by=c("Change.Author"="Assignee"))
  
  # save anonymized and confidential data
  
  saveRDS(jira.conf.plus,
          file=file.path(jiraconf,"jira.conf.plus.RDS"))
  
  
  saveRDS(jira.conf.plus %>% select(-mc_number,-Assignee,-Change.Author),
    file=file.path(jiraanon,"temp.jira.anon.RDS"))
  
} else { 
  print("Not processing anonymization due to global parameter.")
}
