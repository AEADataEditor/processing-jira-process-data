#!/bin/bash

# packaging up for deposit at openICPSR.
# Note that we do this from within the directory, so as not to have redundant directory levels.
# Usage: ./package.sh [DATE]
# If DATE is not provided, uses the last git commit date

set -e

repo=processing-jira-process-data
pwd=$(pwd)

# Determine date to use
if [ -z "$1" ]; then
    # Get last commit date in YYYY-MM-DD format
    DATE=$(git log -1 --format=%cd --date=format:%Y-%m-%d)
    echo "No date provided. Using last commit date: $DATE"
else
    DATE="$1"
    echo "Using provided date: $DATE"
fi

if [ "${pwd##*/}" == "$repo" ] 
then
	echo "Processing ZIP creation"
	git pull 
	git lfs pull

	zipfile="../${repo}-${DATE}.zip"
	
	echo "Creating archive: $zipfile"
	zip -rp "$zipfile" README.md 
	zip -rp "$zipfile" LICENSE.txt
	zip -rp "$zipfile" README.pdf 
	zip -rp "$zipfile" programs/
	zip -rp "$zipfile" images/
	zip -rp "$zipfile" data/anon/
	zip -rp "$zipfile" data/metadata

	echo "Archive created successfully: $zipfile"

	# Create git tag
	tag_name="data-${DATE}"
	commit_message="Data and code as of ${DATE}"

	echo "Creating git tag: $tag_name"

	if git rev-parse "$tag_name" >/dev/null 2>&1; then
		echo "Warning: Tag $tag_name already exists. Skipping tag creation."
		read -p "Do you want to delete and recreate the tag? (y/N): " -n 1 -r
		echo
		if [[ $REPLY =~ ^[Yy]$ ]]; then
			git tag -d "$tag_name"
			git tag -a "$tag_name" -m "$commit_message"
			echo "Tag recreated: $tag_name"
		fi
	else
		git tag -a "$tag_name" -m "$commit_message"
		echo "Tag created: $tag_name with message: $commit_message"
	fi

	echo ""
	echo "Summary:"
	echo "  Archive: $zipfile"
	echo "  Tag: $tag_name"
	echo "  Message: $commit_message"
	echo ""
	echo "To push the tag to remote, run: git push origin $tag_name"

else
	echo "Skipping processing. Be sure to be inside the repo $repo"
fi


