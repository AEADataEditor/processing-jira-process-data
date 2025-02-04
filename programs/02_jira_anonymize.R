# Anonymize JIRA process files and construct variables
# Harry Son, Lars Vilhuber, Linda Wang, Takshil Sachdev
# 2021-05-20

## Inputs: export_(extractday).csv
## Outputs: file.path(jiraconf,"temp.jira.conf.RDS") file.path(jiraanon,"temp.jira.anon.RDS")

### Load libraries 
### Requirements: have library *here*

source(here::here("programs","config.R"),echo=TRUE)
if ( file.exists(here::here("programs","confidential-config.R"))) {
  source(here::here("programs","confidential-config.R"))
  message("Confidential config found.")
  # if not sourced, randomness will ensue
}
source(here::here("global-libraries.R"),echo=TRUE)

exportfile <- paste0(issue_history.prefix,extractday,".csv")

# double-check for existence of issue history file.

if (! file.exists(file.path(jiraconf,exportfile))) {
  process_raw = FALSE
  print("Input file for anonymization not found - setting global parameter to FALSE")
}

if ( process_raw == TRUE ) {
  # Read in data extracted from Jira


  jira.conf.raw <- read.csv(file.path(jiraconf,exportfile), stringsAsFactors = FALSE) %>%
    # the first field name can be iffy. It is the Key (sic)...
    rename(ticket=Key) %>%
    mutate(mc_number = sub('\\..*', '', Manuscript.Central.identifier))  %>%
    filter(Issue.Type == "Task") %>%
    filter(str_detect(ticket,"AEAREP"))
  
  # We need to remove all sub-tasks of AEAREP-1407
placeholders <- jira.conf.raw %>% filter(ticket =="AEAREP-1407") %>%
               select(ticket,Sub.tasks) %>%
               separate_longer_delim(Sub.tasks,delim=",") %>%
               select(ticket = Sub.tasks) %>%
               distinct()

  # now do an anti_join
  jira.conf.cleaned <- jira.conf.raw %>%
    anti_join(placeholders)
  
  # Fix External Party Name
  jira.conf.cleaned$External.party.clean <- sapply(jira.conf.cleaned$External.party.name, function(x) {
    if (grepl("\\[|\\]", x)) {
      gsub("\\[|\\]|'", "", x)
    } else {
      x
    }
  })
  
  # Write out names as currently captured to TEMP
  names(jira.conf.raw) %>% as.data.frame() -> tmp
  names(tmp) <- c("Name")
  write_excel_csv(tmp,file=file.path(temp,jira.conf.names.csv),col_names = TRUE)

  warning(paste0("If you need to edit the names to be included,\n",
                 "edit the file ",file.path(temp,jira.conf.names.csv),"\n",
                 "save it in ",jirameta, "with the same name, ran run again."))
  
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
  saveRDS(jira.manuscripts,file=manuscript.lookup.rds)
  saveRDS(jira.assignees,  file=assignee.lookup.rds)
  
  # Now merge the anonymized data on, keep & rename relevant variables
  jira.conf.plus <- jira.conf.cleaned %>% 
    left_join(jira.manuscripts,by="mc_number") %>%
    left_join(jira.assignees,by="Assignee") %>%
    mutate(date_created = as.Date(substr(Created, 1,10), "%Y-%m-%d"),
           date_asof    = as.Date(substr(As.Of.Date, 1,10), "%Y-%m-%d")) %>%
    rename(reason.failure=Reason.for.Failure.to.be.Fully.Reproduced) %>%
    rename(external=External.validation) %>%
    rename(subtask=Sub.tasks) %>%
    mutate(date_resolved = as.Date(substr(Resolved, 1,10), "%Y-%m-%d"))%>%
    mutate(received = ifelse(Status=="Open","Yes","No")) %>%
    mutate(has_subtask=ifelse(subtask!="","Yes","No")) %>%
    select(ticket, Manuscript.Central.identifier, mc_number, mc_number_anon, MCStatus, Status, received, Changed.Fields,
           MCRecommendation, MCRecommendationV2, Created, As.Of.Date, Resolved, date_created, date_asof, date_resolved, 
           Assignee, assignee_anon, Journal, Software.used, Issue.Type, subtask, has_subtask, Agreement.signed, 
           Update.type, reason.failure, external, External.party.clean, Non.compliant, DCAF_Access_Restrictions,
           openICPSR.Project.Number, Resolution)%>%
    rename(External.party.name = External.party.clean)
  
  # save anonymized and confidential data
  
  saveRDS(jira.conf.plus,
          file=jira.conf.plus.rds)

  saveRDS(jira.conf.plus %>% 
            select(-Manuscript.Central.identifier,-mc_number,-Assignee),
    file=file.path(jiraanon,"temp.jira.anon.RDS"))
  
} else { 
  print("Not processing anonymization due to global parameter.")
}
