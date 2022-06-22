#!/bin/bash

###
# Chage current file naming structure to include serialized station numbers
# FROM: {network}.{station}.{component}.SAC
#   TO: {###}.{network}.{station}.{component}.SAC

homeDir=`pwd`

#Array used to store station names in ascending order of indices (ranging from 001-325 representing the standardized serialized station numbers from text file)
statList=(ACH AD06 AD07 AD08 AD09 AD11 AD13 AD14 AHB AKBB AKGG AKHS AKLV AKMO AKRB AKSA AKUT AKV ANCK ANM APEX2 AU22 AUCH AUJA AUJK AUL AULG AUNO AUSB AUSS AUW AUWS BPAW BRLK BRSE BWN CAHL CAPN CAST CCB CHGN CHI CHN CHUM CNP COLA CUT DHY DIV DOL DT1 DTN EP14 EP15 EP16 EP21 EP22 EP23 ET17 ET18 ET19 ET20 EYAK F1TN F2TN F3TN F4TN F5MN F6TP F7TV F8KN FALS FAPT FID FIRE FNN1 FNN2 FPAP FTGH G15K GCSA GHO GLI H16K H17K HARP HDA HIN HOM I17K I20K IL31 ILLG ILS ILSW ISLZ IVE J14K J16K J17K J18K J19K J20K J25K K13K K15K K17K K20K K24K KABU KAHG KAKN KARR KAWH KD00 KD01 KD02 KD04 KD05 KD12 KDAK KJL KLU KNK KS03 KS11 KS13 KT06 KT07 KT08 KT09 KT10 KTH L14K L15K L16K L17K L18K L19K L20K L22K LA21 LA23 LA25 LA26 LA28 LA29 LA30 LA32 LA33 LA34 LA39 LD35 LD36 LD37 LD38 LD40 LD41 LD44 LD45 LT01 LT02 LT03 LT04 LT05 LT06 LT07 LT08 LT09 LT10 LT11 LT12 LT13 LT14 LT15 LT16 LT17 LT18 LT20 LVA M11K M13K M14K M15K M16K M17K M18K M19K M20K M22K M23K M24K MAPS MCIR MCK MDM MGLS MGOD MID MNAT MSW MTBL N14K N15K N16K N17K N18K N19K N20K NCT NEA2 O14K O15K O16K O17K O18K O19K O20K O22K OHAK OKFG P16K P17K P18K P19K P23K PAX PLBL PLK1 PLK2 PLK3 PLK5 PN7A PPLA PS1A PS4A PWL Q16K Q17K Q18K Q19K Q20K Q23K R16K R17L R18K RC01 RDDF RDJH RDSO RDT RDWB RED RND S12K S14K SAW SCM SDPT SII SKN SLK SPBG SPBL SPCG SPCL SPCN SPCP SPCR SPNN SPU SPWE SSBA SSLN SSLS SSN STLK SVW2 SWD TRF TTA UNV WACK WAT1 WAT6 WAT7 WAZA WD46 WD47 WD48 WD49 WD50 WD51 WD52 WD53 WD54 WD55 WD56 WD57 WD58 WD59 WD60 WD61 WD62 WD63 WD64 WD65 WD66 WD67 WD68 WD69 WD70 WEBT WP24 WP25 WP30 WRH WS26 WS27 WS28 WS71 WS72 WS74 WS75 ZRO)

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
            #Store current file name - Will be used for concatenation
            file=`echo $event`
            
            #Incrementing count variable, starts at index 1 since range is 001-325
            count=1
            
            #Loop over every station name in statList
            for i in "${statList[@]}"
            do
                #Conditional to determine if the current station name from the array is in the file name in which case we break the loop
                if [[ $file == *$i* ]]; then
                    break
                fi
                #Increment the counting variable so it corresponds with statList
                ((count=count+1))
            done
            #Appends the serialized station number (by formatting the count variable to have leading zeros) to the front of the legacy file name
            newEvent=$(printf "%03d\n" $count).$file

            echo $event
            echo $newEvent
    
            # Only uncomment if your are sure about the names
            echo Moving $event to $newEvent
                #mv $event $newEvent
            echo -------------
        done

    done

done

