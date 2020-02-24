# Anonymize JIRA process files
# Lars Vilhuber
# 2020-02-22

## Inputs: export_11-28-2019.csv
## Outputs: file.path(jiraanon,"jira.anon.RDS") and file.path(jiraanon,"jira.anon.csv")

### Cleans working environment.
#rm(list = ls())
#gc()

### Load libraries 
### Requirements: have library *here*
source(here::here("programs","config.R"),echo=TRUE)
global.libraries <- c("dplyr")
results <- sapply(as.list(global.libraries), pkgTest)

# double-check

if (! file.exists(file.path(jirabase,"export_11-28-2019.csv"))) {
  process_raw = FALSE
  print("Input file for anonymization not found - setting global parameter to FALSE")
}

if ( process_raw == TRUE ) {
# Read in data extracted from Jira
#base <- here::here()

jira.raw <- read.csv(file.path(jirabase,"export_11-28-2019.csv"), stringsAsFactors = FALSE) %>%
  rename(ticket = Key) %>%
  mutate(training = grepl("TRAINING", ticket, fixed = TRUE)) %>%
  filter(training == FALSE) %>%
  mutate(date_created = as.Date(substr(Created, 1,10), "%d/%m/%Y"),
         date = as.Date(substr(As.Of.Date, 1,10), "%d/%m/%Y"),
         mc_number = sub('\\..*', '', Manuscript.Central.identifier)) %>%
  filter(date_created >= "2019-07-16") %>%
  filter(! mc_number == "") %>%
  select(-training)

## Keep only variables needed

jira.conf <- jira.raw %>%
  select(ticket,date,mc_number,Journal,Status,Changed.Fields,Change.Author)

# anonymize
jira.tmp <- jira.conf %>% 
  select(mc_number) %>% distinct() 
jira.tmp <- jira.tmp %>%
  bind_cols(as.data.frame(runif(nrow(jira.tmp))))
names(jira.tmp)[2] <- c("rand")
jira.manuscripts <- jira.tmp %>%
  arrange(rand) %>%
  mutate(mc_number_anon = row_number()) %>%
  select(-rand) %>%
  arrange(mc_number)

# Same thing for Change.Author, except for Lars
jira.authors <- jira.conf %>%
  select(Change.Author) %>%
  distinct() 
jira.authors <- jira.authors %>%
  bind_cols(as.data.frame(runif(nrow(jira.authors))))
names(jira.authors)[2] <- c("rand")
jira.anon_authors <- jira.authors %>%
  arrange(rand) %>%
  mutate(Change.Author.Anon = if_else(Change.Author == "Lars Vilhuber",Change.Author,paste0("Author ",row_number()))) %>%
  select(-rand) %>%
  arrange(Change.Author)


# Now merge the anonymized data on
jira.conf %>% 
  left_join(jira.anon_authors,by="Change.Author") %>%
  select(-Change.Author) %>%
  left_join(jira.manuscripts,by="mc_number") %>%
  select(-mc_number) -> jira.anon

saveRDS(jira.anon,file=file.path(jiraanon,"jira.anon.RDS"))
write.csv(jira.anon,file=file.path(jiraanon,"jira.anon.csv"))

} else { 
  print("Not processing anonymization due to global parameter.")
  }
