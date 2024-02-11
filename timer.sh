#!/bin/bash 
#a souped up version of a bash script found online:
#https://linuxconfig.org/time-countdown-bash-script-example
#takes string for voice command to remind you when time is up
SCRIPT=$0
#Error message or reminder if no or improper arguments used
if [[ "$#" -lt "1" ]] || ! [[ "$1" =~ ^-[idhmsht] ]]; then 
  echo -e "Usage:" 
  echo -e
  echo -e "\t${SCRIPT##*/} -i indefinite: counts time passed until cancel."
  echo -e "\tWorks like a stopwatch."
  echo -e
  echo -e "\t${SCRIPT##*/} -s [number-of-seconds]: for second countdown."
  echo -e
  echo -e "\t${SCRIPT##*/} -d \"Jun 10 2011 16:06\", 17:30, or just hour of current day"
  echo -e "\tin military time. Counts down to specified date or time."
  echo -e
  echo -e "\t${SCRIPT##*/} -m [number-number-of-minutes] for minute countdown."
  echo -e
  echo -e "\t${SCRIPT##*/} -h [number-of-hours] for hour countdown."
  echo -e
  echo -e "\t${SCRIPT##*/} -hm [hours] [minutes] for hours plus minute countdown."
  echo -e
  echo -e "\t${SCRIPT##*/} -hms [hours] [minutes] [seconds] for hour, minute, second countdown."
  exit  1 
fi 

now=$(date +%s) 

case $1 in
  -d)
      until=$(date -d "$2" +%s) 
      sec_rem=$((until - now)) 
      #message for if you choose countdown for zero seconds
      if [ $sec_rem -lt 1 ]; then 
        echo "$2 is already history !" 
      fi 
      ;;
##minute option
  -m)
      until=$((60 * $2)) 
      until=$((until + now)) 
      sec_rem=$((until - now)) 
      if [ $sec_rem -lt 1 ]; then 
        echo "$2 is already history!" 
      fi 
      ;;
##second option
  -s)
      until=$2 
      until=$((until + now)) 
      sec_rem=$((until - now)) 
      if [ $sec_rem -lt 1 ]; then 
        echo "$2 is already history!" 
      fi 
      ;;
##hour option
  -h)
      until=$(($2 * 60 * 60)) 
      until=$((until + now)) 
      sec_rem=$((until - now)) 
      if [ $sec_rem -lt 1 ]; then 
        echo "$2 is already history!" 
      fi 
      ;;
##added section for using hours and minutes
##at once, so user doesn't have to do math
  -hm)
      until=$((("$2" * 60 * 60) + ("$3" * 60))) 
      until=$((until + now)) 
      sec_rem=$((until - now)) 
      if [ $sec_rem -lt 1 ]; then 
        echo "$2 is already history!" 
      fi 
      ;;
##like above but incorporates seconds as well
  -hms)
      until=$((("$2" * 60 * 60) + ("$3" * 60) + "$4")) 
      until=$((until + now)) 
      sec_rem=$((until - now)) 
      if [ $sec_rem -lt 1 ]; then 
        echo "$2 is already history !" 
      fi 
      ;;
     *)
      ;;
esac      

if [ $1 = "-i" ]; then
  seconds=0
  minutes=0
  hours=0
  days=0
  weeks=0

  while true; do
    clear
    #reset smaller units for measuring time when larger units have
    #passed
    if [ $seconds -gt 59 ]; then
      seconds=0
      ((minutes++))
    fi

    if [ $minutes -gt 59 ]; then
      seconds=0
      minutes=0
      ((hours++))
    fi

    if [ $hours -gt 23 ]; then
      seconds=0
      minutes=0
      hours=0
      ((days++))
    fi

    if [ $hours -gt 167 ]; then
      seconds=0
      minutes=0
      hours=0
      ((weeks++))
    fi
    #display date and time passed
    date
    echo "----------------------------" 
    printf "Seconds: %i\n" $seconds 
    printf "Minutes: %i\n" $minutes 
    printf "Hours:   %i\n" $hours 
    printf "Days:    %i\n" $days 
    printf "Weeks:   %i\n" $weeks 
    echo -e "\nPress ctrl+c to end timer."
    echo -e "Press ctrl+z to pause timer, then enter fg to pick up"
    echo -e "where you left off."
    #delay one second and add to seconds
    sleep 1

    ((seconds++))
  done
else
  #text string saved as reminder, command for user, etc.
  echo "What do you want the robot to say when time runs out?"
  echo "Type reminder or enter -1 for silence: "
  read string

  #captures "now" as time in seconds 
  now=$(date +%s) 
  #values used later for status bar
  _R=0
  _C=7
  tmp=0
  percent=0
  total_time=0
  #value represents character columns of terminal
  col=$(tput cols)
  #subtracts col to make room for percentages and
  #brackets on screen
  col=$((col - 5))
  #loop for timer
  while [ $sec_rem -gt 0 ]; do 
    clear 

    date 
    #subtracts second from countdown
    ((sec_rem--))

    interval=$sec_rem 
    #calculates new time for display
    #by subtracting each unit from
    #interval
    seconds=$((interval % 60)) 

    interval=$((interval - seconds)) 

    minutes=$((interval % 3600 / 60))

    interval=$((interval - minutes)) 

    hours=$((interval % 86400 / 3600)) 

    interval=$((interval - hours)) 

    days=$((interval % 604800 / 86400)) 

    interval=$((interval - days)) 

    weeks=$((interval / 604800)) 
    #the display of seconds, minutes, hours days weeks
    echo "----------------------------" 
    echo "Seconds: " $seconds 
    echo "Minutes: " $minutes 
    echo "Hours:   " $hours 
    echo "Days:    " $days 
    echo "Weeks:   " $weeks 
    #start of progress bar
    echo -n "["

    progress=$((progress + 1))
    if [ $total_time -lt 1 ] ; then
      total_time=$((hours * 3600 + minutes * 60 + seconds))
    fi

    printf -v f "%$(echo $_R)s>" ; printf "%s\n" "${f// /=}"
    _C=7

    tput cup 7 $col

    tmp=$percent
    #multiples progress by 100 and divides by total time for percentage
    percent=$((progress * 100 / total_time))
    #displays last part of progress bar, substitues percentage at the end of progress bar
    #line below displayed the = sign in pregress bar
    _R=$(( col * percent / 100 ))
    #increases value of _R to percentage complete
    #second delay
    printf "]%d%%" $percent
    echo -e "\n\nPress ctrl+c to end timer."
    echo -e "Press ctrl+z to pause timer, then enter fg to pick up"
    echo -e "where you left off."
    sleep 1
  done
fi

printf "\n"

#triggers spd-say robot voice, loops every 10 minutes
#as a reminder until this script ends
while true; do
  if [ "$string" = "-1" ]; then
    exit
  fi

	spd-say "$string"

  echo -e "\nPress ctrl+c to return to command prompt."

	sleep 600
done
