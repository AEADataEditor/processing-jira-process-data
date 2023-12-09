# Anonymize JIRA process files and construct variables
# Harry Son, Lars Vilhuber
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


# double-check
exportfile <- paste0("export_",extractday,".csv")

if (! file.exists(file.path(jiraconf,exportfile))) {
  process_raw = FALSE
  print("Input file for anonymization not found - setting global parameter to FALSE")
}

if ( process_raw == TRUE ) {
  # Read in data extracted from Jira
  
  jira.conf.raw <- read.csv(file.path(jiraconf,exportfile), stringsAsFactors = FALSE) %>%
    rename(ticket=1) %>%
    filter(Issue.Type == "Task") %>%
    filter(str_detect(ticket,"AEAREP")) %>%
    select(-Change.Author)
  # We need to remove all sub-tasks of AEAREP-1407
  
placeholders <- jira.conf.raw %>% filter(ticket =="AEAREP-1407") %>%
               select(ticket,Sub.tasks) %>%
               separate_longer_delim(Sub.tasks,delim=",") %>%
               select(ticket = Sub.tasks) %>%
               distinct()

  # now do an anti_join
  jira.conf.cleaned <- jira.conf.raw %>%
    # the first field name can be iffy. It is the Key (sic)...
    mutate(mc_number = sub('\\..*', '', Manuscript.Central.identifier))  %>%
    anti_join(placeholders)
  
  # anonymize mc_number
  jira.manuscripts <- jira.conf.cleaned %>% 
    select(mc_number) %>% 
    filter(mc_number!="") %>%
    distinct()   %>%
    mutate(rand = runif(1)) %>%
    arrange(rand) %>%
    mutate(mc_number_anon = row_number()) %>%
    select(-rand) %>%
    arrange(mc_number)
  
  # Create anonymized Assignee number
  jira.assignees <- jira.conf.cleaned %>%
    select(Assignee) %>%
    filter(Assignee!="") %>%
    filter(Assignee!="Automation for Jira") %>%
    filter(Assignee!="LV (Data Editor)") %>%
    distinct() %>%
    mutate(rand = runif(1),
           rand = if_else(Assignee=="Lars Vilhuber",0,rand)) %>%
    arrange(rand) %>%
    mutate(assignee_anon = row_number()) %>%
    select(-rand) %>%
    arrange(Assignee)
    
  
  # Save files
  saveRDS(jira.manuscripts,file=mc.lookup.rds)
  saveRDS(jira.assignees,file=assignee.lookup.rds)
  
  # Now merge the anonymized data on
  jira.conf.plus <- jira.conf.cleaned %>% 
    left_join(jira.manuscripts,by="mc_number") %>%
    left_join(jira.assignees,by="Assignee") %>%
    mutate(date_created = as.Date(substr(Created, 1,10), "%m/%d/%Y"),
           date_asof    = as.Date(substr(As.Of.Date, 1,10), "%m/%d/%Y"))
  
  # save anonymized and confidential data
  
  saveRDS(jira.conf.plus,
          file=jira.conf.plus.rds)
  
  
  saveRDS(jira.conf.plus %>% 
            select(-mc_number,-Assignee),
    file=file.path(jiraanon,"temp.jira.anon.RDS"))
  
} else { 
  print("Not processing anonymization due to global parameter.")
}
