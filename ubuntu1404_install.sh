#!/bin/bash

###########################
# Created by: Jim Fairman #
# Last Edited: 01-14-2016 #
###########################

###########################
# FUNCTION TO DEFINE SITE #
###########################

### CHECK FOR ROOT

clear
echo "
Welcome to the Beryllium Linux install script 3.0 for installing all of the necessary dependencies/packages for integrating a fresh Ubuntu 14.04 install for use on the Beryllium Linux network.

Please report all bugs to Jim Fairman (jfairman@be4.com).

[PRESS ENTER TO CONTINUE]
"
read wait
clear
echo "
First I will check to see if you are running this script as the root user.  Root is required for this script to function properly.

[PRESS ENTER TO CONTINUE]
"
read wait
clear
currentuser=`whoami`
if [ $currentuser != "root" ]
then
        echo "

You are currently running this script as user $currentuser, please become root and re-run this script.  If root is not enabled it may be enabled by issuing the command 'sudo passwd' when logged in as a user with sudo rights.

Returning to the command line. 

[PRESS EMTER TO CONTINUE]
        "
        read wait
        exit
else

        echo "
You are running this script as root, we will now continue.

[PRESS ENTER TO CONTINUE]
        "
        read wait
        clear
fi

#### START SITE SELECTION PORTION OF SCRIPT

clear
echo "
Which Beryllium site is this machine being installed to, Seattle or Boston?

Input Answer: "
read sitename

if [ $sitename = "Seattle" ]
then
        gatewayaddy="192.168.230.252"
        dnsaddy="192.168.230.1"
        homeserver="192.168.230.217"

elif [ $sitename = "Boston" ]
then
        gatewayaddy="192.168.130.254"
        dnsaddy="192.168.130.2"
        homeserver="192.168.130.200"

else
        echo "
Please input either Seattle or Boston as input.

[PRESS ENTER TO CONTINUE]"
        read wait
        clear
        setsite
fi

### IP ADDRESS PORTION OF SCRIPT
clear
echo "
We will now assign the static IP address of this machine.  What would you like the IP to be?

Seattle Site: 192.168.230.xxx
Boston Site: 192.168.130.xxx

Please input an IP address: "
read ipaddy

echo "

You have entered $ipaddy as the assigned static IP address, is this correct?

y/n?: "
read answer

if [ $answer = "n" ]
then
        setip

elif [ $answer = "y" ]
then
        echo "

Adding lines to /etc/network/interfaces."
        echo " " >> /etc/network/interfaces
        echo "# Added by Linux install script" >> /etc/network/interfaces
        echo "auto eth0" >> /etc/network/interfaces
        echo "iface eth0 inet static" >> /etc/network/interfaces
        echo "address $ipaddy" >> /etc/network/interfaces
        echo "netmask 255.255.255.0" >> /etc/network/interfaces
        echo "gateway $gatewayaddy" >> /etc/network/interfaces
        echo "dns-nameservers $dnsaddy" >> /etc/network/interfaces
        echo "dns-search embios.com" >> /etc/network/interfaces
else
        echo "
That is not acceptable input, please answer y or n.

[PRESS ENTER TO CONTINUE]"
        read wait
        clear
        setip
fi

### SETTING HOSTNAME
clear
echo "
We will now assign the hostname for this Linux box.  What would you like the hostname to be?

Examples:  S-DB3-L-JFAIRMAN, B-L-AMORALES, etc

Please input a name: "
read boxname
echo "

You have entered $boxname as the machine name, is this correct?

y/n?: "
read answer2

if [ $answer2 = "n" ]
then
        setname

elif [ $answer2 = "y" ]
then
        echo "

Changing /etc/hostname to fit your new hostname - $boxname"
        rm /etc/hostname
        hostname $boxname
        echo "$boxname" >> /etc/hostname

else
        echo "
That is not acceptable input, please answer y or n.

[PRESS ENTER TO CONTINUE]"
        read wait
        clear
        setname
fi

### INSTALLING PACKAGES TO SUPPORT ANSIBLE

# Install OpenSSH Server, nfs-common, and VIM for Ansible Install
apt-get update
apt-get install -y openssh-server vim python-apt nfs-common dkms

#Adding repos
add-apt-repository -y ppa:x2go/stable
apt-get update
add-apt-repository -y ppa:webupd8team/java
apt-get update

apt-get install -y nfs-common csh tcsh chromium-browser pepperflashplugin-nonfree flashplugin-installer ubuntu-restricted-extras htop gimp inkscape krita vlc kde-full curl libgnomecanvas2-dev a2ps g++ gnuplot libglu1-mesa-dev mesa-common-dev raster3d python-software-properties openbabel openbabel-gui lib32stdc++6 libfreetype6-dev python-pmw libglew-dev freeglut3-dev libpng-dev x2goserver x2goclient oracle-java8-installer libXmu6:i386

# Getting SSH key for root for Ansible
scp root@192.168.230.214:/root/.ssh/id_rsa.pub /root/.ssh/
cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys

# Changing LightDM to allow entering of username and password
echo "greeter-session=unity-greeter" >> /usr/share/lightdm/lightdm.conf.d/50-unity-greeter.conf
echo "greeter-show-manual-login=true" >> /usr/share/lightdm/lightdm.conf.d/50-unity-greeter.conf
echo "allow-guest=false" >> /usr/share/lightdm/lightdm.conf.d/50-unity-greeter.conf
echo "greeter-hide-users=true" >> /usr/share/lightdm/lightdm.conf.d/50-unity-greeter.conf
echo "user-session=kde-plasma" >> /usr/share/lightdm/lightdm.conf.d/50-unity-greeter.conf

# Setting Hosts and Hosts.allow
echo " " >> /etc/hosts
echo "192.168.230.217 hydra.embios.com hydra" >> /etc/hosts
echo "192.168.130.200 squidward.embios.com squidward" >> /etc/hosts
echo "$ipaddy $boxname.embios.com $boxname" >> /etc/hosts

echo " " >> /etc/hosts.allow
echo "ALL:192.168.230.217" >> /etc/hosts.allow
echo "ALL:192.168.130.200" >> /etc/hosts.allow

# Getting PowerBroker for AD Authentication
cd /root
wget 'http://download.beyondtrust.com/PBISO/8.0.1/linux.deb.x64/pbis-open-8.0.1.2029.linux.x86_64.deb.sh'
chmod +x pbis-open-8.0.1.2029.linux.x86_64.deb.sh
bash 'pbis-open-8.0.1.2029.linux.x86_64.deb.sh'

# Lines from AD2.sh made by Dan @ Cavu used to join hydra to domain
if [ -z "$1" ]; then
  echo "Starting up visudo with this script as first parameter"
  export EDITOR=$0 && sudo -E visudo
else
  echo "Changing sudoers - adding embios\linuxadmins"
  echo '%embios\\\linuxadmins ALL=(ALL:ALL) ALL' >> $1
  echo '%linuxadmins ALL=(ALL:ALL) ALL' >> $1
fi

echo "
[PRESS ENTER TO CONTINUE WITH REBOOT]
"
read wait
reboot
