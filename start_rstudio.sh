#!/bin/bash


PWD=$(pwd)
. ${PWD}/.myconfig.sh

if [[ "$1" == "-h" ]]
then
cat << EOF
$0 (tag)

will start interactive environment for tag (TAG)
EOF
exit 0
fi

if [[ ! -z "$1" ]]
then
  tag=${1}
fi

echo "Using tag = $tag"

case $USER in
  codespace)
  WORKSPACE=/workspaces
  ;;
  *)
  WORKSPACE=$PWD
  ;;
esac
  
# pull the docker if necessary
# set -ev

# tag_present=$(docker images | grep $space/$repo | awk ' { print $2 } ' | grep $tag)

# if [[ -z "$tag_present" ]]
# then
#   echo "Pulling $space/$repo:$tag"
#   docker pull $space/$repo:$tag
# else  
#   echo "Found $space/$repo:$tag"
# fi
if [[ ! -z $JIRA_USERNAME ]]; then export DOCKEREXTRA="$DOCKEREXTRA -e JIRA_USERNAME=$JIRA_USERNAME" ; fi
if [[ ! -z $JIRA_API_KEY ]]; then export DOCKEREXTRA="$DOCKEREXTRA -e JIRA_API_KEY=$JIRA_API_KEY" ; fi
# do the same for BOX_ENTERPRISE_ID, BOX_FOLDER_ID, BOX_PRIVATE_KEY_ID 
if [[ ! -z $BOX_ENTERPRISE_ID ]]; then export DOCKEREXTRA="$DOCKEREXTRA -e BOX_ENTERPRISE_ID=$BOX_ENTERPRISE_ID" ; fi
if [[ ! -z $BOX_FOLDER_ID ]]; then export DOCKEREXTRA="$DOCKEREXTRA -e BOX_FOLDER_ID=$BOX_FOLDER_ID" ; fi
if [[ ! -z $BOX_PRIVATE_KEY_ID ]]; then export DOCKEREXTRA="$DOCKEREXTRA -e BOX_PRIVATE_KEY_ID=$BOX_PRIVATE_KEY_ID" ; fi


docker run $DOCKEREXTRA -e DISABLE_AUTH=true -v "$WORKSPACE":/home/rstudio --rm -p 8787:8787 $space/$repo:$tag
