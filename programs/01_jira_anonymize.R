# Anonymize JIRA process files and construct variables
# Harry Son
# 2021-02-17

## Inputs: export_12-22-2020.csv
## Outputs: file.path(jirabase,"temp.jira.conf.RDS") file.path(jiraanon,"temp.jira.anon.RDS")

### Cleans working environment.
rm(list = ls())
gc()

### Load libraries 
### Requirements: have library *here*
source(here::here("programs","config.R"),echo=TRUE)
global.libraries <- c("dplyr","tidyr","splitstackshape")
results <- sapply(as.list(global.libraries), pkgTest)

# double-check

if (! file.exists(file.path(jirabase,"export_12-22-2020.csv"))) {
  process_raw = FALSE
  print("Input file for anonymization not found - setting global parameter to FALSE")
}

if ( process_raw == TRUE ) {
  # Read in data extracted from Jira
  #base <- here::here()
  
  jira.conf.raw <- read.csv(file.path(jirabase,"export_12-22-2020.csv"), stringsAsFactors = FALSE) %>%
    rename(ticket=Key) %>%
    mutate(mc_number = sub('\\..*', '', Manuscript.Central.identifier)) 
  
  # anonymize
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
  
  saveRDS(jira.manuscripts,file=file.path(jirabase,"temp.mc.number.RDS"))
  
  # Now merge the anonymized data on
  jira.conf.raw <- jira.conf.raw %>% 
    left_join(jira.manuscripts,by="mc_number") %>%
    select(-mc_number) -> temp.jira.anon
  
  saveRDS(temp.jira.anon,file=file.path(jiraanon,"temp.jira.anon.RDS"))
  
} else { 
  print("Not processing anonymization due to global parameter.")
}
