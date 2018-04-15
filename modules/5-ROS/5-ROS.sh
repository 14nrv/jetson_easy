#!/bin/bash
# Copyright (C) 2018, Raffaello Bonghi <raffaello@rnext.it>
# All rights reserved
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
# 1. Redistributions of source code must retain the above copyright 
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
# 3. Neither the name of the copyright holder nor the names of its 
#    contributors may be used to endorse or promote products derived 
#    from this software without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND 
# CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, 
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS 
# FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; 
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE 
# OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, 
# EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# Install ROS
# Reference
# Thanks @jetsonhacks
# https://github.com/jetsonhacks/installROSTX2/blob/master/installROS.sh

##################################################

script_list()
{
    if [ ! -z ${ROS_DISTRO+x} ] ; then
        echo "(*) ROS:"
        echo "    - Distro: $ROS_DISTRO"
        echo "    - ROS_MASTER_URI: $ROS_MASTER_URI"
        if [ ! -z ${ROS_HOSTNAME+x} ] ; then
            echo "    - ROS_HOSTNAME: $ROS_HOSTNAME"
        fi
    else
        echo "(*) ROS Not installed!"
    fi
}

################# RUN ############################

script_run()
{
    # Load ROS installer source
    source ros_installer.sh
    
    # ROS Distro installer
    if [ ! -z ${ROS_NEW_DISTRO+x} ] ; then
        # Check if is already installed another ROS VERSION
        if [ -z ${ROS_DISTRO+x} ] ; then
            tput setaf 6
            echo "Install ROS $ROS_NEW_DISTRO"
            tput sgr0
            # Launch ROS installer
            install_ros
        else            
            if [ $ROS_NEW_DISTRO == $ROS_DISTRO ] ; then
                tput setaf 3
                echo "ROS $ROS_DISTRO is already installed"
                tput sgr0
            else
                tput setaf 1
                echo "ROS $ROS_NEW_DISTRO cannot installed. $ROS_DISTRO is already installed"
                tput sgr0
            fi
        fi
    else
        tput setaf 1
        echo "Any ROS_DISTRO is selected"
        tput sgr0
    fi
    
    # ROS workspace installer
    if [ ! -z ${ROS_SET_WORKSPACE+x} ] && [ $ROS_SET_WORKSPACE == "YES" ] ; then
        # Load default value
        if [ -z ${ROS_NAME_WS+x} ] || [ -z $ROS_NAME_WS ] ; then
            ROS_NAME_WS="catkin_ws"
        fi
        # Check if the folrder exist
        if [ ! -d $HOME/$ROS_NAME_WS ] ; then
            tput setaf 6
            echo "Build new ROS workspace $ROS_NAME_WS"
            tput sgr0
            
            # Launch New workspace installer
            #ros_install_workspace $ROS_NAME_WS $ROS_DISTRO
        else
            tput setaf 1
            echo "Folder $ROS_NAME_WS exist! Stop!"
            tput sgr0
        fi
    fi
    
    ## TODO UPDATE
    # ROS Variables
    if [ ! -z ${ROS_DISTRO+x} ] ; then
        # Check if empty the ROS_MASTER_URI
        if [ -z $ROS_NEW_MASTER_URI ] && [ $ROS_NEW_HOSTNAME=1 ] ; then
            ROS_NEW_MASTER_URI="http://$HOSTNAME.local:11311"
        fi
        # Update the ROS_MASTER_URI
        if [ $ROS_NEW_MASTER_URI != "http://localhost:11311" ] && [ $ROS_NEW_MASTER_URI != $ROS_MASTER_URI ]; then
            tput setaf 6
            echo "Add new ROS_MASTER_URI=\"$ROS_NEW_MASTER_URI\""
            tput sgr0
            grep -q -F "# ROS Configuration" $HOME/.bashrc || echo "# ROS Configuration" >> $HOME/.bashrc
            grep -q -F "export ROS_MASTER_URI=\"$ROS_NEW_MASTER_URI\"" $HOME/.bashrc || echo "export ROS_MASTER_URI=\"$ROS_NEW_MASTER_URI\"" >> $HOME/.bashrc
            
            if [ $ROS_NEW_HOSTNAME == 1 ] ; then
                tput setaf 6
                echo "Add new ROS_HOSTNAME=\"$HOSTNAME\""
                tput sgr0
                grep -q -F "export ROS_HOSTNAME=\"$HOSTNAME\"" $HOME/.bashrc || echo "export ROS_HOSTNAME=\"$HOSTNAME\"" >> $HOME/.bashrc
            fi
            
            tput setaf 6
            echo "Re run $USER bashrc in $HOME"
            tput sgr0
            source $HOME/.bashrc
        fi
    fi
}

