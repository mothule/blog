#!/bin/bash

currentDirectory=`basename pwd`

if [[ 'blog' -eq ${currentDirectory} ]] ; then
  rm -rfd ./ws/_site
  if [[ -e './ws/_site' ]] ; then
    echo "Failed remove _site folder"
  else
    echo "Successfully delete _site folder."
  fi
else
  echo "Current directory isn't blog/"
fi
