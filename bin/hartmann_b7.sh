#!/bin/bash

#----------------------------------------------------
#      File-name: <-/bin/hartmann_b7.sh>
#       Language: bash script
#       Synopsis: Dollarkurs
#    Description: Probeklausur Aufgabe B.7
#        Project: Shell Script Programming Course
#         Author: hartmannka80488@th-nuernberg.de
#----------------------------------------------------

url="https://markets.businessinsider.com/currencies/eur-usd"
class="price-section__current-value"
value=$(curl --silent "$url" | grep -oP "(?<=<span class=\"$class\">).*?(?=</span>)")
echo "$value $"