##################################################

script_load_default()
{
    # Write distribution
    #if [ -z ${ROS_NEW_DISTRO+x} ] ; then
    #    ROS_NEW_DISTRO="kinetic"
    #fi
    
    # Set default Distribution
    if [ -z ${ROS_DISTRO_TYPE+x} ] ; then
        ROS_DISTRO_TYPE="base"
    fi
    
    # Write default workspace
    if [ -z ${ROS_NAME_WS+x} ] ; then
        ROS_NAME_WS="catkin_ws"
    fi
    
    # Set is install workspace
    if [ -z ${ROS_SET_WORKSPACE+x} ] ; then
        ROS_SET_WORKSPACE="NO"
    fi
    
    # Write new ROS_NEW_HOSTNAME
    ROS_SET_HOSTNAME="NO"
    
    # Write new ROS_NEW_MASTER_URI
    if [ ! -z ${ROS_MASTER_URI+x} ] ; then
        ROS_NEW_MASTER_URI=$ROS_MASTER_URI
    else
        ROS_NEW_MASTER_URI="http://localhost:11311"
    fi
}

script_save()
{
    # ROS Distribution name
    if [ ! -z ${ROS_NEW_DISTRO+x} ] && [ ! -z $ROS_NEW_DISTRO ] ; then
        echo "ROS_NEW_DISTRO=\"$ROS_NEW_DISTRO\"" >> $1
    fi
    
    if [ ! -z ${ROS_DISTRO_TYPE+x} ] && [ $ROS_DISTRO_TYPE != "base" ] ; then
        echo "ROS_DISTRO_TYPE=\"$ROS_DISTRO_TYPE\"" >> $1
    fi
    
    # ROS name workspace
    if [ ! -z ${ROS_NAME_WS+x} ] && [ $ROS_NAME_WS != "catkin_ws" ] ; then
        echo "ROS_NAME_WS=\"$ROS_NAME_WS\"" >> $1
    fi
    
    # ROS set workspace
    if [ ! -z ${ROS_SET_WORKSPACE+x} ] && [ $ROS_SET_WORKSPACE != "NO" ] ; then
        echo "ROS_SET_WORKSPACE=\"$ROS_SET_WORKSPACE\"" >> $1
    fi
    
    # Write new ROS_NEW_HOSTNAME
    if [ ! -z ${ROS_SET_HOSTNAME+x} ] && [ $ROS_SET_HOSTNAME != "NO" ] ; then
        echo "ROS_SET_HOSTNAME=\"$ROS_SET_HOSTNAME\"" >> $1
    fi
    
    # Write new ROS_NEW_MASTER_URI
    if [ ! -z ${ROS_NEW_MASTER_URI+x} ] && 
       [ $ROS_NEW_MASTER_URI != "http://localhost:11311" ] && 
       [ $ROS_NEW_MASTER_URI != $ROS_MASTER_URI ] ; then
        echo "ROS_NEW_MASTER_URI=\"$ROS_NEW_MASTER_URI\"" >> $1
    fi
}

#### COMMON FUNCTIONS ####

ros_load_equal()
{
    if [ ! -z ${2+x} ] && [ $1 == $2 ] ; then
        echo "ON"
    else
        echo "OFF"
    fi
}

ros_load_check()
{
    if [ ! -z ${1+x} ] ; then
        if [ $1 == "YES" ] ; then
            if [ ! -z ${2+x} ] && [ $2 == "YES" ] ; then
                echo "ON"
            else
                echo "OFF"
            fi
        else
            if [ ! -z ${2+x} ] && [ $2 == "NO" ] ; then
                echo "ON"
            else
                echo "OFF"
            fi
        fi
    else
        echo "OFF"
    fi
}

#### SET DISTRIBUTION ####

ros_set_distro()
{
    local ros_new_distro_temp=$(whiptail --title "Set distribution" --radiolist \
    "Set ROS distribution" 15 60 2 \
    "kinetic" "Install the workspace" $(ros_load_equal "kinetic" $ROS_NEW_DISTRO) \
    "lunar" "Skipp installation" $(ros_load_equal "lunar" $ROS_NEW_DISTRO) 3>&1 1>&2 2>&3)
     
    local exitstatus=$?
    if [ $exitstatus = 0 ]; then
        # Write the new distribution
        ROS_NEW_DISTRO=$ros_new_distro_temp
    fi
}

#### SET ROS DISTRO TYPE ####

