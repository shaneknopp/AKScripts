# AKScripts
Middleware and visualization tools making up some of a technology stack for a seismic tomography study. The [COSC492 repository](https://github.com/shaneknopp/COSC492) contains unfinished Python based inversion codes that intended to reduce the amount of data and inversion preparation scripts used.

## ATaCR
Cosmetic scripts used to modify the naming conventions for [Automated Tilt and Compliance Removal](https://github.com/helenjanisz/ATaCR) (ATaCR) input and back.
- **chEventDir.csh**: Takes the event directories from JWEED/PyWeed and puts them into ATaCR compliant directories and creates the eventTimes.txt list needed to run ATaCR.
- **chStatName.csh**: Chage name of stations to ATaCR compliant naming structure
- **changeStatNameBack.csh**: Chage name from ATaCR events to traditional naming structure

## dataprep
Domain specific scripts used for initial data modification directly after retreival from the [IRIS](https://www.iris.edu/hq/) database. 
- **correcttime.m**: Changes .SAC file header to the correct arguments passed by fixheaders.sh
- **make1sps.m**: Makes the data one sample per second (1 Hz) and writes to file with project naming structure
- **rmresp.m**: Remove instrument response
- **fixheaders.sh**: the "main" file that calls the others (also retreives datetime information from file naming)

## freqwindow
text

## inversionprep
text

## mapping
text
