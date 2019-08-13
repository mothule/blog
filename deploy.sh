#!/bin/bash

echo "Start deploy."

cd ws
JEKYLL_ENV=production bundle exec jekyll build
cd ..

echo "Copy to docs/"
rsync -auv ws/_site/ docs

echo "Commit and push"
git add .
git commit -m "Deploy:"
git push
