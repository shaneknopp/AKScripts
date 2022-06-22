*echo on //toggles printing to terminal
do file wild *SAC*
 r $file
 setbb dt &1,delta
 if &1,delta lt 0.0101 && &1,delta gt 0.0099 
  dec 5
  dec 5
  dec 4
 elseif &1,delta lt 0.021 && &1,delta gt 0.019
  dec 5
  dec 5
  dec 2
 elseif &1,delta lt 0.026 && &1,delta gt 0.024
  dec 5
  dec 4
  dec 2
 elseif &1,delta lt 0.051 && &1,delta gt 0.049
  dec 5
  dec 4
 elseif &1,delta lt 1.15 && &1,delta gt 0.85
* do nothing
 else
  lh delta
  $KILL
 endif
 if &1,delta lt 1.15 && &1,delta gt 0.85
  ch delta 1
  setbb nt &1,knetwk
  setbb st &1,kstnm
  setbb ch &1,kcmpnm
  //setbb chend (SUBSTRING 3 3 &1,kcmpnm)
  //w %nt%.%st%.LH%chend%.SAC
  w %nt%.%st%.LHZ.SAC //write a file using the naming convention network.station
 else
  lh delta
 endif
enddo
