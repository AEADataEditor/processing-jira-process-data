R CMD BATCH 02_jira_anonymize.R
R CMD BATCH 03_lab_members.R
R CMD BATCH 04_repositories.R
R CMD BATCH 10_jira_anon_publish.R
# Pushing confidential files (including confidential-config.R, the seed) to Box
# is done manually, once the run has been checked:
#   R CMD BATCH 99_push_box.R
R CMD BATCH 99_render_README.R
