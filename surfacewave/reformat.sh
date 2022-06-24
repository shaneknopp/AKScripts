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

for i in `ls velocityout.*.txt`
do
    period=`echo ${i:12:3}`
    nodeNum=1
    for j in `cat $i | awk '{print $2}'`
    do
        echo $j $period >> $(printf "%04d\n" $nodeNum)/velocities.txt
        ((nodeNum=nodeNum+1))
    done
done
