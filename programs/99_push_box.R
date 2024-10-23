
### Load libraries 
### Requirements: have library *here*
source(here::here("programs","config.R"),echo=TRUE)
source(here::here("global-libraries.R"),echo=TRUE)

# Load boxr package
library(boxr)

# Read the key variables from the common .env file

readRenviron(file.path(basepath,".env"))

# Now load credentials
client_folder <- Sys.getenv("BOX_FOLDER_ID")
client_key_id <- Sys.getenv("BOX_PRIVATE_KEY_ID")  # This is the "Public Key (N) ID: ______"
client_enterprise_id <- Sys.getenv("BOX_ENTERPRISE_ID") # This is visible within the JSON file
json.config.file <- file.path(basepath,
                              paste0(client_enterprise_id,"_",
                                     client_key_id,"_config.json"))

# Authenticate 
box_auth_service(json.config.file)

# List files in folder
#files <- box_ls(client_folder)
box_setwd(client_folder)


issue_history.csv <- file.path(jiraconf,paste0(issue_history.prefix,extractday,".csv"))


box_ul(file=issue_history.csv)
box_ul(file=jira.conf.plus.rds)
box_ul(file=assignee.lookup.rds)
box_ul(file=manuscript.lookup.rds)
