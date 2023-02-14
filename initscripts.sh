#!/bin/bash

#----------------------------------------------------
#      File-name: <-/bin/init.sh>
#       Language: bash script
#       Synopsis: initialize repository
#    Description: Recursive chmod to make all .sh files within the repository executable 
#        Project: Shell Script Programming Course
#         Author: hartmannka80488@th-nuernberg.de
#----------------------------------------------------

find ./bin/ -type f -iname "*.sh" -exec chmod a+x {} \;