# README

---
title: "Process data from reproducibility service"
author: "Lars Vilhuber"
date: '2024-12-03'
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

> Vilhuber, Lars. 2024. "Process data for the AEA Pre-publication Verification Service." *American Economic Association [publisher]*. Ann Arbor, MI: Inter-university Consortium for Political and Social Research [distributor], 2024-04-29. [https://doi.org/10.3886/E117876V5](https://doi.org/10.3886/E117876V5)

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
  
Other packages might be installed automatically by the programs, as long as the requirements above are met, see [Session Info](#r-session-info).

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

Full year download should take about 30 minutes. At this time, the latest extract was made 2024-12-03. 

### Anonymized data

We subset the raw data to variables of interest, and substitute random numbers for sensitive strings. This is done by running `02_jira_anonymize.R`. The programs saves both the confidential version and the anonymized version.

### Publishing data

Some additional cleaning and matching, and then we write out the file. This is done by running `02_jira_anonymize.R`.

## Describing the Data

The anonymized data has 46 columns. 

### Variables

```
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
```

### Sample records

|Status.Category.Changed      |RepositoryDOI                     |openICPSRversion |Resolution |Agreement.signed |JournalIssueMonth | JournalIssueYear|Update.type |MCStatus     |Bitbucket.short.name |MCRecommendationV2 |reason.failure |Priority |external |External.party.name |Candidate.for.Best.Package |Status   |ticket      |DataAvailabilityAccess |MCRecommendation |subtask | openICPSR.Project.Number|RCT. |RCT.number |Issue.Type |Manuscript.Central.identifier |Journal               |Software.used  |Resolved |Created                      |Start.date |Updated                      |Non.compliant |Summary                                          |DCAF_Access_Restrictions |Due.date   |Key.1       |As.Of.Date                   |Changed.Fields       | mc_number_anon| assignee_anon|date_created |date_asof  |date_resolved |received |has_subtask |
|:----------------------------|:---------------------------------|:----------------|:----------|:----------------|:-----------------|----------------:|:-----------|:------------|:--------------------|:------------------|:--------------|:--------|:--------|:-------------------|:--------------------------|:--------|:-----------|:----------------------|:----------------|:-------|------------------------:|:----|:----------|:----------|:-----------------------------|:---------------------|:--------------|:--------|:----------------------------|:----------|:----------------------------|:-------------|:------------------------------------------------|:------------------------|:----------|:-----------|:----------------------------|:--------------------|--------------:|-------------:|:------------|:----------|:-------------|:--------|:-----------|
|2024-10-14T13:48:01.596-0400 |https://doi.org/10.3886/E208342V1 |V1               |           |                 |                  |               NA|            |CA, Revision |aearep-6135          |                   |               |Medium   |No       |                    |                           |Assigned |AEAREP-6419 |                       |                 |        |                   208342|     |           |Task       |AEJApp-2023-0672.R3           |AEJ:Applied Economics |['R', 'Stata'] |         |2024-10-14T13:48:04.287-0400 |NA         |2024-10-14T14:20:02.039-0400 |              |AEJApp-2023-0672.R3 CA Data Review Request Rev.0 |                         |2024-11-11 |AEAREP-6419 |2024-10-14T14:20:02.039-0400 |status               |              1|             2|2024-10-14   |2024-10-14 |NA            |No       |No          |
|2024-10-14T13:48:01.596-0400 |https://doi.org/10.3886/E208342V1 |V1               |           |                 |                  |               NA|            |CA, Revision |aearep-6135          |                   |               |Medium   |No       |                    |                           |Open     |AEAREP-6419 |                       |                 |        |                   208342|     |           |Task       |AEJApp-2023-0672.R3           |AEJ:Applied Economics |['R', 'Stata'] |         |2024-10-14T13:48:04.287-0400 |NA         |2024-10-14T14:20:02.039-0400 |              |AEJApp-2023-0672.R3 CA Data Review Request Rev.0 |                         |2024-11-11 |AEAREP-6419 |2024-10-14T14:20:02.039-0400 |assignee             |              1|             2|2024-10-14   |2024-10-14 |NA            |Yes      |No          |
|2024-10-14T13:48:01.596-0400 |https://doi.org/10.3886/E208342V1 |V1               |           |                 |                  |               NA|            |CA, Revision |aearep-6135          |                   |               |Medium   |No       |                    |                           |Open     |AEAREP-6419 |                       |                 |        |                   208342|     |           |Task       |AEJApp-2023-0672.R3           |AEJ:Applied Economics |['R', 'Stata'] |         |2024-10-14T13:48:04.287-0400 |NA         |2024-10-14T14:20:02.039-0400 |              |AEJApp-2023-0672.R3 CA Data Review Request Rev.0 |                         |2024-11-11 |AEAREP-6419 |2024-10-14T14:19:25.287-0400 |Report URL           |              1|            NA|2024-10-14   |2024-10-14 |NA            |Yes      |No          |
|2024-10-14T13:48:01.596-0400 |https://doi.org/10.3886/E208342V1 |V1               |           |                 |                  |               NA|            |CA, Revision |aearep-6135          |                   |               |Medium   |No       |                    |                           |Open     |AEAREP-6419 |                       |                 |        |                   208342|     |           |Task       |AEJApp-2023-0672.R3           |AEJ:Applied Economics |['R', 'Stata'] |         |2024-10-14T13:48:04.287-0400 |NA         |2024-10-14T14:20:02.039-0400 |              |AEJApp-2023-0672.R3 CA Data Review Request Rev.0 |                         |2024-11-11 |AEAREP-6419 |2024-10-14T14:18:47.656-0400 |Git working location |              1|            NA|2024-10-14   |2024-10-14 |NA            |Yes      |No          |
|2024-10-14T13:48:01.596-0400 |https://doi.org/10.3886/E208342V1 |V1               |           |                 |                  |               NA|            |CA, Revision |aearep-6135          |                   |               |Medium   |No       |                    |                           |Open     |AEAREP-6419 |                       |                 |        |                   208342|     |           |Task       |AEJApp-2023-0672.R3           |AEJ:Applied Economics |['R', 'Stata'] |         |2024-10-14T13:48:04.287-0400 |NA         |2024-10-14T14:20:02.039-0400 |              |AEJApp-2023-0672.R3 CA Data Review Request Rev.0 |                         |2024-11-11 |AEAREP-6419 |2024-10-14T14:18:47.100-0400 |Bitbucket short name |              1|            NA|2024-10-14   |2024-10-14 |NA            |Yes      |No          |
|2024-10-14T13:48:01.596-0400 |https://doi.org/10.3886/E208342V1 |V1               |           |                 |                  |               NA|            |CA, Revision |                     |                   |               |Medium   |No       |                    |                           |Open     |AEAREP-6419 |                       |                 |        |                   208342|     |           |Task       |AEJApp-2023-0672.R3           |AEJ:Applied Economics |['R', 'Stata'] |         |2024-10-14T13:48:04.287-0400 |NA         |2024-10-14T14:20:02.039-0400 |              |AEJApp-2023-0672.R3 CA Data Review Request Rev.0 |                         |2024-11-11 |AEAREP-6419 |2024-10-14T14:18:44.916-0400 |MCStatus             |              1|            NA|2024-10-14   |2024-10-14 |NA            |Yes      |No          |

### Lab members during this period

We list the lab members active at some point during this period. This still requires confidential data as an input.

There were a total of 55 lab members over the course of the 12 month period.

### R session info


```r
sessionInfo()
```

```
R version 4.2.3 (2023-03-15)
Platform: x86_64-pc-linux-gnu (64-bit)
Running under: Ubuntu 22.04.2 LTS

Matrix products: default
BLAS:   /usr/lib/x86_64-linux-gnu/openblas-pthread/libblas.so.3
LAPACK: /usr/lib/x86_64-linux-gnu/openblas-pthread/libopenblasp-r0.3.20.so

locale:
 [1] LC_CTYPE=en_US.UTF-8       LC_NUMERIC=C               LC_TIME=en_US.UTF-8        LC_COLLATE=en_US.UTF-8    
 [5] LC_MONETARY=en_US.UTF-8    LC_MESSAGES=en_US.UTF-8    LC_PAPER=en_US.UTF-8       LC_NAME=C                 
 [9] LC_ADDRESS=C               LC_TELEPHONE=C             LC_MEASUREMENT=en_US.UTF-8 LC_IDENTIFICATION=C       

attached base packages:
[1] stats     graphics  grDevices utils     datasets  methods   base     

other attached packages:
 [1] jose_1.2.0            openssl_2.0.6         boxr_0.3.6            splitstackshape_1.4.8 here_1.0.1           
 [6] readr_2.1.4           knitr_1.42            tidyr_1.3.0           stringr_1.5.0         dplyr_1.1.0          

loaded via a namespace (and not attached):
 [1] pillar_1.8.1      compiler_4.2.3    tools_4.2.3       bit_4.0.5         digest_0.6.31     jsonlite_1.8.4   
 [7] evaluate_0.20     lifecycle_1.0.3   tibble_3.2.0      pkgconfig_2.0.3   rlang_1.1.0       cli_3.6.0        
[13] rstudioapi_0.14   parallel_4.2.3    yaml_2.3.7        xfun_0.37         fastmap_1.1.1     withr_2.5.0      
[19] generics_0.1.3    vctrs_0.5.2       askpass_1.1       hms_1.1.2         bit64_4.0.5       rprojroot_2.0.3  
[25] tidyselect_1.2.0  glue_1.6.2        data.table_1.14.8 R6_2.5.1          fansi_1.0.4       vroom_1.6.1      
[31] rmarkdown_2.20    purrr_1.0.1       tzdb_0.3.0        magrittr_2.0.3    htmltools_0.5.4   ellipsis_0.3.2   
[37] utf8_1.2.3        stringi_1.7.12    crayon_1.5.2
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
    - Set the environment variable `JIRA_API_TOKEN` to the token value
      - On github codespaces this involves creating a Github secret with the exact name `JIRA_API_TOKEN` and value of the key you get from JIRA
    - Create a file named `.env` in the root directory of this project, and add the following line to it:
      `JIRA_API_TOKEN=<token value>`
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