#!/bin/bash
# +--------------------------------------------------------------------+
# EFA 4 build without ks version 20170109
#
# Purpose:
#       This script will 'baseline' an existing CentOS installation
#       to start the build.bash script ONLY use this script if you
#       are unable to use the kickstart methode.
#
# Prerequirements:
#       A minimal installation of CentOS.
#       Working internet connection
#
# +--------------------------------------------------------------------+
# Copyright (C) 2013~2017 https://efa-project.org
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
# +--------------------------------------------------------------------+

clear

#----------------------------------------------------------------#
# Check if we are root
#----------------------------------------------------------------#
if [ `whoami` == root ]
  then
    echo "[EFA] Good you are root"
else
  echo "[EFA] Please become root to run this."
  exit 1
fi
#----------------------------------------------------------------#

#----------------------------------------------------------------#
# Check if we use CentOS 7
#----------------------------------------------------------------#
CENTOS=`cat /etc/centos-release`

if [[ $CENTOS =~ .*'release 7.'.* ]]; then
  echo "Good you are running CentOS 7 x64"
else
  echo "You are not running CentOS 7"
  echo "Unsupported system, stopping now"
  exit 1
fi
#----------------------------------------------------------------#

#----------------------------------------------------------------#
# Show a disclaimer on using this methode....
#----------------------------------------------------------------#
echo " !!! WARNING !!!"
echo ""
echo "Using this methode is not supported! Please use kickstart where possible."
echo "Only use this methode if there is no option to install using kickstart"
echo "or when it is not possible to use an VM image."
echo ""
echo "This setup will possible put your system in an unsupported state."
echo ""
echo "Again use kickstart or a VM image where possible"
echo ""
echo -n "Are you sure you want to continue? (y/N):"
read YN
flag=1
while [ $flag != "0" ]
    do
      if [[ "$YN" == "Y" || "$YN" == "y" ]]; then
        flag=0
      elif [[ "$YN" == "" || "$YN" == "N" || "$YN" == "n" ]]; then
		echo "Aborting this setup"
        exit 1
      else
          echo -n "Are you sure you want to continue? (y/N):"
          read YN
      fi
  done
#----------------------------------------------------------------#

#----------------------------------------------------------------#
# Upgrade system
#----------------------------------------------------------------#
yum -y update
#----------------------------------------------------------------#

#----------------------------------------------------------------#
# Configure firewall
#----------------------------------------------------------------#
firewall-cmd --permanent --add-service=smtp
firewall-cmd --permanent --add-service=ssh
firewall-cmd --permanent --add-port 80/tcp
firewall-cmd --permanent --add-port 443/tcp
firewall-cmd --reload
#----------------------------------------------------------------#

#----------------------------------------------------------------#
# Set root password to EfaPr0j3ct
#----------------------------------------------------------------#
echo "root:EfaPr0j3ct" | chpasswd --md5 root
#----------------------------------------------------------------#

#----------------------------------------------------------------#
# add packages
#----------------------------------------------------------------#
yum -y install \
@base \
@core
#----------------------------------------------------------------#

#----------------------------------------------------------------#
# Remove packages
#----------------------------------------------------------------#
yum -y remove \
alsa-tools-firmware
#----------------------------------------------------------------#

#----------------------------------------------------------------#
# E.F.A. items
#----------------------------------------------------------------#
mkdir /var/log/EFA
mkdir /usr/src/EFA
#/usr/bin/wget -q -O /usr/src/EFA/build.bash -o /var/log/EFA/wget.log https://raw.githubusercontent.com/E-F-A/v4/build/build.bash
chmod 700 /usr/src/EFA/build.bash
#----------------------------------------------------------------#

#----------------------------------------------------------------#
# Show final messages
#----------------------------------------------------------------#
echo ""
echo "All done, you are now ready to start the build script"
echo "We can now launch the build script."
echo "If you do not want to launch the build script now then"
echo "you will need to start this your self with the command:"
echo ""
echo "logsave /var/log/EFA/build.log /usr/src/EFA/build.bash"
echo ""
echo -n "Do you want to start the build script? (y/N):"
read YN
flag=1
while [ $flag != "0" ]
    do
      if [[ "$YN" == "Y" || "$YN" == "y" ]]; then
        logsave /var/log/EFA/build.log /usr/src/EFA/build.bash
        flag=0
      elif [[ "$YN" == "" || "$YN" == "N" || "$YN" == "n" ]]; then
        echo ""
        echo "Please don't forget to run the build script"
        exit 1
      else
          echo -n "Do you want to start the build script? (y/N):"
          read YN
      fi
  done
#----------------------------------------------------------------#
#EOF
