
### Load libraries 
### Requirements: have library *here*
source(here::here("programs","config.R"),echo=TRUE)
global.libraries <- c("dplyr","tidyr","splitstackshape","boxr","jose")
results <- sapply(as.list(global.libraries), pkgTest)

# Load boxr package
library(boxr)

# Read the client ID from the common .env file

readRenviron(file.path(basepath,".env"))
Sys.getenv("BOX_CLIENT_ID")

# Now load credentials
client_id <- Sys.getenv("BOX_CLIENT_ID")
client_secret <- Sys.getenv("BOX_CLIENT_SECRET")
client_folder <- Sys.getenv("BOX_FOLDER_ID")
client_key_id <- Sys.getenv("BOX_PRIVATE_KEY_ID")  # This is the "Public Key (N) ID: ______"
client_enterprise_id <- Sys.getenv("BOX_ENTERPRISE_ID") # This is visible within the JSON file

# Authenticate 
box_auth_service(file.path(basepath,paste0(client_enterprise_id,"_",client_key_id,"_config.json")))

# List files in folder
files <- box_ls(client_folder)
box_setwd(client_folder)

issues.file.csv = file.path(jiraconf,"issue_history_2023-11-09.csv")
plusfile.Rds    = file.path(jiraconf,"jira.conf.plus.RDS")
assignee.lookup.Rds = file.path(jiraconf,"assignee-lookup.RDS")

box_ul(file=issues.file.csv)
box_ul(file=plusfile.Rds)
box_ul(file=assignee.lookup.Rds)
