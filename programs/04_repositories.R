# Export primary Repository usage
# Lars Vilhuber
# 2025-12-07

## Inputs: jira.conf.plus.RDS
## Outputs: file.path(basepath,"data","repository-usage.csv")

source(here::here("programs","config.R"),echo=TRUE)
if ( file.exists(here::here("programs","confidential-config.R"))) {
  source(here::here("programs","confidential-config.R"))
  # if not sourced, randomness will ensue
}
source(here::here("global-libraries.R"),echo=TRUE)


if (! file.exists(jira.conf.plus.rds)) {
  process_raw = FALSE
  error("Input file with confidential information not found - exiting")
}

repo.conf.plus <- readRDS(jira.conf.plus.rds) %>%
  filter(Status == "Done" & RepositoryDOI != "") %>%
  select(RepositoryDOI,ticket,Status,As.Of.Date)
  
repo.distinct <- repo.conf.plus %>%
  # keep the latest by As.Of.Date
  arrange(ticket, desc(As.Of.Date)) %>%
  group_by(ticket) %>%
  slice_head(n = 1) %>%
  ungroup() %>%
  distinct(RepositoryDOI,ticket)

# Check if there are duplicates for same ticket - should not be
dups <- repo.distinct %>%
  group_by(ticket) %>%
  filter(n()>1)

if ( nrow(dups) > 0 ) {
  error("There are multiple tickets entries for the same ticket. Will keep latest.")
}

# drop the ticket number

repo.distinct.anon <- repo.distinct %>%
  distinct(RepositoryDOI)

# While this is only the public Repository DOI, it is still
# for some as-of-yet unpublished cases, since we have not filtered for history here. For now, we keep this private.

# parse the repository DOIs
repo.use <- repo.distinct.anon %>%
  # strip out the doi.org part, keep the prefix
  mutate(DOI = str_remove(RepositoryDOI,"^https://doi.org/")) %>%
  separate(DOI, into=c("doi_prefix","doi_suffix"), sep="/", extra="merge") 

repo.use.table <- repo.use %>%
  group_by(doi_prefix) %>%
  mutate(usage_count = n()) 

# List DOIs for those not at openICPSR
repo.use.table %>% 
  filter(doi_prefix != "10.3886")

# Save the summary table
repo.use.releasable <- repo.use %>%
  group_by(doi_prefix) %>%
  summarize(usage_count = n()) 

saveRDS(repo.use.releasable,file=file.path(jiraanon,"repository-usage.Rds"))
write.csv(repo.use.releasable, file = file.path(basepath,"data","repository-usage.csv"), 
            row.names = FALSE)
