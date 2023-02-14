#!/bin/bash

#----------------------------------------------------
#      File-name: <-/bin/hartmann_b3.sh>
#       Language: bash script
#       Synopsis: Hauptspeicher
#    Description: Probeklausur Aufgabe B.3
#        Project: Shell Script Programming Course
#         Author: hartmannka80488@th-nuernberg.de
#----------------------------------------------------

# Aufgabe 1
echo -n "RAM in KB: "
vmstat -s | grep -m 1 -o "[[:digit:]]*" 

echo -n "RAM in GB: "
free -tg | grep -oP '\d+' | sed '10!d' # RAM in GB 

#Aufgabe 2
function fGetHarwareMemoryTotal () 
{
  free -tg | grep -oP '\d+' | sed '10!d'
  return 0
}

# Aufgabe 3
echo -n "Das ist ein "
ram=$(fGetHarwareMemoryTotal)
if [[ $ram -lt 2 ]] ; 
  then echo "Kinderrechner"
elif [[ $ram -lt 8 ]] ;  
  then echo "Standartrechner"
else
  echo "Profirechner"
fi