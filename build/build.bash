#!/bin/bash
action=$1
#-----------------------------------------------------------------------------#
# eFa 4.0.0 build script version 20170122
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
# Install eFa
#-----------------------------------------------------------------------------#
mirror="https://mirrors.efa-project.org"

# check if user is root
if [ `whoami` == root ]; then
  echo "Good you are root."
else
  echo "ERROR: Please become root first."
  exit 1
fi

# check if we run CentOS 7
OSVERSION=`cat /etc/centos-release`
if [[ $OSVERSION =~ .*'release 7.'.* ]]; then
  echo "- Good you are running CentOS 7"
else
  echo "- ERROR: You are not running CentOS 7"
  echo "- ERROR: Unsupported system, stopping now"
  exit 1
fi

# Check network connectivity
echo "- Checking network connectivity"
wget -q --tries=3 --timeout=20 --spider $mirror
if [[ $? -eq 0 ]]; then
  echo "-- OK $mirror is reachable"
else
  echo "ERROR: No network connectivity"
  echo "ERROR: unable to reach $mirror"
  echo "ERROR: Aborting script"
  exit 1
fi

# Add eFa Repo
if [[ "$action" == "testing" ]]; then
  echo "- Adding eFa Testing Repo"
  rpm --import $mirror/rpm/eFa4/RPM-GPG-KEY-eFa-Project
  /usr/bin/wget -O /etc/yum.repos.d/eFa4-testing.repo $mirror/rpm/eFa4/eFa4-testing.repo
else
  echo "- Adding eFa Repo"
  rpm --import $mirror/rpm/eFa4/RPM-GPG-KEY-eFa-Project
  cd /etc/yum.repos.d/
  /usr/bin/wget $mirror/rpm/eFa4/eFa4.repo
fi  

echo "- Adding mariadb Repo"
cat > /etc/yum.repos.d/mariadb.repo << 'EOF'
# MariaDB 10.1 CentOS repository list - created 2017-03-19 11:09 UTC
# http://downloads.mariadb.org/mariadb/repositories/
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.1/centos7-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1
enabled=1
EOF

echo "- Adding epel Repo"
yum -y install epel-release

echo "- Adding Remi Repo"
yum -y install http://rpms.remirepo.net/enterprise/remi-release-7.rpm
yum-config-manager --enable remi-php72

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

echo "- Updating the OS"
yum -y update

# install eFa
yum -y install eFa
