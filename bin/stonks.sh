#!/bin/bash

#----------------------------------------------------
#      File-name: <-/bin/stonks.sh>
#       Language: bash script
#       Synopsis: Download and visual display of stock data
#    Description: Calls Alpha vantage API and may even diplay it soirt of cool
#        Project: Shell Script Programming Course
#         Author: hartmannka80488@th-nuernberg.de
#----------------------------------------------------

function set_interval()
{
  arr=("1" "5" "15" "30" "45" "60")
  if [[ " ${arr[*]} " =~ " ${1} " ]]; then
    interval="${1}min"
  else
    echo "Invalid interval. Must be 1, 5, 15, 30, 45 or 60."
    exit 0;
  fi
}

# Clear debug file
true > debug.txt

# Script parameters
version=0.0.1
draw=1

# API parameters
func=TIME_SERIES_INTRADAY
interval=15min
apikey=AV6H9H7PL4L284AY
datatype=csv

while [[ "${1-}" =~ ^- ]]; do
  case "$1" in
    -v | --version )  echo "version $version" ; exit 0 ;;
    -s | --symbol ) shift ; symbol=$1 ;; 
    -i | --interval ) shift ; set_interval "$1" ;;
    -b | --brief ) draw=0 ;;
    -h | --help ) cat stonks_man.txt ; echo ; exit 0 ;;
    --) shift ; break ;;
    *)  echo "Invalid option '$1'" >&2 ; exit 1 ;;
  esac
  shift
done

if [ -z "$symbol" ]; then
  echo 'Missing -s' >&2
  exit 1
fi

