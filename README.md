---
title: "Process data from reproducibility service"
author: "Lars Vilhuber"
date: '2021-03-16'
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

> Vilhuber, Lars. 2021. "Process data for the AEA Pre-publication Verification Service." *American Economic Association [publisher]*. Ann Arbor, MI: Inter-university Consortium for Political and Social Research [distributor], 2021-03-16. [https://doi.org/10.3886/E117876V2](https://doi.org/10.3886/E117876V2)

```
@techreport{10.3886/e117876v2,
  doi = {10.3886/E117876V2},
  url = {https://www.openicpsr.org/openicpsr/project/117876/version/V2/view},
  author = {Vilhuber,  Lars},
  title = {Process data for the AEA Pre-publication Verification Service},
  institution = {American Economic Association [publisher]},
  series = {ICPSR - Interuniversity Consortium for Political and Social Research},
  year = {2021}
}
```

## Requirements
This project requires

- R (last run with R 4.0.5)
  - package `here` (>=0.1)
  
Other packages might be installed automatically by the programs, as long as the requirements above are met, see [Session Info](#r-session-info).

## Data 

### The workflow

![Workflow stages](images/AEADataEditorWorkflow-20191028.png)

### Raw process data

Raw process data is manually extracted from Jira, and saved as 

- `export_MM-DD-YYYY.csv` (for detailed transaction-level data)

The data is not made available outside of the organization, as it contains names of replicators,  manuscript numbers, and verbatim email correspondence. 



At this time, the latest extract was made 05-31-2021. 

### Anonymized data

We subset the raw data to variables of interest, and substitute random numbers for sensitive strings. This is done by running `01_jira_anonymize.R`. The programs saves both the confidential version and the anonymized version. 


```r
source(file.path(programs,"01_jira_anonymize.R"),echo=TRUE)
```

### Publishing data

Some additional cleaning and matching, and then we write out the file


```r
source(file.path(programs,"02_jira_anon_publish.R"),echo=TRUE)
```



## Describing the Data


The anonymized data has 15 columns. 

### Variables


```
## 
## -- Column specification --------------------------------------------------------
## cols(
##   name = col_character(),
##   label = col_character()
## )
```



|name               |label                                                                                                                                                                    |
|:------------------|:------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|ticket             |The tracking number within the system. Project specific. Sequentially assigned upon receipt.                                                                             |
|date_created       |Date of a receipt                                                                                                                                                        |
|date_updated       |Date of a transaction                                                                                                                                                    |
|mc_number_anon     |The (anonymized) number assigned by the editorial workflow system (Manuscript Central/ ScholarOne) to a manuscript. This is purged by a script of any revision suffixes. |
|Journal            |Journal associated with an issue and manuscript. Derived from the manuscript number. Possibly updated by hand                                                            |
|Status             |Status associated with a ticket at any point in time. The schema for these has changed over time.                                                                        |
|Software.used      |A list of software used to replicate the issue.                                                                                                                          |
|received           |An indicator for whether the issue is just created and has not been assigned to a replicator yet.                                                                        |
|Changed.Fields     |A transaction will change various fields. These are listed here.                                                                                                         |
|external           |An indicator for whether the issue required the external validation.                                                                                                     |
|subtask            |An indicator for whether the issue is a subtask of another task.                                                                                                         |
|Resolution         |Resolution associated with a ticket at the end of the replication process.                                                                                               |
|reason.failure     |A list of reasons for failure to fully replicate.                                                                                                                        |
|MCRecommendation   |Decision status when the issue is Revise and Resubmit.                                                                                                                   |
|MCRecommendationV2 |Decision status when the issue is conditionally accepted.                                                                                                                |

### Sample records


|ticket      |date_created |date_updated | mc_number_anon|Journal               |Status   |Software.used |received |Changed.Fields                |external |subtask |Resolution |reason.failure |MCRecommendation |MCRecommendationV2 |
|:-----------|:------------|:------------|--------------:|:---------------------|:--------|:-------------|:--------|:-----------------------------|:--------|:-------|:----------|:--------------|:----------------|:------------------|
|AEAREP-2260 |2021-05-28   |2021-05-31   |            804|AEJ:Applied Economics |Open     |              |NA       |                              |No       |NA      |           |               |                 |                   |
|AEAREP-2260 |2021-05-28   |2021-05-28   |            804|AEJ:Applied Economics |Open     |              |NA       |Journal                       |No       |NA      |           |               |                 |                   |
|AEAREP-2260 |2021-05-28   |2021-05-28   |            804|                      |Open     |              |NA       |Manuscript Central identifier |No       |NA      |           |               |                 |                   |
|AEAREP-2260 |2021-05-28   |2021-05-28   |            804|                      |Open     |              |NA       |                              |No       |NA      |           |               |                 |                   |
|AEAREP-2259 |2021-05-27   |2021-05-31   |            190|AER                   |Assigned |              |No       |                              |No       |NA      |           |               |                 |                   |
|AEAREP-2259 |2021-05-27   |2021-05-27   |            190|AER                   |Assigned |              |No       |Assignee,Status               |No       |NA      |           |               |                 |                   |

### R session info


```r
sessionInfo()
```

```
## R version 4.0.5 (2021-03-31)
## Platform: x86_64-w64-mingw32/x64 (64-bit)
## Running under: Windows 10 x64 (build 19042)
## 
## Matrix products: default
## 
## locale:
## [1] LC_COLLATE=English_United States.1252 
## [2] LC_CTYPE=English_United States.1252   
## [3] LC_MONETARY=English_United States.1252
## [4] LC_NUMERIC=C                          
## [5] LC_TIME=English_United States.1252    
## 
## attached base packages:
## [1] stats     graphics  grDevices utils     datasets  methods   base     
## 
## other attached packages:
## [1] readr_1.4.0   knitr_1.30    tidyr_1.1.2   stringr_1.4.0 dplyr_1.0.2  
## 
## loaded via a namespace (and not attached):
##  [1] rstudioapi_0.13  magrittr_2.0.1   hms_1.0.0        tidyselect_1.1.0
##  [5] here_1.0.0       R6_2.5.0         rlang_0.4.10     fansi_0.4.2     
##  [9] highr_0.8        tools_4.0.5      xfun_0.22        utf8_1.1.4      
## [13] cli_2.3.1        htmltools_0.5.0  ellipsis_0.3.1   assertthat_0.2.1
## [17] yaml_2.2.1       rprojroot_2.0.2  digest_0.6.27    tibble_3.0.6    
## [21] lifecycle_1.0.0  crayon_1.4.1     purrr_0.3.4      vctrs_0.3.6     
## [25] glue_1.4.2       evaluate_0.14    rmarkdown_2.5    stringi_1.5.3   
## [29] compiler_4.0.5   pillar_1.5.0     generics_0.1.0   pkgconfig_2.0.3
```


