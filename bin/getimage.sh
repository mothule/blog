#!/bin/bash

if [ $# -ne 1 ] ; then
  printf "\e[31mNeed arguments 1.\e[m\n"
  exit 1
fi

outDir="./ws/assets/images"
ext=`basename $1 | sed -r 's/^.*\.(.*)$/\1/'`
echo "image file extension is ${ext}."

if [[ -d ./ws/assets/images ]] ; then
  http get $1 > "${outDir}/image.${ext}"
else
  printf "\e[31mNot found ${outDir}. recall on blog directory.\e[m\n"
fi
