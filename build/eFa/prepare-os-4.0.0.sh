#!/bin/sh
#-----------------------------------------------------------------------------#
# eFa 4.0.0 initial mariadb-configuration script
#-----------------------------------------------------------------------------#
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
#-----------------------------------------------------------------------------#

#-----------------------------------------------------------------------------#
# Source the settings file
#-----------------------------------------------------------------------------#
source /usr/src/eFa/eFa-settings.inc
#-----------------------------------------------------------------------------#

local tmppar="`mount | grep -i /tmp`"
if [[ -n "$tmppar" ]]
then
  echo "- Mounting /tmp RW" >> $logfile
  mount -o remount rw /tmp
fi


# Remove unwanted packages
echo "- Removing unwanted packages" >> $logfile
# TODO We  can't do this as we are in yum.. :)
yum -y remove \
iwl100-firmware \
iwl2030-firmware \
iwl5000-firmware \
iwl6000-firmware \
iwl3160-firmware \
iwl105-firmware \
iwl135-firmware \
iwl1000-firmware \
iwl7260-firmware \
alsa-firmware \
iwl6000g2b-firmware \
wl6050-firmware \
iwl6000g2a-firmware \
iwl5150-firmware \
iwl7265-firmware \
iwl3945-firmware \
ivtv-firmware \
iwl2000-firmware \
iwl4965-firmware \
alsa-tools-firmware \
alsa-lib \
postfix

# Change the root password
echo "- Changing the root password" >> $logfile
echo "root:EfaPr0j3ct" | chpasswd --md5 root

echo "Adding Firewall rules" >> $logfile
firewall-cmd --permanent --add-service=smtp
firewall-cmd --permanent --add-service=ssh
firewall-cmd --permanent --add-port 80/tcp
firewall-cmd --permanent --add-port 443/tcp
firewall-cmd --permanent --add-port 587/tcp
firewall-cmd --reload
