#!/bin/bash

#----------------------------------------------------
#      File-name: <-/bin/hartmann_b5.sh>
#       Language: bash script
#       Synopsis: maxint in bash
#    Description: Probeklausur Aufgabe B.5
#        Project: Shell Script Programming Course
#         Author: hartmannka80488@th-nuernberg.de
#----------------------------------------------------

num=2
echo $num
while true ; do
  num=$((num*2))
  echo $num
  if [[ $num -lt 0 ]]; then
    echo -n "MAXINT: "
    echo $((num-1))
    exit 0
  fi
done
