#!/bin/bash

# packaging up for deposit at openICPSR.
# Note that we do this from within the directory, so as not to have redundant directory levels.

repo=processing-jira-process-data
pwd=$(pwd)

if [ "${pwd##*/}" == "$repo" ] 
then
	echo "Processing ZIP creation"
	git pull 
	git lfs pull

	zip -rp ../${repo}-$(date +%F).zip README.md 
	zip -rp ../${repo}-$(date +%F).zip README.pdf 
	zip -rp ../${repo}-$(date +%F).zip programs/
	zip -rp ../${repo}-$(date +%F).zip images/
	zip -rp ../${repo}-$(date +%F).zip data/anon/
	zip -rp ../${repo}-$(date +%F).zip data/metadata

else
	echo "Skipping processing. Be sure to be inside the repo $repo"
fi


