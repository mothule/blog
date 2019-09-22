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
info "Build blog contents for production."
JEKYLL_ENV=production bundle exec jekyll build
cd ..

ruby bin/validate-image-existence

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

sleep 7s

info "Copy to docs/"
rsync -auv --delete ws/_site/ docs

sleep 3s

info "Copy CNAME to docs/"
cp CNAME docs/


info "Commit and push"
git add .
git commit -m "Deploy:"
git push

info "Finished deploy."
exit 0
