#!/bin/bash

echo "Start deploy."

cd ws
if [[ -e _site ]] ; then
  rm -rfd _site
fi

JEKYLL_ENV=production bundle exec jekyll build
cd ..
mv ws/_site/* docs/

git add .
git commit -m "Deploy:"
git push
