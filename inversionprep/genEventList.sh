#!/bin/bash

homeDir=`pwd`

eventList=(2018-05-02T06.32.48.880_6.0 2018-05-05T06.19.05.040_6.1 2018-05-09T07.57.55.250_6.0 2018-05-09T10.41.45.920_6.2 2018-05-18T01.45.31.300_6.1 2018-06-21T21.13.32.650_6.1 2018-07-07T21.33.49.630_6.0 2018-07-13T09.46.49.640_6.4 2018-07-15T01.57.19.410_6.0 2018-07-15T13.09.16.470_6.0 2018-07-17T07.02.53.020_6.0 2018-07-19T18.30.32.710_6.0 2018-07-28T17.07.23.370_6.0 2018-07-28T22.47.38.740_6.4 2018-08-05T11.46.38.190_6.9 2018-08-16T18.22.53.360_6.3 2018-08-17T15.35.01.870_6.5 2018-08-17T23.22.24.900_6.1 2018-08-19T00.19.40.670_8.2 2018-08-19T00.23.06.180_6.3 2018-08-19T04.10.23.490_6.3 2018-08-19T04.28.58.700_6.8 2018-08-19T14.56.28.030_6.9 2018-08-21T21.31.47.540_7.3 2018-08-21T22.32.26.850_6.5 2018-08-25T22.13.25.620_6.0 2018-08-28T07.08.11.270_6.2 2018-08-28T22.35.13.410_6.4 2018-09-05T18.07.59.150_6.6 2018-09-06T15.49.14.420_7.9 2018-09-07T02.12.04.350_6.2 2018-09-08T07.16.49.620_6.2 2018-09-09T19.31.35.090_6.5 2018-09-10T04.19.02.630_6.9 2018-09-10T19.31.37.420_6.3 2018-09-28T06.59.59.780_6.1 2018-09-28T10.02.43.480_7.5 2018-10-01T23.59.42.730_6.0 2018-10-10T18.44.55.280_6.0 2018-10-10T20.45.26.530_6.1 2018-10-10T22.00.34.500_6.2 2018-10-16T00.28.12.710_6.3 2018-10-16T01.03.43.090_6.4 2018-10-30T02.13.39.550_6.1 2018-11-01T22.19.51.540_6.2 2018-11-04T07.55.28.010_6.0 2018-11-09T01.49.40.060_6.7 2018-12-05T04.18.08.400_7.5 2018-12-05T06.43.04.120_6.6 2018-12-29T03.39.09.740_7.0 2019-01-06T17.27.20.670_6.6 2019-01-15T18.06.34.290_6.6 2019-01-20T01.32.51.850_6.7 2019-02-01T16.14.13.090_6.6 2019-02-22T10.17.22.410_7.5 2019-03-01T08.50.42.620_7.0 2019-04-11T08.18.21.380_6.0 2019-04-12T11.40.49.886_6.8 2019-05-06T21.19.37.981_7.1 2019-06-15T22.55.04.132_7.3 2019-06-24T02.53.39.830_7.3 2019-07-06T03.19.53.040_7.1 2019-07-14T05.39.23.427_6.6 2019-07-14T09.10.50.533_7.3 2019-07-31T15.02.33.853_6.6 2019-08-02T12.03.27.483_6.9 2019-09-25T23.46.43.029_6.5 2019-10-29T01.04.43.863_6.6 2019-10-31T01.11.19.122_6.5 2019-11-04T22.43.32.280_6.6 2019-11-14T16.17.40.582_7.1 2019-12-15T06.11.51.155_6.8)

#Loop over every directory for each event (all of the folders)
for eventDir in `ls -d 201*`
do
    cd $homeDir/$eventDir
    
    #Loop over every period for every event
    for eventPer in `ls -d *s`
    do
        cd $homeDir/$eventDir/$eventPer

        firstTwo=`echo ${eventPer:0:2}`
        shopt -s nullglob
        numfiles=(*.SAC)
        #can also use numfiles=`ls | wc -l`
        
        eventNum=1
        for i in "${eventList[@]}"
        do
            if [[ $eventDir == $i ]]; then
                break
            fi
            #Increment the counting variable so it corresponds with statList
            ((eventNum=eventNum+1))
        done
        echo ${#numfiles[@]} $eventNum >> ../../eqlists/eqlist.$firstTwo.txt
        echo $firstTwo $eventNum >> ../../eqlists/total.txt

        #Loop over every SAC file for every period for each event
        for event in `ls *.SAC`
        do
            echo `pwd`/$event >> ../../eqlists/eqlist.$firstTwo.txt
        done
    done
done
