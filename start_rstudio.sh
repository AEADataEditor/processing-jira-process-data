#!/bin/bash
PWD=$(pwd)

. ${PWD}/.myconfig.sh
  
# build the docker if necessary

BUILD=yes
arg1=$1

docker pull $space/$repo 
if [[ $? == 1 ]]
then
  ## maybe it's local only
  docker image inspect $space/$repo > /dev/null
  [[ $? == 0 ]] && BUILD=no
else
  BUILD=NO
fi
# override
[[ "$arg1" == "force" ]] && BUILD=yes

if [[ "$BUILD" == "yes" ]]; then
docker build . -t $space/$repo
nohup docker push $space/$repo &
fi

docker run -e DISABLE_AUTH=true \
 -v $WORKSPACE:/home/rstudio --rm -p 8787:8787 $space/$repo