# Find max number in array
function max()
{
  max=$(printf '%s\n' "${@}" | \
  awk '$1>max||NR==1 {max=$1}
      END {print max}')
  printf "%s" "$max"
  return 0;
}


# Find min value in array
function min()
{
  min=$(printf '%s\n' "${@}" | \
  awk '$1<min||NR==1 {min=$1}
      END {print min}')
  printf "%s" "$min"
  return 0
}


# Print symbol n times 
# @param: n symbol
repeat()
{
  for ((i=1; i<=$1; i++)); do printf "%s" "$2"; done
  return 0
}

#Print symbol n times in a vertical line
# @param: y x n symbol
function repeat_vertical() 
{
  for ((yshift=0; yshift<=$3; yshift++)); do 
    tput cup $(($1+yshift)) "$2"
    printf "%s" "$4"
  done
  return 0
}

# Floating point calculator
# Can be passed an arithmetic expression to calculate
function calc() { awk "BEGIN{ printf \"%.4f\n\", $* }"; }

# Mapping function used in glsl
# @param: value min1 max1 min2 max2
function map
{
  v=$(calc "($4+($1-$2)*($5-$4)/($3-$2))")
  echo "$v"
  return 0
}


# Draw a text box with a value in the center
# @param: x y title value
function draw_value_box() 
{
  x=$1
  y=$2
  text="$3: $4"
  size=${#text}

  tput cup "$((y++))" "$x"
  repeat "$size" "-"
  tput cup "$((y++))" "$x"
  printf "%s" "$text"
  tput cup "$y" "$x"
  repeat "$size" "-"

  return 0
}

# Draw axes with specified size, dimensions and axis names 
# @param:  origin_x origin_y dim_x dim_y 
function draw_stock()
{
  # X-Axis
  tput bold
  tput cup "$2" "$1"
  repeat "$3" "_"
  tput sgr0  

  # Y-Axis
  tput bold
  repeat_vertical $(($2-$4)) "$1" "$4" "|" 
  tput sgr0  

  # X-Labels  
  timestamp_length=5
  for (( i=$(($1+1)); i<=$(($1+$3-timestamp_length)); i+="$timestamp_length" )); do
    idx=$(map "$i" "$1" $(($1+$3)) $((${#timestamp[@]}-1)) 1 | cut -d, -f1)
    tput cup $(($2+1)) $((i))
    printf "\u2319%s" "${timestamp[idx]:11:5}"
    i=$((i+timestamp_length))
  done



  # Y-Labels
  ymin=$(("${minmin%\.*}"))
  ymax=$(("${maxmax%\.*}+1"))

  for (( i="$ymin"; i<="$ymax"; i++ )); do
    posy=$(map "$i" "$ymin" "$ymax" "$2" $(($2-$4)) | cut -d, -f1)
    tput cup "$posy" $(($1-(${#i}+1)))
    printf "%s\u2015" "$i"
  done


  # Figure out color of graph
  color=2 # Green
  if (( $(echo "$first_close > $last_close" | bc -l) )); then
    color=1 # Red
  fi
  tput setab $color

  # Figure out positions and draw 
  for ((i=1; i<$3; i++)); do
    # Index to look up value
    idx=$(map $i "$3" 1 $(( ${#timestamp[@]} - 1 )) 1 | cut -d, -f1)
    val=${close[$idx]}

    # Y-Position of value in coordinate system
    posy=$(map "$val" "$ymin" "$ymax" "$2" $(($2-$4)) | cut -d, -f1)

    tput setab $color
    tput cup $(($2-posy)) $(($1+i))
    printf "%s" " "
    tput setab 7
    repeat_vertical $(($2-posy+1)) $(($1+i)) $((posy-2)) " " 
  done
  tput sgr0  

  return 0
}


# TODO: maybe convert to generic key event handler
# Infinite loop that stops when specified key is presse, might just be tempporary solution for debugging
# Converts inputs to lower case letters before matching, so parameters should be lower case as well
# @param: key 
function exit_loop()
{
  while true; do
  tput cup "$h" 0
    printf "Press %s to exit \t\t: " "$1"
    read -n1 -r input
    if [[ ${input,,} = "$1" ]] 
        then break 
    else 
        printf "Invalid Input."
    fi
  done
}


############
#   START
############

# Screen dimensions
w=$(tput cols)
h=$(tput lines)
qh=$((h/4))

# Get stock data from Alpha Vantage API and save to csv
url="https://www.alphavantage.co/query?function=$func&symbol=$symbol&interval=$interval&apikey=$apikey&datatype=$datatype"
curl -o stock.csv "$url"

# Parse csv to arrays
while IFS=',' read -ra arr; do 
   timestamp+=("${arr[0]}")
   open+=("${arr[1]}")
   high+=("${arr[2]}")
   low+=("${arr[3]}")
   close+=("${arr[4]}")
   volume+=("${arr[5]}")
done < stock.csv

if [[ ${timestamp[1]} == *Error* ]]; then
  printf "%s\n" "Error, invalid symbol: $symbol. Exiting."
  exit 1
fi

# Print absolute values on right
maxmax=$(max "${high[@]:1}")
minmin=$(min "${low[@]:1}")
first_close=${close[-1]}
last_close=${close[1]}

if [[ $draw == 1 ]]; then
  # Save & clear screen
  tput smcup
  tput cup 0 0
  tput ed

  draw_value_box $((w-15)) 0 Open "$first_close"
  draw_value_box $((w-15)) $((qh)) Low "$minmin"
  draw_value_box $((w-15)) $((qh*2)) High "$maxmax"
  draw_value_box $((w-15)) $((qh*3)) Close "$last_close"
  
  graph_x=5
  graph_y=$((h-5))
  graph_w=$((w-graph_x-14-5))
  graph_h=$((h-5-1))
  draw_stock $graph_x $graph_y $graph_w $graph_h

  # Start the exit loop
  exit_loop q

  # Restore screen
  tput rmcup

else 
  printf "Start: %s\n" "$first_close"
  printf "Low: %s\n" "$minmin"
  printf "Hight: %s\n" "$maxmax"
  printf "Close: %s\n" "$last_close"
fi
