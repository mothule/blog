#!/bin/bash

if [[ $# -ne 1 ]] ; then
  printf "\e[31mNeed arguments 1.\e[m\n"
  exit 1
fi

echo "Download from $1"
outDir="./ws/assets/images"
ext=`basename $1 | sed -r 's/^.*\.(.*)$/\1/'`

if [[ ! -d ./ws/assets/images ]] ; then
  printf "\e[31mNot found ${outDir}. recall on blog directory.\e[m\n"
  exit 1
fi

  temp_file="/tmp/image.${ext}"
  if [[ -e ${temp_file} ]] ; then
    rm ${temp_file}
  fi
  http get $1 > ${temp_file}

echo "Compress via tinypng"
ruby bin/compress_image "${temp_file}" "${outDir}/image.${ext}"
if [[ ! -e ${outDir}/image.${ext} ]] ; then
  printf "\e[31mFailed compressing image.\e[m\n"
  exit 1
fi

echo 'Successful'

