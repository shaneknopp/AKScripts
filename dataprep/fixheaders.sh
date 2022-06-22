#!/bin/bash
#basically the control file for the other macros, they get called through here
echo on #toggles printing to terminal
for event in `ls -d 2*` #iterates over each folder whose name begins with 2 in the current directory
do
 cd $event #changes the directory to the present event folder
 pwd
 #uses data from the directory name and assignes it to variables representing time
 year=`echo ${event:0:4}` #start at index 0 go for 4 characters
 month=`echo ${event:5:2}` #start at index 5 go for 2 characters
 day=`echo ${event:8:2}` #start at index 8 go for 2 characters
 hour=`echo ${event:11:2}` #start at index 11 go for 2 characters
 minute=`echo ${event:14:2}` #start at index 14 go for 2 characters
 sec=`echo ${event:17:2}` #start at index 17 go for 2 characters
 msec=`echo ${event:20:3}` #start at index 20 go for 3 characters
 jday=`date -j -f "%Y %m %d" "$year $month $day" "+%j"` #not really sure what jday is
 echo $year $month $day $hour $minute $sec $msec #prints the time variables to terminal
 echo $jday #prints the jday variable to terminal
 printf "macro ../correcttime.m $year $jday $hour $minute $sec $msec\nq\n" | sac #runs correcttime.m script on the current event using sac?
 printf "macro ../rmresp.m\nq\n" | sac #runs rmresp.m script on the current event using sac?
 printf "macro ../make1sps.m\nq\n" | sac #runs the make1sps.m script on the current event using sac?
 rm *at* #deletes something? that contains at
 cd .. #moves back a directory, goes to next event
done
