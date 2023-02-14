#!/bin/bash

#----------------------------------------------------
#      File-name: <-/bin/hartmann_b4.sh>
#       Language: bash script
#       Synopsis: Quadrat zeichnen
#    Description: Probeklausur Aufgabe B.4
#        Project: Shell Script Programming Course
#         Author: hartmannka80488@th-nuernberg.de
#----------------------------------------------------

# Check if first parameter is number
if ! [[ "$1" =~ ^[0-9]+$ ]] ; then 
  exec >&2; echo "error: Not a number"; exit 1
fi

# Optional symbol to use when drawing
sym="*" 
if ! [[ ${#2} -eq 0 ]]; then
  if [[ ${#2} -gt 1 ]]; then
    exec >&2; echo "error: Symbol length must exceed length of 1"; exit 1
  fi
  sym=$2
fi

# Draw the actual square (more of a reectangle most of the time)
rows="$((($1+1)/2))" # Round up
cols="$(($1))"
for y in $(seq 1 $rows); do
  for x in $(seq 1 $cols); do
    if [ "$y" = 1 ] || [ "$y" = $rows ] || [ "$x" = 1 ] || [ "$x" = $cols ]; then
      echo -n "$sym"
    else
      echo -n " "
    fi
  done
  echo
done