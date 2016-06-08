#!/bin/bash

############################
##                        ##
## XDS Input Copy Script  ##
##                        ##
## Created by Jim Fairman ##
## Last Modified:01-12-15 ##
##                        ##
############################

###########################
# SET DIRECTORY VARIABLES #
###########################

scriptdir=/usr/local/usrlocal/xds_scripts
targetdir=$(pwd)

###########################
# END DIRECTORY VARIABLES #
###########################


#######################
# MENU FUNCTION START #
#######################

function menu() {

clear
echo '

+-=-=-=-=-=-=-=-=-=-=-=<([XDS INPUT COPY SCRIPT])>=-=-=-=-=-=-=-=-=-=-=-=+
|               Tell me where your data was collected:                   |
+-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=+
|  ALS         APS          SSRL       In-House          AUS   Oh Canada |
| 1)501   6)LSCAT 21ID-D  11)7-1   17)Humphrey (Sat2)  19)MX1  21)08-BM  |
| 2)502   7)LSCAT 21ID-F  12)9-1   18)Lauren (Sat3)    20)MX2  22)08-ID  |
| 3)503   8)LSCAT 21ID-G  13)9-2                                         |
| 4)821   9)GMCA 23ID-B   14)11-1                                        |
| 5)822  10)GMCA 23ID-D   15)12-2                                        |
|                         16)14-1                                        |
+-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=+
|        Written by Jim Fairman       |         Updated 2014-05-06       |
+-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=+
Please input a number: '
read beamline

if [ $beamline = 1 ]
then
	beamname=als-501_XDS.INP	
elif [ $beamline = 2 ]
then	
	beamname=als-502_XDS.INP
elif [ $beamline = 3 ]
then
	beamname=als-503_XDS.INP
elif [ $beamline = 4 ]
then
	beamname=als-821_XDS.INP
elif [ $beamline = 5 ]
then
	beamname=als_822_XDS.INP
elif [ $beamline = 6 ]
then
	beamname=aps-21idd_XDS.INP
elif [ $beamline = 7 ]
then
	beamname=aps-21idf_XDS.INP
elif [ $beamline = 8 ]
then
	beamname=aps-21idg_XDS.INP
elif [ $beamline = 9 ]
then
	beamname=aps-23idb_XDS.INP
elif [ $beamline = 10 ]
then
	beamname=aps-23idd_XDS.INP
elif [ $beamline = 11 ]
then
	beamname=ssrl-7-1_XDS.INP
elif [ $beamline = 12 ]
then
	beamname=ssrl-9-1_XDS.INP
elif [ $beamline = 13 ]
then
	beamname=ssrl-9-2_XDS.INP
elif [ $beamline = 14 ]
then
	beamname=ssrl-11-1_XDS.INP
elif [ $beamline = 15 ]
then
	beamname=ssrl-12-2_XDS.INP
elif [ $beamline = 16 ]
then
	beamname=ssrl-14-1_XDS.INP
elif [ $beamline = 17 ]
then
	beamname=Saturn2_XDS.INP
elif [ $beamline = 18 ]
then
	beamname=Saturn3_XDS.INP
elif [ $beamline = 19 ]
then
        beamname=aus-mx1-XDS.INP
elif [ $beamline = 20 ]
then
        beamname=aus-mx2-XDS.INP
elif [ $beamline = 21 ]
then
        beamname=clsi_08bm_mar300_XDS.INP
elif [ $beamline = 22 ]
then
        beamname=clsi_08id_ray300_XDS.INP
else
	echo "That is not acceptable input, please enter a number between 1 and 22."
	echo " "
	echo "[Please press Enter to continue]"
	read wait
	clear
	menu
fi
}

####################
# MENU FUNCTION END#
####################


##############################
# XDS.INP MODIFICATION START #
##############################

