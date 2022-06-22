#!/bin/tcsh

###
# Chage name from ATaCR events to traditional naming structure
# FROM: {yyyymmddhhMM}.{network}.{station}.{component}.sac -- Output of ATaCR
#   TO: {network}.{station}.{component}.SAC  -- Input for ATaCR

#
set homeDir=`pwd`

foreach eventDir (`ls -d 201*`)
    cd $homeDir/$eventDir
    echo $eventDir
    foreach event (`ls *.sac`)
    
    
    set temp=`echo $event | awk '{print substr($0,14,15)}'`
    set file=`echo $temp | awk '{sub("sac","SAC"); print $0}'`


    echo $event
    echo $file
    
    # Only uncomment if your are sure about the names
    echo Moving $event to $file
        mv $event $file
    echo -------------
end

end
