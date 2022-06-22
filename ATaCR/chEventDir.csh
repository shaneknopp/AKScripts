#!/bin/tcsh

###
# This script takes the event directories from Jweed and puts them into
# ATaCR compliant directories.  It also creates the eventTimes.txt list
# needed to run ATaCR.
# This does NOT change the event file names. Use chEventNames.csh
#
# FROM: YYYY-mm-ddThh.MM.ss.msec_Mag -- Input format of directories (Obtained from Jweed)
#   TO: YYYYmmddhhMM -- Output format of directories (ATaCR compliant) --
# YYYY -year
# mm - month
# dd - day
# hh - hour
# MM - minute
# T  - Just a "T" that Jweed puts in the name
# ss - seconds
# msec - miliseconds
# Mag - Magnitude
#
# Directory structure:
#  YYYY-mm-ddThh.MM.ss.msec_Mag
#
# Modified Jun 2022 - sknopp
####

ls -d 201* > oldEventList.txt

foreach event (`ls -d 201*`)
    # YYYY-mm-ddThh.MM.ss.msec_Mag
    set YYYY=`echo $event | awk -F- '{print $1}'`
    set mm=`echo $event | awk -F- '{print $2}'`
    set dd=`echo $event | awk -F- '{print $3}' | awk -FT '{print $1}'`
    set hh=`echo $event | awk -F- '{print $3}' | awk -FT '{print $2}' | awk -F. '{print $1}'`
    set MM=`echo $event | awk -F. '{print $2}'`
#    set sec=`echo $event | awk -F. '{print $3}'`
#    set msec=`echo $event | awk -F. '{print $4}' | awk -F_ '{print $1}'`
#    set jday=`date -j -f "%Y %m %d" "$yyyy $mm $dd" "+%j"`

#    echo $YYYY
#    echo Month $mm
#    echo Day $dd
#    echo Hour $hh
#    echo Minute $MM
#    echo Second $sec
#    echo Milisec $msec
    
    set newEvent=${YYYY}${mm}${dd}${hh}${MM}
#   YYYYmmddhhMM
    
    echo $event
    echo $newEvent
    mv $event $newEvent
    echo -------------
end