ros_set_distro_type()
{
    local ros_distro_type_temp=$(whiptail --title "Set distribution" --radiolist \
    "Select the ROS distribution" 15 60 3 \
    "base" "ROS Base is the smallest version of ROS" $(ros_load_equal "base" $ROS_DISTRO_TYPE) \
    "desktop" "ROS with GUI nodes" $(ros_load_equal "desktop" $ROS_DISTRO_TYPE) \
    "full" "ROS with GUI and Gazebo" $(ros_load_equal "full" $ROS_DISTRO_TYPE) 3>&1 1>&2 2>&3)
     
    local exitstatus=$?
    if [ $exitstatus = 0 ]; then
        # Write the new distribution
        ROS_DISTRO_TYPE=$ros_distro_type_temp
    fi
}

#### SET WORKSPACE ####

ros_set_workspace()
{
    local ros_set_workspace_temp=$(whiptail --title "$MODULE_NAME" --radiolist \
    "Do you want install the workspace?" 15 60 2 \
    "YES" "Install the workspace" $(ros_load_check "YES" $ROS_SET_WORKSPACE) \
    "NO" "Skipp installation" $(ros_load_check "NO" $ROS_SET_WORKSPACE) 3>&1 1>&2 2>&3)
    
    local exitstatus=$?
    if [ $exitstatus = 0 ]; then
        ROS_SET_WORKSPACE=$ros_set_workspace_temp
    fi
}

ros_name_workspace()
{
    local ros_name_workspace_temp=$(whiptail --inputbox "Set ROS workspace" 8 78 $ROS_NAME_WS --title "Set ROS workspace" 3>&1 1>&2 2>&3)
    local exitstatus=$?
    if [ $exitstatus = 0 ]; then
        # Write the new workspace
        ROS_NAME_WS=$ros_name_workspace_temp
    fi
}

#### SET ROS_HOSTNAME ####

ros_set_hostname()
{
    local ros_set_hostname_temp=$(whiptail --title "$MODULE_NAME - Set Hostname variable" --radiolist \
    "Do you want use set hostname variable?" 15 60 2 \
    "YES" "Use same hostname" $(ros_load_check "YES" $ROS_SET_HOSTNAME) \
    "NO" "Manual edit" $(ros_load_check "NO" $ROS_SET_HOSTNAME) 3>&1 1>&2 2>&3)
     
    local exitstatus=$?
    if [ $exitstatus = 0 ]; then
        ROS_SET_HOSTNAME=$ros_set_hostname_temp
    fi
}

#### SET ROS_MASTER_URI ####

ros_set_master_uri()
{
    local ros_set_master_uri_temp=$(whiptail --inputbox "Set ROS_MASTER_URI" 8 78 $ROS_NEW_MASTER_URI --title "Set ROS_MASTER_URI" 3>&1 1>&2 2>&3)
    
    local exitstatus=$?
    if [ $exitstatus = 0 ]; then
        # Write new ROS_MASTER_URI
        ROS_NEW_MASTER_URI=$ros_set_master_uri_temp
    fi
}

#### LOAD MODULE VARIABLES ####

ros_load_version()
{
    if [ -z ${1+x} ] ; then
        echo ""
    else
        echo "- $1"
    fi
}

# Default variables load
if [ -z ${ROS_NEW_DISTRO+x} ] ; then
    MODULE_NAME="Install ROS"
else
    MODULE_NAME="Install ROS $(ros_load_version $ROS_NEW_DISTRO)"
fi

MODULE_DESCRIPTION="ROS - This module install the release of ROS, build a workspace, set a new hostname and set a new master uri"
MODULE_DEFAULT=0

ros_is_check()
{
    if [ ! -z ${1+x} ] && [ $1 == "YES" ] ; then
        echo "X"
    else
        echo " "
    fi
}

# SUB MENU Module
MODULE_SUBMENU=("Set ROS distribution:ros_set_distro" "Type ROS distribution:ros_set_distro_type" "[$(ros_is_check $ROS_SET_WORKSPACE)] Install workspace:ros_set_workspace")
# Add name ROS option
if [ ! -z ${ROS_SET_WORKSPACE+x} ] ; then
    if [ $ROS_SET_WORKSPACE == "YES" ] ; then
        MODULE_SUBMENU+=(" - Set name workspace:ros_name_workspace")
    fi
fi 
MODULE_SUBMENU+=("[$(ros_is_check $ROS_SET_HOSTNAME)] Set ROS_HOSTNAME:ros_set_hostname")
# Enable name ROS option
if [ ! -z ${ROS_SET_HOSTNAME+x} ] ; then
    if [ $ROS_SET_HOSTNAME == "NO" ] ; then
        MODULE_SUBMENU+=(" - Set ROS_MASTER_URI:ros_set_master_uri")
    fi
fi 

