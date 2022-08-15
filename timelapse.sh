#!/bin/bash
if [[ "$1" == "-h" ]]
   then echo "Feed me Seymore!"
   echo "./timelapse [#photos] [#timebetweenphotos(sec)] [#britenessthreshold] [#shutter(microseconds)] [#ISO] [#path]"
   exit 1
fi

cd ${6:-/home/pi/tl1}
#set global variables
Shutter=${4:-125000}
ISO=${5:-100}
Filename=100
NumofFiles=${1:-100000}
Brightness=${3:-25000}
Brightnessthreshold=$Brightness
Slackhigh=`echo "($Brightness/20) + $Brightness" | bc`
Slacklow=`echo "$Brightness - ($Brightness/20)" | bc`
Bump=0

#take photos
for ((i=1; i<=${1:-100000}; i++))
 do
   echo "Sleeping ${2:-1}"
   sleep ${2:-1}
   echo "Taking pic $i of $NumofFiles filename:$Filename.jpg"
   raspistill -o $Filename.jpg -ss $Shutter -ISO $ISO -w 1290 -h 720 -rot 180 -t 1 -n
   echo "raspistill -o $Filename.jpg -ss $Shutter -ISO $ISO -w 1290 -h 720 -rot 180 -t 1 -n"
   echo "slacklow" $Slacklow
   echo "slackhigh" $Slackhigh
   
   if [ $Filename -gt "100" ]
   then
      file=$(($Filename + 1))
      Brightness=`convert $Filename.jpg -colorspace Gray -format "%[fx:quantumrange*image.mean]" info:`
      Brightness=`echo "($Brightness+0.5)/1" | bc`
      echo "Brightness:" $Brightness
   fi
   echo "ISO:" $ISO
   echo "Shutter:" $Shutter
   Filename=$(($Filename + 1))


                if [ $Brightness -lt $Slacklow ]
                then
                        if [ $ISO -lt "800" ] && [ $ISO -gt "99" ] && [ $Shutter -gt "500000" ]
                        then
                           ISO=$((ISO + 100))
                           Shutter=`echo "($Shutter / 2) + ($Shutter / 3)" | bc`
                           
                        else
                           if [ $Shutter -lt "500001" ]
                           then	
                              Shutter=`echo "($Shutter / 3) + $Shutter" | bc`
                              
                           else
                              if [ $Shutter -lt "6021021" ] && [ $Shutter -gt "500000" ]
                              then
                                Shutter=`echo "($Shutter / 4) + $Shutter" | bc`

                                else 
                                 if [ $Shutter -gt "6021022" ]
                                 then
                                   Shutter=6021021
                                 fi  
                              fi
                            fi
                        fi

                fi


                if [ $Brightness -gt $Slackhigh ]
                then
                        if [ $ISO -gt "100" ] && [ $ISO -lt "800" ] && [ $Shutter -lt "200000" ]
                        then
                           ISO=$((ISO - 100))
                           
                        else
                           if [ $Shutter -lt "500001" ]
                           then	
                              Shutter=`echo "$Shutter - ($Shutter/3)" | bc`
                              
                           else
                              if [ $Shutter -lt "6021021" ] || [ $Shutter -eq "6021021" ] && [ $Shutter -gt "500000" ]
                              then
                                 Shutter=`echo "$Shutter - ($Shutter/4)" | bc`
                                 
                              else 
                                 if [ $Shutter -gt "6021021" ]
                                 then
                                   Shutter=5750000
                                   
                                 fi  
                              fi
                            fi
                        fi
                fi

                if [ $ISO -gt "799" ] && [ $Shutter -gt "1550000" ] && [ $Brightness -lt "35000" ] && [ $Bump -lt "1" ] && [ $Shutter -lt "6021021" ]
                then
                   Slackhigh=`echo "($Slackhigh/10) + $Slackhigh" | bc`
                   echo "New Slackhigh: $Slackhigh"
                   Slacklow=`echo "($Slacklow/10) + $Slacklow" | bc`
                   echo "New Slacklow: $Slacklow"
                   Bump=$((Bump + 1))
                else
                   if [ $Bump -gt "0" ] && [ $Bump -eq "3" ]
                   then
                      Bump=$((Bump + 1))
                      echo "Bump:" $Bump
                   else
                      if [ $Bump -gt "2" ]
                      then
                         Bump=0
                         echo "Bump:" $Bump
                      fi
                   fi
                fi


done
