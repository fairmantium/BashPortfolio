#!/bin/bash

############################
##                        ##
## GAMESS in PHENIX.elbow ##
##                        ##
## Created by Jim Fairman ##
## Last Modified:08-03-15 ##
##                        ##
############################

###########################
# SET DIRECTORY VARIABLES #
###########################

workingdir=~/scr

###########################
# END DIRECTORY VARIABLES #
###########################

######################
# PRELIMINARY CHECKS #
######################

function checks() {

	#Checking to see if you are running the script on Hydra.
	
	ipaddy=`ifconfig eth0 | awk '/inet addr/{print substr($2,6)}'`
	if [ $ipaddy != "192.168.230.217" ]; then
		echo "You must run this script from Hydra."
		echo " "
		echo "Please SSH over to Hydra by issuing 'hydra' at the terminal."
		echo "[Press Enter to continue]"
		read wait
		exit
	fi

	#Checking to see if there is a /home/usr/scr directory, if not then create one
	if [ ! -d "$workingdir" ]; then
		echo "There was no 'scr' directory in your home directory, creating one."
		mkdir $workingdir
		chmod 777 $workingdir
		echo " "
		echo "[Press Enter to continue]"
		read wait
		echo " "
		echo " "
	fi

}

####################
# GAMESS RUN START #
####################

function gamessrun() {

	#Getting files and/or SMILES string for running GAMESS
	clear
	echo "
+-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+
| 								  |
| 1) I have a .smi file that already contains a SMILES string.    |
| 								  |
| 2) I have a SMILES string that I want to input into GAMESS.     |
|								  |
| 3) Exit							  |
|								  |
+-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+
| Completed .PDB and .CIF files will appear in /home/username/scr |
+-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+
Please input a number: "
	read smilesinput
	
	if [ $smilesinput = 1 ]
	then
		echo " "
		echo " "
		echo "Please provide me with the directory where the .smi file is located."
		echo ""
		echo "Directory: "
		read gamessdir
		echo " "
		echo "Please provide me with the .smi file name."
		echo " "
		echo "Filename: "
		read gamessfile
		echo " "
		echo "Please input the 3-letter code you would like assigned to your molecule in the PDB."
		echo " "
		echo "3-letter code: "
		read pdbidcode
		echo " "
                echo " "
                echo "Running phenix.elbow with GAMESS optimization."
		echo " "
                echo "This may take several hours."
                echo " "
                echo "[Please press Enter to continue]"
                read wait
		cd ~/scr
		cp $gamessdir/$gamessfile ~/scr
		tcsh -c "nice phenix.elbow $gamessfile --gamess --basis="3-21G" --id=$pdbidcode"
	elif [ $smilesinput = 2 ]
	then
		echo " "
		echo " "
		echo "Please provide me with the SMILES string you are interested in."
		echo " "
		echo "SMILES: "
		read smilesstring
		echo " "
		echo " "
		echo "Please input the 3-letter code you would like assigned to your molecule in the PDB."
                echo " "
                echo "3-letter code: "
                read pdbidcode
		echo " "
		echo " "
		echo "Running phenix.elbow with GAMESS optimization."
		echo " "
		echo "This may take several hours."
		echo " "
		echo "[Please press Enter to continue]"
		read wait
		cd ~/scr
		rm ligand.smi
		echo $smilesstring >> ligand.smi
		tcsh -c "nice phenix.elbow ligand.smi --gamess --basis="3-21G" --id=$pdbidcode"
	elif [ $smilesinput = 3 ]
	then
		echo " "
		echo " "
		echo "Returning to the command line."
		echo " "
		echo "[Please press Enter to continue]"
		read wait
		exit
	else
		echo " "
		echo "Please input a number between 1 and 3."
		echo " "
		echo "[Please press Enter to continue]"
		read wait
		clear
		gamessrun
	fi
}

##################
# GAMESS RUN END #
##################

#######################
# MAIN FUNCTION START #
#######################

checks
gamessrun

#####################
# MAIN FUNCTION END #
#####################

