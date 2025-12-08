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
    # Some corrections
    mutate(mc_number = case_when(
      substr(Manuscript.Central.identifier,1,4) == "aer." ~ str_replace(Manuscript.Central.identifier,".","-"),
      substr(Manuscript.Central.identifier,1,4) == "pol." ~ str_replace(Manuscript.Central.identifier,".","-"),
      substr(Manuscript.Central.identifier,1,4) == "app." ~ str_replace(Manuscript.Central.identifier,".","-"),
      TRUE ~  mc_number
    )) %>%
    filter(Issue.Type == "Task") %>%
    # Possibly temporary issue?
    filter(ticket == Key.1) %>%
    select(-Key.1) %>%
    filter(str_detect(ticket,"AEAREP"))
  
  # We need to remove all sub-tasks of AEAREP-1407
placeholders <- jira.conf.raw %>% filter(ticket =="AEAREP-1407") %>%
               select(ticket,Sub.tasks) %>%
               separate_longer_delim(Sub.tasks,delim=",") %>%
               mutate(Sub.tasks = str_trim(Sub.tasks)) %>%
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
                 "save it in ",jirameta, " as \"description_anon.csv\", then run again."))
  
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
  message("=============================================")
  message("Saving lookup tables for JIRA anonymization.")
  saveRDS(jira.manuscripts,file=manuscript.lookup.rds)
  saveRDS(jira.assignees,  file=assignee.lookup.rds)
  message("=============================================")
  # Read in `description_anon.csv`, and from the `name`column, construct code that will keep only those variables listed in the `name` column

  # Read in the anonymization file
  public_names <- read_csv(file.path(jirameta,"description_anon.csv")) %>%
    filter(name!="") %>%
    select(name) %>%
    pull()
  extra_conf <- c("Manuscript.Central.identifier", "mc_number", "Assignee", "openICPSR.Project.Number","RepositoryDOI")

  # Now merge the anonymized data on, keep & rename relevant variables
  jira.conf.all <- jira.conf.cleaned %>% 
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
    rename(External.party.name.conf = External.party.name,
           External.party.name = External.party.clean) 


##   filter out subtasks
jira.conf.subtask <- jira.conf.all %>%
  filter(subtask != "") %>%
  select(ticket, subtask) %>%
  separate_longer_delim(subtask,delim=",") %>%
  mutate(subtask = str_trim(subtask)) %>%
  select(ticket = subtask) %>%
  distinct()

jira.conf.plus <- jira.conf.all %>%
  filter(!is.na(mc_number_anon)) %>%
  anti_join(jira.conf.subtask) %>%
  select(all_of(public_names),all_of(extra_conf))

  
  # save anonymized and confidential data
  message("=============================================")
  message("Saving anonymized and confidential JIRA data.")
  saveRDS(jira.conf.plus,
          file=jira.conf.plus.rds)

  saveRDS(jira.conf.plus %>% 
            select(all_of(public_names)),
    file=file.path(jiraconf,"temp.jira.anon.RDS"))
  message("=============================================")
  message("Reading back in anonymized JIRA data for checking.")
  jira.anon <- readRDS(file.path(jiraconf,"temp.jira.anon.RDS"))

  print(skim(jira.anon))
  message("=============================================")



} else { 
  print("Not processing anonymization due to global parameter.")
}
