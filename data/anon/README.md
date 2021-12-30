# JIRA export

AEA uses JIRA to track verification requests. The files have been anonymized, as they contain individual names. The program used to anonymize is available in the program directory.

Vilhuber,  Lars. 2022.  “Process  data  for  the AEA  Pre-publication  Verification  Service.” American Economic Association [publisher], https://doi.org/10.3886/E117876V3

# Checksums

These are the checksums of the *files* in this directory:

```
399767ed4361b23dd5f708ec48664ce60686f23292f347b18d1036b952f8e397  jira.anon.RDS
cc7977f3752d8a14e89c7083f7d31adf29b74a1b2065b03ebd8d96fd6487e788  jira.anon.csv
```

This is the checksum of the RDS file once read into R, when running

```{r}
digest::digest(readRDS("jira.anon.RDS"),algo="sha256")
```

```
> digest(readRDS("jira.anon.RDS"),algo="sha256")
[1] "73c92a3ff1d4f5ee5cedd2bf05c5940ca900f621c2e9358bf3e3a3149519ae7c"
```
