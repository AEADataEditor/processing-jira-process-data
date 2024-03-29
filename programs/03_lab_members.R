# Export lab members worked during the designated period.
# Harry Son
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

lookup <- read_csv(file.path(jirameta,"lookup.csv"))

jira.conf.plus <- readRDS(jira.conf.plus.rds)

lab.member <- jira.conf.plus %>%
  filter(date_created >= firstday, date_created < lastday) %>%
  filter(Assignee != "") %>%
  filter(!Assignee %in% exclusions) %>%
  left_join(lookup) %>%
  mutate(Assignee = if_else(is.na(Name),Assignee,Name)) %>%
  distinct(Assignee) 

write.table(lab.member, file = file.path(basepath,"data","replicationlab_members.txt"), sep = "\t",
            row.names = FALSE)

### Repeat process for external replicators
external.member <- jira.conf.plus %>%
  filter(External.party.name!="") %>%
  mutate(date_created = as.Date(substr(Created, 1,10), "%m/%d/%Y")) %>%
  filter(date_created >= firstday, date_created < lastday) %>%
  mutate(name_external=str_replace(External.party.name,"-"," ")) %>%
  distinct(name_external) 

write.table(external.member, file = file.path(basepath,"data","external_replicators.txt"), sep = "\t",
            row.names = FALSE)