function xdsinpmodify() {

echo " "
echo " "
echo " "
echo "Now lets set up your XDS.INP file with all the information abour your dataset."
echo " "
echo "Please provide me with the directory where your images are stored."
read datadir
echo " "
echo "Thank you, now provide me with the template for your image names (ie: puck8-10_1_0???.img or puck8-10_1.???)."
read dataname
echo " "
echo "Thank you, I'm now inspecting your images for information."

echo $dataname > .blah.txt
sed -e "s/???/001/g" .blah.txt > .blah1.txt
read firstframe < .blah1.txt
sed -e "s/???/*/g" .blah.txt > .blah2.txt
read imagenumsearch < .blah2.txt
imagenum=`ls -1 $datadir/$imagenumsearch | wc -l`
diffdump $datadir/$firstframe > .dump.txt
exptime=`cat .dump.txt | grep Exposure`
wavelength=`cat .dump.txt | grep Wavelength`
distance=`cat .dump.txt | grep Distance`
oscangle=`cat .dump.txt | grep Oscillation`
twotheta=`cat .dump.txt | grep Theta`

exptime=`echo $exptime | awk -v N=4 '{print $N}'`
wavelength=`echo $wavelength | awk -v N=3 '{print $N}'`
distance=`echo $distance | awk -v N=5 '{print $N}'`
twotheta=`echo $twotheta | awk -v N=4 '{print $N}'`

osc1=`echo $oscangle | awk -v N=4 '{print $N}'`
osc2=`echo $oscangle | awk -v N=6 '{print $N}'`
oscillation=`perl -e 'print '$osc2' - '$osc1''`

sed -e "s/OSCILLATION_RANGE/OSCILLATION_RANGE=$oscillation !/g" XDS.INP > .XDS2.INP
sed -e "s/X-RAY_WAVELENGTH/X-RAY_WAVELENGTH=$wavelength !/g" .XDS2.INP > .XDS3.INP
sed -e "s/DATA_RANGE/DATA_RANGE=1 $imagenum !/g" .XDS3.INP > .XDS4.INP
fulltemplate=$datadir/$dataname

### SET IMAGE TEMPLATE NAME ###

if [ $beamline = 1 ]
then
	sed -e "s:NAME_TEMPLATE:NAME_TEMPLATE_OF_DATA_FRAMES=$fulltemplate SMV DIRECT ! :g" .XDS4.INP > .XDS5.INP
elif [ $beamline = 2 ]
then
        sed -e "s:NAME_TEMPLATE:NAME_TEMPLATE_OF_DATA_FRAMES=$fulltemplate SMV DIRECT ! :g" .XDS4.INP > .XDS5.INP
elif [ $beamline = 3 ]
then
        sed -e "s:NAME_TEMPLATE:NAME_TEMPLATE_OF_DATA_FRAMES=$fulltemplate SMV DIRECT ! :g" .XDS4.INP > .XDS5.INP
elif [ $beamline = 4 ]
then
        sed -e "s:NAME_TEMPLATE:NAME_TEMPLATE_OF_DATA_FRAMES=$fulltemplate SMV DIRECT ! :g" .XDS4.INP > .XDS5.INP
elif [ $beamline = 5 ]
then
        sed -e "s:NAME_TEMPLATE:NAME_TEMPLATE_OF_DATA_FRAMES=$fulltemplate SMV DIRECT ! :g" .XDS4.INP > .XDS5.INP
elif [ $beamline = 6 ]
then
        sed -e "s:NAME_TEMPLATE:NAME_TEMPLATE_OF_DATA_FRAMES=$fulltemplate ! TIFF :g" .XDS4.INP > .XDS5.INP
elif [ $beamline = 7 ]
then
        sed -e "s:NAME_TEMPLATE:NAME_TEMPLATE_OF_DATA_FRAMES=$fulltemplate ! TIFF :g" .XDS4.INP > .XDS5.INP
elif [ $beamline = 8 ]
then
        sed -e "s:NAME_TEMPLATE:NAME_TEMPLATE_OF_DATA_FRAMES=$fulltemplate ! TIFF :g" .XDS4.INP > .XDS5.INP
elif [ $beamline = 9 ]
then
        sed -e "s:NAME_TEMPLATE:NAME_TEMPLATE_OF_DATA_FRAMES=$fulltemplate ! TIFF :g" .XDS4.INP > .XDS5.INP
elif [ $beamline = 10 ]
then
        sed -e "s:NAME_TEMPLATE:NAME_TEMPLATE_OF_DATA_FRAMES=$fulltemplate ! TIFF :g" .XDS4.INP > .XDS5.INP
elif [ $beamline = 11 ]
then
        sed -e "s:NAME_TEMPLATE:NAME_TEMPLATE_OF_DATA_FRAMES=$fulltemplate SMV DIRECT ! :g" .XDS4.INP > .XDS5.INP
elif [ $beamline = 12 ]
then
        sed -e "s:NAME_TEMPLATE:NAME_TEMPLATE_OF_DATA_FRAMES=$fulltemplate SMV DIRECT ! :g" .XDS4.INP > .XDS5.INP
elif [ $beamline = 13 ]
then
        sed -e "s:NAME_TEMPLATE:NAME_TEMPLATE_OF_DATA_FRAMES=$fulltemplate DIRECT TIFF ! :g" .XDS4.INP > .XDS5.INP
elif [ $beamline = 14 ]
then
        sed -e "s:NAME_TEMPLATE:NAME_TEMPLATE_OF_DATA_FRAMES=$fulltemplate SMV DIRECT !:g" .XDS4.INP > .XDS5.INP
elif [ $beamline = 15 ]
then
        sed -e "s:NAME_TEMPLATE:NAME_TEMPLATE_OF_DATA_FRAMES=$fulltemplate ! :g" .XDS4.INP > .XDS5.INP
elif [ $beamline = 16 ]
then
        sed -e "s:NAME_TEMPLATE:NAME_TEMPLATE_OF_DATA_FRAMES=$fulltemplate ! :g" .XDS4.INP > .XDS5.INP
elif [ $beamline = 17 ]
then
        sed -e "s:NAME_TEMPLATE:NAME_TEMPLATE_OF_DATA_FRAMES=$fulltemplate SMV DIRECT ! :g" .XDS4.INP > .XDS5.INP
elif [ $beamline = 18 ]
then
        sed -e "s:NAME_TEMPLATE:NAME_TEMPLATE_OF_DATA_FRAMES=$fulltemplate SMV DIRECT ! :g" .XDS4.INP > .XDS5.INP
elif [ $beamline = 19 ]
then
        sed -e "s:NAME_TEMPLATE:NAME_TEMPLATE_OF_DATA_FRAMES=$fulltemplate SMV DIRECT ! :g" .XDS4.INP > .XDS5.INP
elif [ $beamline = 20 ]
then
        sed -e "s:NAME_TEMPLATE:NAME_TEMPLATE_OF_DATA_FRAMES=$fulltemplate SMV DIRECT ! :g" .XDS4.INP > .XDS5.INP
elif [ $beamline = 21 ]
then
        sed -e "s:NAME_TEMPLATE:NAME_TEMPLATE_OF_DATA_FRAMES=$fulltemplate ! TIFF :g" .XDS4.INP > .XDS5.INP
elif [ $beamline = 22 ]
then
        sed -e "s:NAME_TEMPLATE:NAME_TEMPLATE_OF_DATA_FRAMES=$fulltemplate ! TIFF :g" .XDS4.INP > .XDS5.INP
fi

### SET DETECTOR DISTANCE ###

if [ $beamline -lt 17 ]
then
        sed -e "s/DETECTOR_DISTANCE=/DETECTOR_DISTANCE=$distance !/g" .XDS5.INP > .XDS6.INP
elif [ $beamline -gt 18 ]
then
        sed -e "s/DETECTOR_DISTANCE=/DETECTOR_DISTANCE=$distance !/g" .XDS5.INP > .XDS6.INP
else
	sed -e "s/DETECTOR_DISTANCE=/DETECTOR_DISTANCE=-$distance !/g" .XDS5.INP > .XDS6.INP
fi

mv XDS.INP .XDS.BAK
cp .XDS6.INP XDS.INP
rm .XDS2.INP
rm .XDS3.INP
rm .XDS4.INP
rm .XDS5.INP
rm .XDS6.INP

echo " "
echo " "
echo "Here is the information I got from your files:"
echo "Number of Images in Dataset: $imagenum"
echo "Exposure Time: $exptime"
echo "Wavelength: $wavelength"
echo "Distance to Detector: $distance"
echo "Oscillation Angle: $oscillation"
echo "Two Theta Angle: $twotheta"
echo " "
echo "Values have been written to your XDS.INP file.  If any of these values are incorrect you can modify them in the XDS.INP file later."
echo " "
echo "[Please press Enter to continue]"
read wait

## REMOVING JUNK TEXT FILES ##

rm .blah.txt
rm .blah1.txt
rm .blah2.txt
rm .dump.txt

}

############################
# XDS.INP MODIFICATION END #
############################


######################
# MAIN FUNCTION START#
######################

menu
cp $scriptdir/$beamname $targetdir
cp $scriptdir/XSCALE.INP $targetdir
cp $scriptdir/XDSCONV.INP $targetdir
cp $scriptdir/conv.com $targetdir
mv $targetdir/$beamname $targetdir/XDS.INP
echo " "
echo "XDS.INP, XSCALE.INP, XDSCONV.INP, and conv.com have been copied to your current directory."
xdsinpmodify


####################
# MAIN FUNCTION END#
####################
