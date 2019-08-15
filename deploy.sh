#!/bin/bash

COLOR_ESC="\e["
COLOR_ESC_END="m"
COLOR_YELLOW=${COLOR_ESC}33${COLOR_ESC_END}
COLOR_PURPLE=${COLOR_ESC}35${COLOR_ESC_END}
COLOR_CYAN=${COLOR_ESC}36${COLOR_ESC_END}
COLOR_OFF=${COLOR_ESC}${COLOR_ESC_END}

function info() {
  printf "${COLOR_YELLOW}$1${COLOR_OFF}"
}


info "Start deploy."
printf "${COLOR_YELLOW}Start deploy.${COLOR_OFF}"

cd ws
JEKYLL_ENV=production bundle exec jekyll build
cd ..

echo "Copy to docs/"
rsync -auv ws/_site/ docs

echo "Copy CNAME to docs/"
cp CNAME docs/


echo "Commit and push"
git add .
git commit -m "Deploy:"
git push
