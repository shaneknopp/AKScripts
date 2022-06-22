#!/bin/tcsh

###
# Chage name of stations to ATaCR compliant naming structure
#   TO: {yyyymmddhhMM}.{network}.{station}.{component}.sac  -- Input for ATaCR
###

set network=XO
set homeDir=`pwd`

foreach eventDir (`ls -d 201*`)
    cd $homeDir/$eventDir
    echo $eventDir
    foreach event (`ls *.SAC`)
    

    set station=`echo $event | awk -F. '{print $2}'`
    set component=`echo $event | awk -F. '{print $4}'`

    # Get parameters from SAC files
    set year=`echo $event | awk -F_ '{print $5}' | awk -F- '{print $1}'`
    set month=`echo $event | awk -F- '{print $2}'`
    set day=`echo $event | awk -F- '{print $3}' | awk -FT '{print $1}'`
    set hour=`echo $event | awk -FT '{print $2}' | awk -F. '{print $1}'`
    set minute=`echo $event | awk -F. '{print $6}'`
#    set jday=`date -j -f "%Y %m %d" "$year $month $day" "+%j"`


#                {yyyymmddhhMM}.{network}.{station}.{component}.sac
    set newEvent=${year}${month}${day}${hour}${minute}.$network.$station.$component.sac
    
    # Only uncomment if your are sure about the names
    echo Moving $event to $newEvent
    #mv $event $newEvent
    echo -------------
end

end
