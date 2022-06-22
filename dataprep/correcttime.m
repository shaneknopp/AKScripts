echo on //toggles printing to terminal
 do file wild *SAC* //executes the commands below for files that contain SAC to update the header for the event
  r $file //??
  chnhdr o gmt $1 $2 $3 $4 $5 $6 //sets the origin time
  chnhdr ALLT (0 - &1,o&) iztype io
*  chnhdr allt (o - &1,o&) iztype io //subtracts origin time from all defined times
  wh //??
 enddo //end the do loop
