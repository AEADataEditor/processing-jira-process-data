---
title: "Process data from reproducibility service"
author: "Lars Vilhuber"
date: '2024-12-04'
output:
  html_document:
    keep_md: yes
    toc: yes
  pdf_document: 
    toc: yes
editor_options:
  chunk_output_type: console
---


> Note: The [PDF version](https://aeadataeditor.github.io/processing-jira-process-data/README.pdf) of this document is transformed by manually printing from a browser.

## Citation

> Vilhuber, Lars. 2024. "Process data for the AEA Pre-publication Verification Service." *American Economic Association [publisher]*. Ann Arbor, MI: Inter-university Consortium for Political and Social Research [distributor], 2024-12-04. [https://doi.org/10.3886/E117876V5](https://doi.org/10.3886/E117876V5)

```@techreport{10.3886/e117876V5,
  doi = {10.3886/E117876V5},
  url = {https://doi.org/10.3886/E117876V5},
  author = {Vilhuber,  Lars},
  title = {Process data for the AEA Pre-publication Verification Service},
  institution = {American Economic Association [publisher]},
  series = {ICPSR - Interuniversity Consortium for Political and Social Research},
  year = {2024}}
```

## Requirements

This project requires

- R (last run with R 4.2.3)
  - package `here` (>=0.1)
- Python
  - module `venv`
  
Other packages will be installed automatically by the programs, as long as the requirements above are met, see [Session Info](#r-session-info).

### R packages


|Package         |Version |
|:---------------|:-------|
|dplyr           |1.1.1   |
|stringr         |1.5.0   |
|tidyr           |1.3.0   |
|knitr           |1.42    |
|readr           |2.1.4   |
|here            |1.0.1   |
|splitstackshape |1.4.8   |
|boxr            |0.3.6   |
|jose            |1.2.0   |
|rmarkdown       |2.21    |

### Python packages


|Modules       |
|:-------------|
|jira          |
|requests      |
|python-dotenv |
|pandas        |
|openpyxl      |
|argparse      |


### Docker

These requirements are satisfied in the Docker image created by `Dockerfile`, see [description below](#setup---1.-docker)

## Data 

### The workflow

![Workflow stages](images/AEADataEditorWorkflow-20191028.png)

### Raw process data

Raw process data is extracted from Jira using API (see below for details), and saved as 

- `export_MM-DD-YYYY.csv` (for detailed transaction-level data)

The data is not made available outside of the organization, as it contains names of replicators,  manuscript numbers, and verbatim email correspondence.

To obtain, run `programs/01_download_issues.py`. This will use the fields as specified in `data/metadata/jira-fields.xlsx`. If fields need to be updated (they are keyed on names), run `programs/00_jira_fields.py` to obtain a new Excel file, and mark the to-be-included fields with "True".

A full download of JIRA issues as of 2024 would be

```
> python3 01_download_issues.py -s 2018-01-01 -e 2024-11-30
Summary:
- Start Date: 2018-01-01
- End Date: 2024-11-30

 About to extract all issue history between these dates from https://aeadataeditors.atlassian.net.
 The output will be written to /home/rstudio/data/confidential/issue_history_2024-12-03.csv.

```




At this time, the latest extract was made 2024-12-04. 

### Anonymized data

We subset the raw data to variables of interest, and substitute random numbers for sensitive strings. This is done by running `02_jira_anonymize.R`. The programs saves both the confidential version and the anonymized version.


```r
source(file.path(programs,"02_jira_anonymize.R"),echo=TRUE)
```

```
## 
## > source(here::here("programs", "config.R"), echo = TRUE)
## 
## > process_raw <- TRUE
## 
## > download_raw <- TRUE
## 
## > extractday <- "2024-12-04"
## 
## > firstday <- "2023-12-01"
## 
## > lastday <- "2024-11-30"
## 
## > basepath <- here::here()
## 
## > setwd(basepath)
## 
## > jiraconf <- file.path(basepath, "data", "confidential")
## 
## > jiraanon <- file.path(basepath, "data", "anon")
## 
## > jirameta <- file.path(basepath, "data", "metadata")
## 
## > images <- file.path(basepath, "images")
## 
## > tables <- file.path(basepath, "tables")
## 
## > programs <- file.path(basepath, "programs")
## 
## > temp <- file.path(basepath, "data", "temp")
## 
## > for (dir in list(images, tables, programs, temp)) {
## +     if (file.exists(dir)) {
## +     }
## +     else {
## +         dir.create(file.path(dir))
## +     }
##  .... [TRUNCATED] 
## 
## > issue_history.prefix <- "issue_history_"
## 
## > manuscript.lookup <- "mc-lookup"
## 
## > manuscript.lookup.rds <- file.path(jiraconf, paste0(manuscript.lookup, 
## +     ".RDS"))
## 
## > assignee.lookup <- "assignee-lookup"
## 
## > assignee.lookup.rds <- file.path(jiraconf, paste0(assignee.lookup, 
## +     ".RDS"))
## 
## > jira.conf.plus.base <- "jira.conf.plus"
## 
## > jira.conf.plus.rds <- file.path(jiraconf, paste0(jira.conf.plus.base, 
## +     ".RDS"))
## 
## > jira.conf.names.csv <- "jira_conf_names.csv"
## 
## > members.txt <- file.path(jiraanon, "replicationlab_members.txt")
## 
## > jira.anon.base <- "jira.anon"
## 
## > jira.anon.rds <- file.path(jiraanon, paste0(jira.anon.base, 
## +     ".RDS"))
## 
## > jira.anon.csv <- file.path(jiraanon, paste0(jira.anon.base, 
## +     ".csv"))
## 
## > if (file.exists(here::here("programs", "confidential-config.R"))) {
## +     source(here::here("programs", "confidential-config.R"))
## +     message("Con ..." ... [TRUNCATED]
```

```
## Confidential config found.
```

```
## 
## > source(here::here("global-libraries.R"), echo = TRUE)
## 
## > ppm.date <- "2023-11-01"
## 
## > options(repos = paste0("https://packagemanager.posit.co/cran/", 
## +     ppm.date, "/"))
## 
## > global.libraries <- c("dplyr", "stringr", "tidyr", 
## +     "knitr", "readr", "here", "splitstackshape", "boxr", "jose", 
## +     "rmarkdown")
## 
## > pkgTest <- function(x) {
## +     if (!require(x, character.only = TRUE)) {
## +         install.packages(x, dep = TRUE)
## +         if (!require(x, charact .... [TRUNCATED] 
## 
## > pkgTest.github <- function(x, source) {
## +     if (!require(x, character.only = TRUE)) {
## +         install_github(paste(source, x, sep = "/"))
## +      .... [TRUNCATED] 
## 
## > results <- sapply(as.list(global.libraries), pkgTest)
## 
## > exportfile <- paste0(issue_history.prefix, extractday, 
## +     ".csv")
## 
## > if (!file.exists(file.path(jiraconf, exportfile))) {
## +     process_raw = FALSE
## +     print("Input file for anonymization not found - setting global  ..." ... [TRUNCATED] 
## 
## > if (process_raw == TRUE) {
## +     jira.conf.raw <- read.csv(file.path(jiraconf, exportfile), 
## +         stringsAsFactors = FALSE) %>% rename(ticket = .... [TRUNCATED]
```

```
## Joining with `by = join_by(ticket)`
```

### Publishing data

Some additional cleaning and matching, and then we write out the file


```r
source(file.path(programs,"10_jira_anon_publish.R"),echo=TRUE)
```

```
## 
## > source(here::here("programs", "config.R"), echo = TRUE)
## 
## > process_raw <- TRUE
## 
## > download_raw <- TRUE
## 
## > extractday <- "2024-12-04"
## 
## > firstday <- "2023-12-01"
## 
## > lastday <- "2024-11-30"
## 
## > basepath <- here::here()
## 
## > setwd(basepath)
## 
## > jiraconf <- file.path(basepath, "data", "confidential")
## 
## > jiraanon <- file.path(basepath, "data", "anon")
## 
## > jirameta <- file.path(basepath, "data", "metadata")
## 
## > images <- file.path(basepath, "images")
## 
## > tables <- file.path(basepath, "tables")
## 
## > programs <- file.path(basepath, "programs")
## 
## > temp <- file.path(basepath, "data", "temp")
## 
## > for (dir in list(images, tables, programs, temp)) {
## +     if (file.exists(dir)) {
## +     }
## +     else {
## +         dir.create(file.path(dir))
## +     }
##  .... [TRUNCATED] 
## 
## > issue_history.prefix <- "issue_history_"
## 
## > manuscript.lookup <- "mc-lookup"
## 
## > manuscript.lookup.rds <- file.path(jiraconf, paste0(manuscript.lookup, 
## +     ".RDS"))
## 
## > assignee.lookup <- "assignee-lookup"
## 
## > assignee.lookup.rds <- file.path(jiraconf, paste0(assignee.lookup, 
## +     ".RDS"))
## 
## > jira.conf.plus.base <- "jira.conf.plus"
## 
## > jira.conf.plus.rds <- file.path(jiraconf, paste0(jira.conf.plus.base, 
## +     ".RDS"))
## 
## > jira.conf.names.csv <- "jira_conf_names.csv"
## 
## > members.txt <- file.path(jiraanon, "replicationlab_members.txt")
## 
## > jira.anon.base <- "jira.anon"
## 
## > jira.anon.rds <- file.path(jiraanon, paste0(jira.anon.base, 
## +     ".RDS"))
## 
## > jira.anon.csv <- file.path(jiraanon, paste0(jira.anon.base, 
## +     ".csv"))
## 
## > source(here::here("global-libraries.R"), echo = TRUE)
## 
## > ppm.date <- "2023-11-01"
## 
## > options(repos = paste0("https://packagemanager.posit.co/cran/", 
## +     ppm.date, "/"))
## 
## > global.libraries <- c("dplyr", "stringr", "tidyr", 
## +     "knitr", "readr", "here", "splitstackshape", "boxr", "jose", 
## +     "rmarkdown")
## 
## > pkgTest <- function(x) {
## +     if (!require(x, character.only = TRUE)) {
## +         install.packages(x, dep = TRUE)
## +         if (!require(x, charact .... [TRUNCATED] 
## 
## > pkgTest.github <- function(x, source) {
## +     if (!require(x, character.only = TRUE)) {
## +         install_github(paste(source, x, sep = "/"))
## +      .... [TRUNCATED] 
## 
## > results <- sapply(as.list(global.libraries), pkgTest)
## 
## > jira.anon.raw <- readRDS(file.path(jiraanon, "temp.jira.anon.RDS")) %>% 
## +     rename(reason.failure = Reason.for.Failure.to.be.Fully.Reproduced) %> .... [TRUNCATED] 
## 
## > jira.conf.subtask <- jira.anon.raw %>% filter(subtask != 
## +     "") %>% select(ticket, subtask) %>% separate_longer_delim(subtask, 
## +     delim = ", ..." ... [TRUNCATED] 
## 
## > jira.anon <- jira.anon.raw %>% filter(!is.na(mc_number_anon)) %>% 
## +     anti_join(jira.conf.subtask)
```

```
## Joining with `by = join_by(ticket)`
```

```
## 
## > saveRDS(jira.anon, jira.anon.rds)
## 
## > write.csv(jira.anon, jira.anon.csv)
```

Finally, we push the confidential data to Box, using the following code, which we specifically run manually:


```bash
cd programs
R CMD BATCH 99_push_box.R
```

## Describing the Data


The anonymized data has 46 columns. 

### Variables


|name                          |label                                                                                                                                                                    |
|:-----------------------------|:------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|Status.Category.Changed       |NA                                                                                                                                                                       |
|RepositoryDOI                 |NA                                                                                                                                                                       |
|openICPSRversion              |NA                                                                                                                                                                       |
|Resolution                    |Resolution associated with a ticket at the end of the replication process.                                                                                               |
|Agreement.signed              |NA                                                                                                                                                                       |
|JournalIssueMonth             |NA                                                                                                                                                                       |
|JournalIssueYear              |NA                                                                                                                                                                       |
|Update.type                   |NA                                                                                                                                                                       |
|MCStatus                      |NA                                                                                                                                                                       |
|Bitbucket.short.name          |NA                                                                                                                                                                       |
|MCRecommendationV2            |Decision status when the issue is conditionally accepted.                                                                                                                |
|reason.failure                |A list of reasons for failure to fully replicate.                                                                                                                        |
|Priority                      |NA                                                                                                                                                                       |
|external                      |An indicator for whether the issue required the external validation.                                                                                                     |
|External.party.name           |NA                                                                                                                                                                       |
|Candidate.for.Best.Package    |NA                                                                                                                                                                       |
|Status                        |Status associated with a ticket at any point in time. The schema for these has changed over time.                                                                        |
|ticket                        |The tracking number within the system. Project specific. Sequentially assigned upon receipt.                                                                             |
|DataAvailabilityAccess        |NA                                                                                                                                                                       |
|MCRecommendation              |Decision status when the issue is Revise and Resubmit.                                                                                                                   |
|subtask                       |An indicator for whether the issue is a subtask of another task.                                                                                                         |
|openICPSR.Project.Number      |NA                                                                                                                                                                       |
|RCT.                          |NA                                                                                                                                                                       |
|RCT.number                    |NA                                                                                                                                                                       |
|Issue.Type                    |NA                                                                                                                                                                       |
|Manuscript.Central.identifier |NA                                                                                                                                                                       |
|Journal                       |Journal associated with an issue and manuscript. Derived from the manuscript number. Possibly updated by hand                                                            |
|Software.used                 |A list of software used to replicate the issue.                                                                                                                          |
|Resolved                      |NA                                                                                                                                                                       |
|Created                       |NA                                                                                                                                                                       |
|Start.date                    |NA                                                                                                                                                                       |
|Updated                       |NA                                                                                                                                                                       |
|Non.compliant                 |NA                                                                                                                                                                       |
|Summary                       |NA                                                                                                                                                                       |
|DCAF_Access_Restrictions      |NA                                                                                                                                                                       |
|Due.date                      |NA                                                                                                                                                                       |
|Key.1                         |NA                                                                                                                                                                       |
|As.Of.Date                    |NA                                                                                                                                                                       |
|Changed.Fields                |A transaction will change various fields. These are listed here.                                                                                                         |
|mc_number_anon                |The (anonymized) number assigned by the editorial workflow system (Manuscript Central/ ScholarOne) to a manuscript. This is purged by a script of any revision suffixes. |
|assignee_anon                 |NA                                                                                                                                                                       |
|date_created                  |Date of a receipt                                                                                                                                                        |
|date_asof                     |NA                                                                                                                                                                       |
|date_resolved                 |NA                                                                                                                                                                       |
|received                      |An indicator for whether the issue is just created and has not been assigned to a replicator yet.                                                                        |
|has_subtask                   |NA                                                                                                                                                                       |

### Sample records


|Status.Category.Changed      |RepositoryDOI                     |openICPSRversion |Resolution |Agreement.signed |JournalIssueMonth | JournalIssueYear|Update.type |MCStatus     |Bitbucket.short.name |MCRecommendationV2  |reason.failure                                                                 |Priority |external |External.party.name |Candidate.for.Best.Package |Status          |ticket      |DataAvailabilityAccess |MCRecommendation |subtask | openICPSR.Project.Number|RCT. |RCT.number |Issue.Type |Manuscript.Central.identifier |Journal |Software.used                          |Resolved                     |Created                      |Start.date |Updated                      |Non.compliant |Summary                                                  |DCAF_Access_Restrictions |Due.date   |Key.1       |As.Of.Date                   |Changed.Fields                | mc_number_anon| assignee_anon|date_created |date_asof  |date_resolved |received |has_subtask |
|:----------------------------|:---------------------------------|:----------------|:----------|:----------------|:-----------------|----------------:|:-----------|:------------|:--------------------|:-------------------|:------------------------------------------------------------------------------|:--------|:--------|:-------------------|:--------------------------|:---------------|:-----------|:----------------------|:----------------|:-------|------------------------:|:----|:----------|:----------|:-----------------------------|:-------|:--------------------------------------|:----------------------------|:----------------------------|:----------|:----------------------------|:-------------|:--------------------------------------------------------|:------------------------|:----------|:-----------|:----------------------------|:-----------------------------|--------------:|-------------:|:------------|:----------|:-------------|:--------|:-----------|
|2024-11-26T14:44:04.379-0500 |                                  |V1               |           |                 |                  |               NA|            |             |                     |                    |                                                                               |Medium   |No       |                    |                           |Open            |AEAREP-6655 |                       |                 |        |                       NA|     |           |Task       |AER-2022-1422                 |AER     |                                       |                             |2024-11-26T14:42:25.824-0500 |NA         |2024-11-26T14:44:04.378-0500 |              |Fw: Question on Replication Package for AER-2022-1422.R3 |                         |2024-12-24 |AEAREP-6655 |2024-11-26T14:43:17.969-0500 |JiraSearchMC                  |              1|             1|2024-11-26   |2024-11-26 |NA            |Yes      |No          |
|2024-11-26T14:44:04.379-0500 |                                  |V1               |           |                 |                  |               NA|            |             |                     |                    |                                                                               |Medium   |No       |                    |                           |Open            |AEAREP-6655 |                       |                 |        |                       NA|     |           |Task       |AER-2022-1422                 |AER     |                                       |                             |2024-11-26T14:42:25.824-0500 |NA         |2024-11-26T14:44:04.378-0500 |              |Fw: Question on Replication Package for AER-2022-1422.R3 |                         |2024-12-24 |AEAREP-6655 |2024-11-26T14:42:59.199-0500 |Manuscript Central identifier |              1|             1|2024-11-26   |2024-11-26 |NA            |Yes      |No          |
|2024-12-02T10:27:55.578-0500 |https://doi.org/10.3886/E183683V1 |V1               |Done       |                 |                  |               NA|            |CA, Revision |aearep-3853          |Revise and Resubmit |[<JIRA CustomFieldOption: value='Reproduced in a previous round', id='10185'>] |Highest  |No       |                    |                           |Done            |AEAREP-6654 |                       |                 |        |                   183683|     |           |Task       |AER-2019-0650.R7              |AER     |['Excel', 'MATLAB', 'Python', 'Stata'] |2024-12-02T10:24:45.793-0500 |2024-11-26T14:38:34.900-0500 |NA         |2024-12-02T10:29:47.704-0500 |              |AER-2019-0650.R7 CA Data Review Request Rev.5            |                         |2024-12-24 |AEAREP-6654 |2024-12-02T10:29:47.704-0500 |status                        |              2|             2|2024-11-26   |2024-12-02 |2024-12-02    |No       |No          |
|2024-12-02T10:27:55.578-0500 |https://doi.org/10.3886/E183683V1 |V1               |Done       |                 |                  |               NA|            |CA, Revision |aearep-3853          |Revise and Resubmit |[<JIRA CustomFieldOption: value='Reproduced in a previous round', id='10185'>] |Highest  |No       |                    |                           |Submitted to MC |AEAREP-6654 |                       |                 |        |                   183683|     |           |Task       |AER-2019-0650.R7              |AER     |['Excel', 'MATLAB', 'Python', 'Stata'] |2024-12-02T10:24:45.793-0500 |2024-11-26T14:38:34.900-0500 |NA         |2024-12-02T10:29:47.704-0500 |              |AER-2019-0650.R7 CA Data Review Request Rev.5            |                         |2024-12-24 |AEAREP-6654 |2024-12-02T10:29:47.704-0500 |status                        |              2|             2|2024-11-26   |2024-12-02 |2024-12-02    |No       |No          |
|2024-12-02T10:27:55.578-0500 |https://doi.org/10.3886/E183683V1 |V1               |Done       |                 |                  |               NA|            |CA, Revision |aearep-3853          |Revise and Resubmit |[<JIRA CustomFieldOption: value='Reproduced in a previous round', id='10185'>] |Highest  |No       |                    |                           |Approved        |AEAREP-6654 |                       |                 |        |                   183683|     |           |Task       |AER-2019-0650.R7              |AER     |['Excel', 'MATLAB', 'Python', 'Stata'] |2024-12-02T10:24:45.793-0500 |2024-11-26T14:38:34.900-0500 |NA         |2024-12-02T10:29:47.704-0500 |              |AER-2019-0650.R7 CA Data Review Request Rev.5            |                         |2024-12-24 |AEAREP-6654 |2024-12-02T10:29:42.110-0500 |Report URL PDF                |              2|             2|2024-11-26   |2024-12-02 |2024-12-02    |No       |No          |
|2024-12-02T10:27:55.578-0500 |https://doi.org/10.3886/E183683V1 |V1               |Done       |                 |                  |               NA|            |CA, Revision |aearep-3853          |Revise and Resubmit |[<JIRA CustomFieldOption: value='Reproduced in a previous round', id='10185'>] |Highest  |No       |                    |                           |Approved        |AEAREP-6654 |                       |                 |        |                   183683|     |           |Task       |AER-2019-0650.R7              |AER     |['Excel', 'MATLAB', 'Python', 'Stata'] |2024-12-02T10:24:45.793-0500 |2024-11-26T14:38:34.900-0500 |NA         |2024-12-02T10:29:47.704-0500 |              |AER-2019-0650.R7 CA Data Review Request Rev.5            |                         |2024-12-24 |AEAREP-6654 |2024-12-02T10:27:58.330-0500 |assignee                      |              2|             2|2024-11-26   |2024-12-02 |2024-12-02    |No       |No          |

### Lab members during this period

We list the lab members active at some point during this period. This still requires confidential data as an input.


```
## 
## > source(here::here("programs", "config.R"), echo = TRUE)
## 
## > process_raw <- TRUE
## 
## > download_raw <- TRUE
## 
## > extractday <- "2024-12-04"
## 
## > firstday <- "2023-12-01"
## 
## > lastday <- "2024-11-30"
## 
## > basepath <- here::here()
## 
## > setwd(basepath)
## 
## > jiraconf <- file.path(basepath, "data", "confidential")
## 
## > jiraanon <- file.path(basepath, "data", "anon")
## 
## > jirameta <- file.path(basepath, "data", "metadata")
## 
## > images <- file.path(basepath, "images")
## 
## > tables <- file.path(basepath, "tables")
## 
## > programs <- file.path(basepath, "programs")
## 
## > temp <- file.path(basepath, "data", "temp")
## 
## > for (dir in list(images, tables, programs, temp)) {
## +     if (file.exists(dir)) {
## +     }
## +     else {
## +         dir.create(file.path(dir))
## +     }
##  .... [TRUNCATED] 
## 
## > issue_history.prefix <- "issue_history_"
## 
## > manuscript.lookup <- "mc-lookup"
## 
## > manuscript.lookup.rds <- file.path(jiraconf, paste0(manuscript.lookup, 
## +     ".RDS"))
## 
## > assignee.lookup <- "assignee-lookup"
## 
## > assignee.lookup.rds <- file.path(jiraconf, paste0(assignee.lookup, 
## +     ".RDS"))
## 
## > jira.conf.plus.base <- "jira.conf.plus"
## 
## > jira.conf.plus.rds <- file.path(jiraconf, paste0(jira.conf.plus.base, 
## +     ".RDS"))
## 
## > jira.conf.names.csv <- "jira_conf_names.csv"
## 
## > members.txt <- file.path(jiraanon, "replicationlab_members.txt")
## 
## > jira.anon.base <- "jira.anon"
## 
## > jira.anon.rds <- file.path(jiraanon, paste0(jira.anon.base, 
## +     ".RDS"))
## 
## > jira.anon.csv <- file.path(jiraanon, paste0(jira.anon.base, 
## +     ".csv"))
## 
## > if (file.exists(here::here("programs", "confidential-config.R"))) {
## +     source(here::here("programs", "confidential-config.R"))
## + }
## 
## > source(here::here("global-libraries.R"), echo = TRUE)
## 
## > ppm.date <- "2023-11-01"
## 
## > options(repos = paste0("https://packagemanager.posit.co/cran/", 
## +     ppm.date, "/"))
## 
## > global.libraries <- c("dplyr", "stringr", "tidyr", 
## +     "knitr", "readr", "here", "splitstackshape", "boxr", "jose", 
## +     "rmarkdown")
## 
## > pkgTest <- function(x) {
## +     if (!require(x, character.only = TRUE)) {
## +         install.packages(x, dep = TRUE)
## +         if (!require(x, charact .... [TRUNCATED] 
## 
## > pkgTest.github <- function(x, source) {
## +     if (!require(x, character.only = TRUE)) {
## +         install_github(paste(source, x, sep = "/"))
## +      .... [TRUNCATED] 
## 
## > results <- sapply(as.list(global.libraries), pkgTest)
## 
## > exclusions <- c("Lars Vilhuber", "Michael Darisse", 
## +     "Sofia Encarnacion", "Linda Wang", "Leonel Borja Plaza", 
## +     "User ", "Takshil Sachdev ..." ... [TRUNCATED] 
## 
## > lookup <- read_csv(file.path(jirameta, "lookup.csv"))
## 
## > jira.conf.plus <- readRDS(jira.conf.plus.rds)
## 
## > lab.member <- jira.conf.plus %>% filter(date_created >= 
## +     firstday, date_created < lastday) %>% filter(Assignee != 
## +     "") %>% filter(!Assig .... [TRUNCATED] 
## 
## > if (!file.exists(jira.conf.plus.rds)) {
## +     process_raw = FALSE
## +     warning("Input file with confidential information not found - setting global ..." ... [TRUNCATED] 
## 
## > external.member <- jira.conf.plus %>% filter(External.party.name != 
## +     "") %>% mutate(date_created = as.Date(substr(Created, 1, 
## +     10), "%m/ ..." ... [TRUNCATED] 
## 
## > write.table(external.member, file = file.path(basepath, 
## +     "data", "external_replicators.txt"), sep = "\t", row.names = FALSE)
```

There were a total of 55 lab members over the course of the 12 month period.

### R session info


```r
sessionInfo()
```

```
## R version 4.2.3 (2023-03-15)
## Platform: x86_64-pc-linux-gnu (64-bit)
## Running under: Ubuntu 22.04.4 LTS
## 
## Matrix products: default
## BLAS:   /usr/lib/x86_64-linux-gnu/openblas-pthread/libblas.so.3
## LAPACK: /usr/lib/x86_64-linux-gnu/openblas-pthread/libopenblasp-r0.3.20.so
## 
## locale:
##  [1] LC_CTYPE=en_US.UTF-8       LC_NUMERIC=C              
##  [3] LC_TIME=en_US.UTF-8        LC_COLLATE=en_US.UTF-8    
##  [5] LC_MONETARY=en_US.UTF-8    LC_MESSAGES=en_US.UTF-8   
##  [7] LC_PAPER=en_US.UTF-8       LC_NAME=C                 
##  [9] LC_ADDRESS=C               LC_TELEPHONE=C            
## [11] LC_MEASUREMENT=en_US.UTF-8 LC_IDENTIFICATION=C       
## 
## attached base packages:
## [1] stats     graphics  grDevices utils     datasets  methods   base     
## 
## other attached packages:
##  [1] rmarkdown_2.21        jose_1.2.0            openssl_2.0.6        
##  [4] boxr_0.3.6            splitstackshape_1.4.8 here_1.0.1           
##  [7] readr_2.1.4           knitr_1.42            tidyr_1.3.0          
## [10] stringr_1.5.0         dplyr_1.1.1          
## 
## loaded via a namespace (and not attached):
##  [1] pillar_1.9.0      bslib_0.4.2       compiler_4.2.3    jquerylib_0.1.4  
##  [5] tools_4.2.3       bit_4.0.5         digest_0.6.31     jsonlite_1.8.4   
##  [9] evaluate_0.20     lifecycle_1.0.3   tibble_3.2.1      pkgconfig_2.0.3  
## [13] rlang_1.1.0       cli_3.6.1         rstudioapi_0.14   parallel_4.2.3   
## [17] yaml_2.3.7        xfun_0.38         fastmap_1.1.1     withr_2.5.0      
## [21] askpass_1.1       generics_0.1.3    vctrs_0.6.2       sass_0.4.5       
## [25] hms_1.1.3         bit64_4.0.5       rprojroot_2.0.3   tidyselect_1.2.0 
## [29] glue_1.6.2        data.table_1.14.8 R6_2.5.1          fansi_1.0.4      
## [33] vroom_1.6.1       purrr_1.0.1       tzdb_0.3.0        magrittr_2.0.3   
## [37] htmltools_0.5.5   utf8_1.2.3        stringi_1.7.12    cachem_1.0.7     
## [41] crayon_1.5.2
```


## Downloading New Extract

### Setup - 1. Docker

#### Requirements

- Docker

#### Build

The `Dockerfile` is used to build the Docker image. The image is built with the `build.sh` script, which requires a `TAG` argument, and will otherwise read parameters from the [`.myconfig.sh`](.myconfig.sh) file.

```bash
bash ./build.sh TAG
```

You can do this in a GitHub Codespace or on BioHPC (remember to replace docker with docker1)

#### Available Docker image (tags)

Use `ls-tags.sh` to list available tags.

```bash
bash ./ls-tags.sh
```

#### Run

To run the image as a Rstudio interactive development image, use

```bash
bash ./start_rstudio.sh TAG
```

It defaults to the `2023-12-06` image if you don't specify a tag.


### Setup - 2. JIRA

#### Getting API key

The API is a per-individual key. It is not stored in this repository.

- Go to [https://id.atlassian.com/manage-profile/security/api-tokens](https://id.atlassian.com/manage-profile/security/api-tokens)

![JIRA API token](images/jira-account-apitokens.png)

- Click on "Create API token"
- Enter a label for the token (e.g. "JIRA Extract")
- Copy the token to the clipboard

![JIRA API token](images/jira-account-api-copy.png)

- Use it with the Python scripts in this repository, in one of the following ways:
    - Set the environment variable `JIRA_API_KEY` to the token value
      - On github codespaces this involves creating a Github secret with the exact name `JIRA_API_KEY` and value of the key you get from JIRA
    - Create a file named `.env` in the root directory of this project, and add the following line to it:
      `JIRA_API_KEY=<token value>`
    - Pass the token value to the Python scripts when prompted.


### Setup - 3. Reading and Writing Confidential Data to Box

Location: [https://cornell.app.box.com/folder/143352802492](https://cornell.app.box.com/folder/143352802492)

We use the subfolder [`jira_exports`](https://cornell.app.box.com/folder/235801403908).

In order to up- and download, you need not just an API key, but a JSON file with other credentials. This file is called `client_enterprise_id,"_",client_key_id,"_config.json"`, e.g. `81483_bkgnsg4p_config.json`. 

- The `client_enterprise_id` is identified in the JSON file itself as well. 
- The `client_key_id` is the name of the key in the [Box developer console](https://cornell.app.box.com/developers/console/app/1590771/configuration). 

This file is key. It is not stored in this repository, but is stored in the Box folder `InternalData`. To use this, the file must be downloaded and stored in the root of the project directory.

The `.env` file needs to be appropriately adjusted:

```dotenv
BOX_FOLDER_ID=12345678890
BOX_PRIVATE_KEY_ID=abcdef4g
BOX_ENTERPRISE_ID=123456
```

with the relevant numbers as per above entered. The BOX_FOLDER_ID is the 12 digit number in the URL of the box folder `.../folder/12345678890?...`. The BOX_PRIVATE_KEY_ID refers to the `publicKeyID` in the JSON file. The BOX_ENTERPRISE_ID is the number at the beginning of the name of the JSON file. Alternatively, on Github Actions, these need to be encoded as secrets.

The upload is then handled by `99_push_box.R`.

### Download Steps

- After you run `./start_rstudio.sh` it should pull the image from the docker and open a port for you to develop in a familiar RStudio environment.
  - On GitHub Codespaces you can access this port by clicking on ports and then the little globe icon to open it in a new tab.
- After opening development environment, ensure the docker image contains complete python requirements by running `pip install -r requirements.txt`.
  - Ensure you are in the correct directory, might need to CD to the folder containing `requirements.txt`.
- To obtain extract run `python3 01_download_issues.py -s 2023-12-01 -e 2024-11-30` with the relevant dates.
  - This will get the fields as specified in `data/metadata/jira-fields.xlsx`.
  - If fields need to be updated (they are keyed on names), edit `programs/00_jira_fields.py` to mark the to-be-included fields with "True" and then run it. Otherwise running this program is not required.
  - If you have not set up a .env file, you may need to input your JIRA Username (netid@cornell.edu) and JIRA API Key at this step.
  - Again ensure you are in the correct directory, might need to CD to the folder containing `01_download_issues.py`.
- Once the download has concluded, update the `extractday`, `firstday`, and `lastday` fields in the `config.R` file.
- Now run `02_jira_anonymize.R`, `03_lab_members.R`, and `10_jira_anon_publish.R` to create the confidential and anonymized files used for the report.
  - You should run these through the terminal as `R CMD BATCH 02_jira_anonymize.R` to obtain ROut files and look through those files to ensure program is running successfully
  - You can update the relevant parts of the README (extract day, extract contents) once you have re-run and obtained a new extract
- Now you can upload the relevant file to our Box folder using `99_push_box.R`.
  - Remember to set up .env file as detailed above.
