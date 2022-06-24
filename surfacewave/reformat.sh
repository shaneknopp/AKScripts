#!/bin/bash

for i in `cat nodelocs.txt | awk '{print $1}'`
#for i in {1..1363}
do
    dir=$(printf "%04d\n" $i)
    if [[ -d "$dir" ]]; then
        break
    fi
    mkdir $dir
done

for i in `ls velocityout2d/velocityout.*.txt`
do
    period=`echo ${i:26:8}`
    nodeNum=1
    for j in `cat $i | awk '{print $2}'`
    do
        echo $period $j >> $(printf "%04d\n" $nodeNum)/velocities.txt
        ((nodeNum=nodeNum+1))
    done
done
