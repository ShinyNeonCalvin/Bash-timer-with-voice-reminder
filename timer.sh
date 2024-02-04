#!/bin/bash 
#a timer script mostly found online at:
#https://linuxconfig.org/time-countdown-bash-script-example
#takes string for voice command when time runs out

SCRIPT=$0

#Error message/instructions with incorrect usage
if [ "$#" -lt "2" ] || ! [[ "$1" =~ -[dhmsht] ]] || ! [[ "$2" =~ ^[0-9] ]] 
then 
	echo "Usage and options:" 
	echo "${SCRIPT##*/} -s 10 for seconds"
	echo "${SCRIPT##*/} -d Jun 10 2011 16:06 or 17:30 for date" 
	echo "${SCRIPT##*/} -m 90 for minutes" 
	echo "${SCRIPT##*/} -h 2 for hours"
	echo "${SCRIPT##*/} -hm 1 20 for hours plus minutes"
	echo "${SCRIPT##*/} -hms 1 20 23 for hours, minutes, seconds"
	exit 1 
fi 

#text string saved as reminder, command for user, etc.
read -p "What do you want the robot to say when time runs out? " string

#declares "now" as time in seconds 
now=$(date +%s) 

#with option -d, converts your end time into seconds added
#to current second of system clock, then sets up countdown
#variable 
if [ "$1" = "-d" ] ; then 
	until=$(date -d "$2" +%s) 
	sec_rem=$(expr $until - $now) 
	#message for if you choose countdown for zero seconds
	if [ $sec_rem -lt 1 ]; then 
		echo "$2 is already history !" 
	fi 
fi 
#minute option
if [ "$1" = "-m" ] ; then 
	until=$(expr 60 \* $2) 
	until=$(expr $until + $now) 
	sec_rem=$(expr $until - $now) 
	if [ $sec_rem -lt 1 ]; then 
		echo "$2 is already history !" 
	fi 
fi 
#second option
if [ "$1" = "-s" ] ; then 
	until=$(expr $2) 
	until=$(expr $until + $now) 
	sec_rem=$(expr $until - $now) 
	if [ $sec_rem -lt 1 ]; then 
		echo "$2 is already history !" 
	fi 
fi 
#hour option
if [ "$1" = "-h" ] ; then 
	until=$(expr $2 \* 60 \* 60) 
	until=$(expr $until + $now) 
	sec_rem=$(expr $until - $now) 
	if [ $sec_rem -lt 1 ]; then 
		echo "$2 is already history !" 
	fi 
fi 

#added section for using hours and minutes
#at once, so user doesn't have to do math
if [ "$1" = "-hm" ] ; then 
	until=$((("$2" * 60 * 60) + ("$3" * 60))) 
	until=$(expr $until + $now) 
	sec_rem=$(expr $until - $now) 
	if [ $sec_rem -lt 1 ]; then 
		echo "$2 is already history !" 
	fi 
fi 

#like above but incorperates seconds as well
if [ "$1" = "-hms" ] ; then 
	until=$((("$2" * 60 * 60) + ("$3" * 60) + "$4")) 
	until=$(expr $until + $now) 
	sec_rem=$(expr $until - $now) 
	if [ $sec_rem -lt 1 ]; then 
		echo "$2 is already history !" 
	fi 
fi 

#Variables set for graphical part of timer
_R=0
_C=7
tmp=0
percent=0
total_time=0
col=$(tput cols)
col=$(( col-5 ))
#loop for program function
while [ $sec_rem -gt 0 ]; do 
	#clear allows for progress to keep changing on screen
	clear 
	#shows date at top of screen
	date 
	#subtract second for each second
	let sec_rem=$sec_rem-1 
	#variable for remaining time
	interval=$sec_rem 
	#variable containing remaining number of seconds within each minute with modulo
	#for remainder
	seconds=$(expr $interval % 60) 
	#subtracts remaining seconds from interval, used to update remaining time
	interval=$(expr $interval - $seconds) 
	#shows remaining minutes within hour by dividing total seconds by 3600 with
	#remainder and then dividing by 60, shows minutes from seconds in minutes
	minutes=$(expr $interval % 3600 / 60)
	#sets interval to amount subtracted 
	interval=$(expr $interval - $minutes) 
	#shows remaining hours by dividing seconds in day with remainder, then seconds
	#in hour, shows hours from seconds in hours
	hours=$(expr $interval % 86400 / 3600) 
	#set interval to amount subtracted
	interval=$(expr $interval - $hours) 
	#shows remaining days by dividing seconds in week with remainder, then seconds 
	#in day, shows remaining days from seconds in a day
	days=$(expr $interval % 604800 / 86400) 
	#sets interval to amount subtracted
	interval=$(expr $interval - $hours) 
	#shows number of weeks remaining by dividing interval from seconds in week
	weeks=$(expr $interval / 604800) 
	#the display of seconds, minutes, hours days weeks
	echo "----------------------------" 
	echo "Seconds: " $seconds 
	echo "Minutes: " $minutes 
	echo "Hours:   " $hours 
	echo "Days:    " $days 
	echo "Weeks:   " $weeks 
	#start of progress bar
	echo -n "["
	#sets progress beginning with + 1
	progress=$((progress + 1))
	if [ $total_time -lt 1 ] ; then
		#sets total time to seconds in hours plus seconds in minutes plus seconds
		total_time=$((hours * 3600 + minutes * 60 + seconds))
	fi
	#creates variable with printf, replaces empty space with = sign in progress bar
	#defines a character width, and subsitutues "=" for all blank spaces in that char length
	printf -v f "%$(echo $_R)s>" ; printf "%s\n" "${f// /=}"
	_C=7
	#positions cursor on line 7 and $col character column
	tput cup 7 $col

	tmp=$percent
	#multiples progress by 100 and divides by total time for percentage
	percent=$((progress * 100 / total_time))
	#displays last part of progress bar, substitues percentage at the end of progress bar
	printf "]%d%%" $percent

	#increases value of _R to percentage complete
	_R=$(( col * percent / 100 ))
    #sleep 1 is what makes script into a valid timer, otherwise the script would quickly run itself out
	sleep 1
done
#puts newline for look at end of timer
printf "\n"
#loops robot voice at end of script and every 10 minutes while process keeps going,
#as an additional reminder if your time is already up
while true; do
	spd-say "$string"
	sleep 600
done
