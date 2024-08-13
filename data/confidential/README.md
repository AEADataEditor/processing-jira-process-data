# JIRA export

AEA uses JIRA to track verification requests. 
These are the raw confidential files, containing names of individuals. They should not be distributed.

## How to export

Assuming that the Jira extra component "Advanced Export" is available, click on it in a generic Search interface. 

Currently, a filter `report-2022-search-submitted` is saved as a pre-configured public configuration. Select it, together with "History export". Be sure that "Summary" is not one of the fields selected, as this will lead to a failure to export. 

Choose date/time format "5/20/2021" (not preferred, but others are confusing) and "CSV Separator" = "Comma" (if using "Tab", adjust the R import).

Then Download CSV.

## Python API pull is coming

We are currently working on a Python script that pulls the equivalent data from the JIRA API. This will be more robust and reproducible, but was not ready in time for this report.

