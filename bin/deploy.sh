#!/bin/bash

set -ue

COLOR_ESC="\e["
COLOR_ESC_END="m"
COLOR_YELLOW=${COLOR_ESC}33${COLOR_ESC_END}
COLOR_PURPLE=${COLOR_ESC}35${COLOR_ESC_END}
COLOR_CYAN=${COLOR_ESC}36${COLOR_ESC_END}
COLOR_OFF=${COLOR_ESC}${COLOR_ESC_END}

function info() {
  printf "${COLOR_YELLOW}$1${COLOR_OFF}\n"
}
function error() {
  printf "${COLOR_PURPLE}$1${COLOR_OFF}\n"
}
function log() {
  printf "$1\n"
}


info "Start deploy."

cd ws
info "Build blog contents for production...start"
JEKYLL_ENV=production bundle exec jekyll build
info "Build blog contents for production...done"
cd ..

ruby bin/validate-image-existence
ruby bin/validate-tags.rb false

if [[ ! -d './docs' ]] ; then
  if mkdir docs ; then
    info "Created a docs folder"
  else
    error "Failed to create docs folder"
    exit 1
  fi
else
  log "/docs folder already existing."
fi

# rsync
info "Copy to docs/ ... start"
rsync -auv --delete ws/_site/ docs
info "Copy to docs/ ... done"

# CNAME
info "Copy CNAME to docs/ ... start"
cp CNAME docs/
info "Copy CNAME to docs/ ... done"

# Git
info "Commit and push ... start"
git add .
git commit -m "Deploy:"
git push
info "Commit and push ... done"

info "Deploy done."
exit 0
