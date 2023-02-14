#!/bin/bash

#----------------------------------------------------
#      File-name: <-/bin/hartmann_b6.sh>
#       Language: bash script
#       Synopsis: Videofiles konvertieren
#    Description: Probeklausur Aufgabe B.6
#        Project: Shell Script Programming Course
#         Author: hartmannka80488@th-nuernberg.de
#----------------------------------------------------

if [[ -z "$1" ]] ; then 
  exec >&2; echo "error: Please provide a file"; exit 1
fi

#ffmpeg -i "$1" "${1%.*}.mp4" \;
for file in "$@" 
do
  # Throw warning when file is already mp4
  if [[ $file == *.mp4 ]]; then 
      exec >&2; echo "Warning! File already in mp4 format: $file";
  else
    newname="${file%.*}.mp4"
    echo ffmpeg -i "$file" "$newname"
    mv -- "$file" "$newname"
  fi
done
