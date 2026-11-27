repo=report-aea-data-editor-2026
space=aeadataeditor
dockerrepo=$(echo $space/$repo | tr [A-Z] [a-z] | sed 's/-internal//')
case $USER in
  vilhuber)
  #WORKSPACE=$HOME/Workspace/git/
  WORKSPACE=$PWD
  ;;
  codespace)
  WORKSPACE=/workspaces
  ;;
esac
tag=2026-11-25
