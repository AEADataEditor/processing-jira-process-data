
### Load libraries 
### Requirements: have library *here*
source(here::here("programs","config.R"),echo=TRUE)
source(here::here("global-libraries.R"),echo=TRUE)

# Load boxr package
library(boxr)

# Read the key variables from the common .env file (if present; otherwise
# they are expected to already be set in the environment, e.g. Codespaces secrets)

if (file.exists(file.path(basepath,".env"))) readRenviron(file.path(basepath,".env"))

# Files to push. All must exist before we authenticate - in particular the
# confidential seed, without which the anonymization cannot be reproduced.

issue_history.csv <- file.path(jiraconf,paste0(issue_history.prefix,extractday,".csv"))
confidential.config <- file.path(programs,"confidential-config.R")

push.files <- c(issue_history.csv,
                jira.conf.plus.rds,
                assignee.lookup.rds,
                manuscript.lookup.rds,
                confidential.config)

missing.files <- push.files[!file.exists(push.files)]
if (length(missing.files) > 0) {
  stop("Not pushing to Box - missing file(s):\n  ", paste(missing.files, collapse="\n  "))
}

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

for (f in push.files) {
  message("Uploading ", f)
  box_ul(file=f)
}
