#!/bin/bash

#----------------------------------------------------
#      File-name: <-/bin/hartmann_b2.sh>
#       Language: bash script
#       Synopsis: Dateien suchen
#    Description: Probeklausur Aufgabe B.2
#        Project: Shell Script Programming Course
#         Author: hartmannka80488@th-nuernberg.de
#----------------------------------------------------

# Aufgabe 1:
# Display files created in 2019
ls -d 2019*

# Aufgabe 2
# Display files created on January 1st
ls -d ????0101*

# Aufgabe 3
# Recursively find files starting with upper case letters
find . -type f -name "[[:upper:]]*" -print

