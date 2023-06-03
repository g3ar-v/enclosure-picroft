#!/bin/bash

##########################################################################
# update.sh
##########################################################################
# This script is executed by the auto_run.sh when a new version is found
# at https://github.com/MycroftAI/enclosure-picroft/tree/buster
REPO_PATH=https://raw.githubusercontent.com/g3ar-v/enclosure-picroft/buster/
# REPO_PATH="https://raw.githubusercontent.com/MycroftAI/enclosure-picroft/buster"

if [ ! -f /etc/core/core.conf ] ;
then
    # Assume this is a fresh install, setup the system
    echo "Would you like to install Picroft on this machine?"
    echo -n "Choice [Y/N]: "
    read -N1 -s key
    case $key in
      [Yy])
        ;;

      *)
        echo "Aborting install."
        exit
        ;;
    esac

    # Create basic folder structures
    sudo mkdir -p /etc/core/
    mkdir -p ~/bin

    # Get the Picroft conf file
    cd /etc/core || exit
    sudo wget -N $REPO_PATH/etc/core/core.conf

    # Enable Autologin as the 'pi' user
    echo "[Service]" | sudo tee /etc/systemd/system/getty@tty1.service.d/autologin.conf
    echo "ExecStart=" | sudo tee -a /etc/systemd/system/getty@tty1.service.d/autologin.conf
    echo "ExecStart=-/sbin/agetty --autologin pi --noclear %I 38400 linux" | sudo tee -a /etc/systemd/system/getty@tty1.service.d/autologin.conf
    sudo systemctl enable getty@tty1.service

    # Create RAM disk (the Picroft version of mycroft.conf point at it)
    if ! grep -Fq "tmpfs /ramdisk" /etc/fstab ; then
        echo "tmpfs /ramdisk tmpfs rw,nodev,nosuid,size=20M 0 0" | sudo tee -a /etc/fstab
    fi

    # Download and setup Mycroft-core
    echo "Installing 'git'..."
    sudo apt-get update
    sudo apt-get install git -y

    echo "Downloading 'core'..."
    cd ~ || exit
    git clone https://github.com/g3ar-v/__core__.git
    cd __core__ || exit
    # git checkout master

    echo
    echo "Beginning building __core__.  This'll take a bit,"
    echo "take a break.  Results will be in the ~/build.log"
    bash dev_setup.sh -y 2>&1 | tee ../build.log
    echo "Build complete.  Press any key to review the output before it is deleted."
    read -N1 -s key
    nano ../build.log
    rm ../build.log

    echo
    echo "Retrieving default skills"
    sudo mkdir -p /opt/core
    sudo chown pi:pi /opt/core
    mkdir -p ~/.core
    ~/__core__/bin/mycroft-msm default

    wget -N $REPO_PATH/home/pi/audio_setup.sh
    wget -N $REPO_PATH/home/pi/custom_setup.sh
fi

# update software
echo "Updating Picroft scripts"
cd ~ || exit
wget -N $REPO_PATH/home/pi/.bashrc
wget -N $REPO_PATH/home/pi/auto_run.sh
wget -N $REPO_PATH/home/pi/version
wget -N $REPO_PATH/home/pi/update.sh  # updated within auto_run.sh, but download in case run directly

cd ~/bin || exit 
wget -N $REPO_PATH/home/pi/bin/mycroft-wipe
chmod +x mycroft-wipe

