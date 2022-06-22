echo on //toggles printing to terminal
do file wild *SAC* //executes the commands below for files that contain SAC to set backboard variables (temporary places to store information)
 r $file
 setbb nt &1,knetwk //knetwk name of seismic network
 setbb st &1,kstnm //kstnm name of station
 setbb ch &1,kcmpnm //kcmpnm name of channel
 rmean //removes the mean
 rtrend //removes the linear trend
 taper //applies a symmetric taper to each end of data
 transfer from polezero subtype ../../AK_PZ/SAC_PZs_%nt%_%st%__%ch% to none freq 0.003 0.004 20 30 //
w over //
enddo //end the do loop


//what to do with upward sloping waveform
