# Export lab members worked during the designated period.
# Harry Son, Lars Vilhuber
# 2021-03-14

## Inputs: jira.conf.plus.RDS
## Outputs: file.path(basepath,"data","replicationlab_members.txt")

source(here::here("programs","config.R"),echo=TRUE)
if ( file.exists(here::here("programs","confidential-config.R"))) {
  source(here::here("programs","confidential-config.R"))
  # if not sourced, randomness will ensue
}
source(here::here("global-libraries.R"),echo=TRUE)

exclusions <- c("Lars Vilhuber","Michael Darisse","Sofia Encarnacion", "Linda Wang",
                "Leonel Borja Plaza","User ","Takshil Sachdev","Jenna Kutz Farabaugh",
                "LV (Data Editor)")

# This contains unmapped IDs that need to be cleaned up

lookup <- read_csv(file.path(jirameta,"assignee-name-lookup.csv"))
removal <- read_csv(file.path(jirameta,"assignee-remove.csv"))

jira.conf.plus <- readRDS(jira.conf.plus.rds)

lab.member <- jira.conf.plus %>%
  filter(date_created >= firstday, date_created < lastday) %>%
  filter(Assignee != "") %>%
  filter(!Assignee %in% exclusions) %>%
  left_join(lookup) %>%
  anti_join(removal) %>%
  mutate(Assignee = if_else(is.na(Name),Assignee,Name)) %>%
  distinct(Assignee) 

saveRDS(lab.member,file=file.path(jiraanon,"replicationlab_members.Rds"))
write.table(lab.member, file = file.path(basepath,"data","replicationlab_members.txt"), sep = "\t",
            row.names = FALSE)

if (! file.exists(jira.conf.plus.rds)) {
  process_raw = FALSE
  warning("Input file with confidential information not found - setting global parameter to FALSE")
}

### Repeat process for external replicators

external.member <- jira.conf.plus %>%
  filter(External.party.name!="") %>%
  filter(date_created >= firstday, date_created < lastday) %>%
  mutate(name_external=str_replace(External.party.name,"-"," ")) %>%
  distinct(name_external) 

write.table(external.member, file = file.path(basepath,"data","external_replicators.txt"), sep = "\t",
            row.names = FALSE)
