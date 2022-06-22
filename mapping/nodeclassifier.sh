#!/bin/bash

while getopts s:e:z: flag
do
    case "${flag}" in
        s) start=${OPTARG};;
        e) end=${OPTARG};;
        z) zone=${OPTARG};;
    esac
done

for i in `cat nodeareas.txt | awk '{print $1}'`
do
	if (( start <= i && end >= i )); then
		awk 'BEGIN{FS=OFS=" "}NR==n{$3=a}1' n="$i" a="$zone" nodeareas.txt > temp && mv temp nodeareas.txt
	fi
done
