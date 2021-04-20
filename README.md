---
title: "Process data from reproducibility service"
author: "Lars Vilhuber"
date: "3/16/2021"
output: 
  html_document: 
    keep_md: yes
    toc: yes
editor_options: 
  chunk_output_type: console
---


> Note: The PDF version of this document is transformed by manually printing from a browser.

## Requirements
This project requires
- R (last run with R 4.0.4)
  - package `here` (>=0.1)
  
Other packages might be installed automatically by the programs, as long as the requirements above are met.

## Data 

### The workflow

![Workflow stages](images/AEADataEditorWorkflow-20191028.png)

### Raw process data
Raw process data is manually extracted from Jira, and saved as 
- `export_MM-DD-YYYY.csv`

We currently only use the latter. The data is not made available outside of the organization, as it contains names of replicators,  manuscript numbers, and verbatim email correspondence. 


At this time, the latest extract was made 12-22-2020. 

### Anonymized data
We subset the raw data to variables of interest, and substitute random numbers for sensitive strings. This is done by running `01_jira_anonymize.R` and `02_jira_anon_publish.R`:


```r
source(file.path(programs,"01_jira_anonymize.R"),echo=TRUE)
```


## Describing the Data


The anonymized data has 15 columns. 

### Variables
|  name             | description                                                      |
|----------------------|-------------------------------|
|   ticket             | The tracking number within the system. Project specific. Sequentially assigned upon receipt.                          |
|   date_created       | Date of a receipt                                                  |
|   date_updated       |  Date of a transaction  |
|   Journal            |  Journal associated with an issue and manuscript. Derived from the manuscript number. Possibly updated by hand         |
|   Status             |  Status associated with a ticket at any point in time. The schema for these has changed over time.                                           |
|   Changed.Fields     |  A transaction will change various fields. These are listed here. |
|   Software.used      |  A list of software used to replicate the issue.  |
|   received           |  An indicator for whether the issue is just created and has not been assigned to a replicator yet.  |
|   external           |  An indicator for whether the issue required the external validation. |
|   subtask            | An indicator for whether the issue is a subtask of another task.   |
|   Resolution         |  Resolution associated with a ticket at the end of the replication process.           |
|   reason.failure     |  A list of reasons for failure to fully replicate. |
|   MCRecommendation   |  Decision status when the issue is Revise and Resubmit. |
|   MCRecommendationV2 |  Decision status when the issue is conditionally accepted.    |
|   mc_number_anon     | The (anonymized) number assigned by the editorial workflow system (Manuscript Central/ ScholarOne) to a manuscript. This is purged by a script of any revision suffixes." |


### Sample records

| ticket      | date_created | date_updated | mc_number_anon | Journal             | Status              | Software.used | received | Changed.Fields                                          | external | subtask | Resolution        | reason.failure                                      | MCRecommendation | MCRecommendationV2 |
|-------------|--------------|--------------|----------------|---------------------|---------------------|---------------|----------|---------------------------------------------------------|----------|---------|-------------------|-----------------------------------------------------|------------------|--------------------|
| AEAREP-1639 | 12/7/2020    | 12/18/2020   | 202            | AEJ:Economic Policy | Submitted to MC     |               | No       | Status                                                  | No       | NA      | Mostly replicated | Discrepancy in output,Data preparation code missing |                  | Conditional Accept |
| AEAREP-1639 | 12/7/2020    | 12/18/2020   | 202            | AEJ:Economic Policy | Approved            |               | No       | openICPSRDOI                                            | No       | NA      | Mostly replicated | Discrepancy in output,Data preparation code missing |                  | Conditional Accept |
| AEAREP-1639 | 12/7/2020    | 12/18/2020   | 202            | AEJ:Economic Policy | Approved            |               | No       | Status                                                  | No       | NA      | Mostly replicated | Discrepancy in output,Data preparation code missing |                  | Conditional Accept |
| AEAREP-1639 | 12/7/2020    | 12/18/2020   | 202            | AEJ:Economic Policy | Report Under Review |               | No       | MCRecommendationV2,Status                               | No       | NA      | Mostly replicated | Discrepancy in output,Data preparation code missing |                  | Conditional Accept |
| AEAREP-1639 | 12/7/2020    | 12/18/2020   | 202            | AEJ:Economic Policy | Writing Report      |               | No       | Reason for Failure to Fully Replicate,Resolution,Status | No       | NA      | Mostly replicated | Discrepancy,in,output,Data,preparation,code,missing |                  |                    |
| AEAREP-1639 | 12/7/2020    | 12/18/2020   | 202            | AEJ:Economic Policy | Alternate workflow  |               | No       | Status                                                  | No       | NA      |                   |                                                     |                  |                    |
| AEAREP-1639 | 12/7/2020    | 12/18/2020   | 202            | AEJ:Economic Policy | In Progress         |               | No       | Status                                                  | No       | NA      |                   |                                                     |                  |                    |
| AEAREP-1639 | 12/7/2020    | 12/18/2020   | 202            | AEJ:Economic Policy | Assigned            |               | No       | Status                                                  | No       | NA      |                   |                                                     |                  |                    |
| AEAREP-1639 | 12/7/2020    | 12/8/2020    | 202            | AEJ:Economic Policy | Open                |               | No       | openICPSR Project Number                                | No       | NA      |                   |                                                     |                  |                    |
| AEAREP-1639 | 12/7/2020    | 12/7/2020    | 202            | AEJ:Economic Policy | Open                |               | No       | Journal                                                 | No       | NA      |

