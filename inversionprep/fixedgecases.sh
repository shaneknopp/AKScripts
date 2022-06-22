#!/bin/bash

###
# Chage current file naming structure to include serialized station numbers
# FROM: {network}.{station}.{component}.SAC
#   TO: {###}.{network}.{station}.{component}.SAC

homeDir=`pwd`

#Loop over every directory for each event (all of the folders)
for eventDir in `ls -d 201*`
do
    cd $homeDir/$eventDir
    
    #Loop over every period for every event
    for eventPer in `ls -d *s`
    do
        cd $homeDir/$eventDir/$eventPer
    
        #Loop over every SAC file for every period for each event
        for event in `ls *.SAC`
        do
            if [[ $event == "026.AV.AULG.LHZ.SAC" ]]; then
                echo Moving $event to "027.AV.AULG.LHZ.SAC"
                mv $event "027.AV.AULG.LHZ.SAC"
            fi
            if [[ $event == "031.AV.AUWS.LHZ.SAC" ]]; then
                echo Moving $event to "032.AV.AUWS.LHZ.SAC"
                mv $event "032.AV.AUWS.LHZ.SAC"
            fi
            if [[ $event == "094.AV.ILSW.LHZ.SAC" ]]; then
                echo Moving $event to "095.AV.ILSW.LHZ.SAC"
                mv $event "095.AV.ILSW.LHZ.SAC"
            fi
        done

    done

done
