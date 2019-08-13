#!/bin/bash

echo "Start deploy."

cd ws
JEKYLL_ENV=production bundle exec jekyll build
cd ..
mv ws/_site/* docs/

git add .
git commit -m "Deploy:"
git push
