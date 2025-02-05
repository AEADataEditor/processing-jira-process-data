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
source(here::here("global-libraries.R"),echo=TRUE)

# double-check

# Read in the anonymization file
  public_names <- read_csv(file.path(jirameta,"description_anon.csv")) %>%
    filter(name!="") %>%
    select(name) %>%
    pull()

# Read in data extracted from Jira

jira.anon.raw <- readRDS(file.path(jiraconf,"temp.jira.anon.RDS")) %>%
  filter(ticket!="AEAREP-365") %>% # duplicate with aearep-364
  filter(ticket!="AEAREP-1589")  %>%  ## Decision notice of aearep-1523
  select(all_of(public_names))

## export it as a csv file
saveRDS(jira.anon,jira.anon.rds)
write.csv(jira.anon,jira.anon.csv)

