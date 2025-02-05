---
title: "Process data from reproducibility service"
author: "Lars Vilhuber"
date: '2025-02-05'
output:
  html_document:
    keep_md: yes
    toc: yes
editor_options:
  chunk_output_type: console
---


> Note: The [PDF version](https://aeadataeditor.github.io/processing-jira-process-data/README.pdf) of this document is transformed by manually printing from a browser.

## Citation

> Vilhuber, Lars. 2025. "Process data for the AEA Pre-publication Verification Service." *American Economic Association [publisher]*. Ann Arbor, MI: Inter-university Consortium for Political and Social Research [distributor], 2025-02-05. [https://doi.org/10.3886/E117876V6](https://doi.org/10.3886/E117876V6)

```
@techreport{10.3886/e117876V6,
  doi = {10.3886/E117876V6},
  url = {https://doi.org/10.3886/E117876V6},
  author = {Vilhuber,  Lars},
  title = {Process data for the AEA Pre-publication Verification Service},
  institution = {American Economic Association [publisher]},
  series = {ICPSR - Interuniversity Consortium for Political and Social Research},
  year = {2025}}
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
|tidylog         |1.0.2   |

### Python packages


|Modules       |
|:-------------|
|jira          |
|requests      |
|python-dotenv |
|pandas        |
|argparse      |


### Docker

These requirements are satisfied in the Docker image created by `Dockerfile`, see [description below](#setup---1.-docker)

## Data 

### The workflow

![Workflow stages](images/AEADataEditorWorkflow-20191028.png)

### Raw process data

Raw process data is extracted from Jira using API (see below for details), and saved as 

- `issue_history_MM-DD-YYYY.csv` (for detailed transaction-level data)

The data is not made available outside of the organization, as it contains names of replicators,  manuscript numbers, and verbatim email correspondence.

To obtain, run `programs/01_download_issues.py`. This will use the fields as specified in `data/metadata/jira-fields.xlsx`. If fields need to be updated (they are keyed on names), run `programs/00_jira_fields.py` to obtain a new Excel file, and mark the to-be-included fields with "True".

A full download of JIRA issues as of 2025 would be

```
> python3 01_download_issues.py -s 2018-01-01 -e 2024-11-30
Summary:
- Start Date: 2018-01-01
- End Date: 2024-11-30

 About to extract all issue history between these dates from https://aeadataeditors.atlassian.net.
 The output will be written to /home/rstudio/data/confidential/issue_history_2024-12-03.csv.

```




At this time, the latest extract was made 2025-02-05. 

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
## > extractday <- "2025-02-05"
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
## +     "rmarkdown", "tidylog" .... [TRUNCATED] 
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
## rename: renamed one variable (ticket)
```

```
## mutate: new variable 'mc_number' (character) with 518 unique values and 0% NA
```

```
## mutate: changed 345 values (1%) of 'mc_number' (0 new NA)
```

```
## filter: removed 7,140 rows (19%), 30,151 rows remaining
```

```
## filter: no rows removed
```

```
## select: dropped one variable (Key.1)
```

```
## filter: no rows removed
```

```
## filter: removed all rows (100%)
```

```
## select: dropped 24 variables (Agreement.signed, Resolution, Update.type, MCStatus, MCRecommendationV2, …)
```

```
## mutate: no changes
```

```
## select: dropped one variable (Sub.tasks)
```

```
## distinct: no rows removed
```

```
## Joining with `by = join_by(ticket)`
## anti_join: added no columns
## > rows only in x 30,151
## > rows only in y ( 0)
## > matched rows ( 0)
## > ========
## > rows total 30,151
## select: dropped 26 variables (Agreement.signed, Resolution, Update.type,
## MCStatus, MCRecommendationV2, …)
## filter: removed 2,704 rows (9%), 27,447 rows remaining
## distinct: removed 26,917 rows (98%), 530 rows remaining
## mutate: new variable 'rand' (double) with one unique value and 0% NA
## mutate: new variable 'mc_number_anon' (integer) with 530 unique values and 0%
## NA
## select: dropped one variable (rand)
## select: dropped 26 variables (Agreement.signed, Resolution, Update.type,
## MCStatus, MCRecommendationV2, …)
## filter: removed 11,190 rows (37%), 18,961 rows remaining
## filter: no rows removed
## filter: removed 1,017 rows (5%), 17,944 rows remaining
## distinct: removed 17,884 rows (>99%), 60 rows remaining
## mutate: new variable 'rand' (double) with 2 unique values and 0% NA
## mutate: new variable 'assignee_anon' (integer) with 60 unique values and 0% NA
## select: dropped one variable (rand)
## Rows: 23 Columns: 2
## ── Column specification
## ──────────────────────────────────────────────────────── Delimiter: "," chr
## (2): name, label
## ℹ Use `spec()` to retrieve the full column specification for this data. ℹ
## Specify the column types or set `show_col_types = FALSE` to quiet this message.
## filter: no rows removed
## select: dropped one variable (label)
## left_join: added one column (mc_number_anon)
## > rows only in x 2,704
## > rows only in y ( 0)
## > matched rows 27,447
## > ========
## > rows total 30,151
## left_join: added one column (assignee_anon)
## > rows only in x 12,207
## > rows only in y ( 0)
## > matched rows 17,944
## > ========
## > rows total 30,151
## mutate: new variable 'date_created' (Date) with 236 unique values and 0% NA
## new variable 'date_asof' (Date) with 415 unique values and 0% NA
## rename: renamed one variable (reason.failure)
## rename: renamed one variable (external)
## rename: renamed one variable (subtask)
## mutate: new variable 'date_resolved' (Date) with 287 unique values and 4% NA
## mutate: new variable 'received' (character) with 2 unique values and 0% NA
## mutate: new variable 'has_subtask' (character) with 2 unique values and 0% NA
## rename: renamed one variable (External.party.name.conf)
## filter: removed 10,590 rows (35%), 19,561 rows remaining
## select: dropped 32 variables (Agreement.signed, Resolution, Update.type,
## MCStatus, MCRecommendationV2, …)
## mutate: changed 26,742 values (58%) of 'subtask' (0 new NA)
## select: dropped one variable (subtask)
## distinct: removed 45,426 rows (98%), 877 rows remaining
## filter: removed 2,704 rows (9%), 27,447 rows remaining
## Joining with `by = join_by(ticket)`
## anti_join: added no columns
## > rows only in x 27,255
## > rows only in y ( 842)
## > matched rows ( 192)
## > ========
## > rows total 27,255
## select: dropped 7 variables (External.party.name.conf, subtask, Issue.Type,
## Resolved, Created, …)
## select: dropped 4 variables (Manuscript.Central.identifier, mc_number,
## Assignee, openICPSR.Project.Number)
```

### Publishing data

Some additional cleaning and matching, and then we write out the file


```r
source(file.path(programs,"10_jira_anon_publish.R"),echo=TRUE)
```

Finally, we push the confidential data to Box, using the following code, which we specifically run manually:


```bash
cd programs
R CMD BATCH 99_push_box.R
```

## Describing the Data


The anonymized data has 23 columns. 

### Variables


|name                        |label                                                                                                                                                                    |
|:---------------------------|:------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|ticket                      |The tracking number within the system. Project specific. Sequentially assigned upon receipt.                                                                             |
|mc_number_anon              |The (anonymized) number assigned by the editorial workflow system (Manuscript Central/ ScholarOne) to a manuscript. This is purged by a script of any revision suffixes. |
|assignee_anon               |Anonymized assignee name (time-varying)                                                                                                                                  |
|date_created                |Creation date of issue                                                                                                                                                   |
|received                    |An indicator for whether the issue is just created and has not been assigned to a replicator yet.                                                                        |
|Journal                     |Journal associated with an issue and manuscript. Derived from the manuscript number. Possibly updated by hand                                                            |
|Status                      |Status associated with a ticket at any point in time. The schema for these has changed over time.                                                                        |
|external                    |An indicator for whether the issue required  external validation.                                                                                                        |
|Resolution                  |Resolution associated with a ticket at the end of the reproducibility check.                                                                                             |
|reason.failure              |A list of reasons for failure to fully reproduce.                                                                                                                        |
|MCRecommendation            |Decision status when the issue is Revise and Resubmit.                                                                                                                   |
|MCRecommendationV2          |Decision status when the issue is conditionally accepted.                                                                                                                |
|External.party.name         |Name of the external party. Usually only institutional names.                                                                                                            |
|Non.compliant               |An indicator for whether the issue is non-compliant for some reason.                                                                                                     |
|DCAF_Access_Restrictions    |Category of Access Restrictions (2 categories)                                                                                                                           |
|DCAF_Access_Restrictions_V2 |Category of Access Restrictions (4 categories)                                                                                                                           |
|Update.type                 |Who initiated the need to update the replication package                                                                                                                 |
|Software.used               |Manually coded software used in the replication package                                                                                                                  |
|Agreement.signed            |Type of agreements signed by Data Editor to obtain private data                                                                                                          |
|MCStatus                    |Status of the manuscript in the editorial workflow system.                                                                                                               |
|As.Of.Date                  |Date and time stamp of the issue transaction                                                                                                                             |
|date_asof                   |Date part of the issue transaction                                                                                                                                       |
|date_resolved               |The date the issue was resolved.                                                                                                                                         |


### Lab members during this period

We list the lab members active at some point during this period. This still requires confidential data as an input.





There were a total of 49 lab members over the course of the 12 month period.

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
##  [1] tidylog_1.0.2         rmarkdown_2.21        jose_1.2.0           
##  [4] openssl_2.0.6         boxr_0.3.6            splitstackshape_1.4.8
##  [7] here_1.0.1            readr_2.1.4           knitr_1.42           
## [10] tidyr_1.3.0           stringr_1.5.0         dplyr_1.1.1          
## 
## loaded via a namespace (and not attached):
##  [1] bslib_0.4.2       jquerylib_0.1.4   pillar_1.9.0      compiler_4.2.3   
##  [5] tools_4.2.3       bit_4.0.5         digest_0.6.31     jsonlite_1.8.4   
##  [9] evaluate_0.20     lifecycle_1.0.3   tibble_3.2.1      pkgconfig_2.0.3  
## [13] rlang_1.1.0       cli_3.6.1         parallel_4.2.3    yaml_2.3.7       
## [17] xfun_0.38         fastmap_1.1.1     withr_2.5.0       sass_0.4.5       
## [21] generics_0.1.3    vctrs_0.6.2       askpass_1.1       hms_1.1.3        
## [25] bit64_4.0.5       rprojroot_2.0.3   tidyselect_1.2.0  glue_1.6.2       
## [29] data.table_1.14.8 R6_2.5.1          fansi_1.0.4       vroom_1.6.1      
## [33] tzdb_0.3.0        purrr_1.0.1       magrittr_2.0.3    clisymbols_1.2.0 
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


It defaults to the 2025-02-05 image if you don't specify a tag.


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

Location: [https://cornell.app.box.com/folder/143352802492](https://cornell.app.box.com/folder/143352802492)🔒

We use the subfolder [`jira_exports`](https://cornell.app.box.com/folder/235801403908)🔒.

In order to up- and download, you need not just an API key, but a JSON file with other credentials. This file is called `client_enterprise_id,"_",client_key_id,"_config.json"`, e.g. `81483_bkgnsg4p_config.json`. 

- The `client_enterprise_id` is identified in the JSON file itself as well. 
- The `client_key_id` is the name of the key in the [Box developer console](https://cornell.app.box.com/developers/console/app/1590771/configuration)🔒. 

This file is key. It is not stored in this repository, but is stored in the Box folder `InternalData`. To use this, the file must be downloaded and stored in the root of the project directory.

The `.env` file needs to be appropriately adjusted:

```dotenv
BOX_FOLDER_ID=12345678890
BOX_PRIVATE_KEY_ID=abcdef4g
BOX_ENTERPRISE_ID=123456
```

with the relevant numbers as per above entered. The BOX_FOLDER_ID is the 12 digit number in the URL of the box folder `.../folder/12345678890?...`. The BOX_PRIVATE_KEY_ID refers to the `publicKeyID` in the JSON file. The BOX_ENTERPRISE_ID is the number at the beginning of the name of the JSON file. Alternatively, on Github Actions, these need to be encoded as secrets.

The upload is then handled by `99_push_box.R`.

### Processing Steps

#### Start Docker and Setup Environment

- Run `./start_rstudio.sh` it should pull the image from the docker and open a port for you to develop in a familiar RStudio environment.
  - On GitHub Codespaces you can access this port by clicking on ports and then the little globe icon to open it in a new tab.
  - On a local computer, you may need to open a browser at <http://localhost:8787>
  - To obtain a console in the running Docker container, open a second terminal and connect: `
  
```bash
container_id=$(docker container ls | head -2 | tail -1 | awk ' { print $1 } ')
docker exec -it -u rstudio $container_id /bin/bash`
```
  
> The remainder of the instructions assume you are working within the Docker environment. Adjust as necessary if you are only using the code base in your own environment.

- Change to the correct working directory:
  - Rstudio: click on `processing-jira-process-data/processing-jira-process-data.Rproj`
  - Console: cd to the correct directory.
- Install any missing Python packages  by running `pip install -r requirements.txt`.
- Set up **environment variables**:
  - Use an `.env` file is present in the root project directory
  - Ensure that the Box `json` file as outlined above is present in the root project directory.
  - Provide JIRA and BOX information
  
> Template file

```
JIRA_USERNAME=
JIRA_API_KEY=
BOX_FOLDER_ID=
BOX_PRIVATE_KEY_ID=
BOX_ENTERPRISE_ID=
```

- Define start and end dates:
  - Update the `extractday`, `firstday`, and `lastday` fields in the [`programs/config.R`](programs/config.R) file.
  - You will need to manually provide them to the Python programs (for now)


#### Obtain Extract

- `cd programs`
- To obtain extract **run `python3 01_download_issues.py -s ` 2023-12-01 ` -e ` 2024-11-30** with the relevant dates.
  - This will get the fields as specified in `data/metadata/jira-fields.xlsx`.
  - If fields need to be updated (they are keyed on names), edit `programs/00_jira_fields.py` to obtain the full list of fields, open the resulting Excel file (`data/metadata/jira-fields.xlsx`) and  mark the to-be-included fields with "True". Otherwise running `programs/00_jira_fields.py` is not required.

- **Run R programs in numerical order** to create the confidential and anonymized files used for the report.
  - Running with `R CMD BATCH name_of_file.R` will create the necessary log files.
  - This is encapsulated in the `main.sh` file, for convenience:

```bash
cd programs
bash -x ./main.sh
```

