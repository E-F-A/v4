#!/bin/bash
######################################################################
# eFa 4.0.2 Development prebuild environment
######################################################################
# Copyright (C) 2020  https://efa-project.org
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
#######################################################################

# Git path
GITPATH="/root/v4"

# check if user is root
if [ `whoami` == root ]; then
  echo "Good you are root."
else
  echo "ERROR: Please become root first."
  exit 1
fi

# check if we run CentOS 7 or 8
OSVERSION=`cat /etc/centos-release`
if [[ $OSVERSION =~ .*'release 7.'.* ]]; then
  RELEASE=7
  echo "- Good you are running CentOS 7"
elif [[ $OSVERSION =~ .*'release 8.'.* ]]; then
  echo "- Good you are running CentOS 8"
  RELEASE=8
else
  echo "- ERROR: You are not running CentOS 7 or 8"
  echo "- ERROR: Unsupported system, stopping now"
  exit 1
fi

if [[ -f /etc/selinux/config && -n $(grep -i ^SELINUX=disabled$ /etc/selinux/config)  ]]; then
  echo "- ERROR: SELinux is disabled and this is not an lxc container"
  echo "- ERROR: Please enable SELinux and try again."
  exit 1
fi

if [[ ! -d /root/v4 ]]; then
  echo "- ERROR: git path is incorrect"
  echo "- ERROR: Please clone to /root/v4 or update GITPATH and try again."
  exit 1
fi

yum -y install epel-release
[ $? -ne 0 ] && exit 1

if [[ $RELEASE -eq 7 ]]; then
  echo "- Adding IUS Repo"
  yum -y install https://repo.ius.io/ius-release-el7.rpm
  [ $? -ne 0 ] && exit 1
  rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-IUS-7
  [ $? -ne 0 ] && exit 1
else
  yum config-manager --set-enabled powertools
  [ $? -ne 0 ] && exit 1
fi

yum -y update
[ $? -ne 0 ] && exit 1

if [[ $RELEASE -eq 7 ]]; then
  yum -y remove mariadb-libs
  [ $? -ne 0 ] && exit 1
fi

yum -y install rpm-build
[ $? -ne 0 ] && exit 1

mkdir -p $GITPATH/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
[ $? -ne 0 ] && exit 1
echo "%_topdir $GITPATH/rpmbuild" > ~/.rpmmacros
[ $? -ne 0 ] && exit 1
cd $GITPATH/rpmbuild/SPECS
[ $? -ne 0 ] && exit 1
if [[ $RELEASE -eq 7 ]]; then
  yum -y remove postfix postfix32u
  [ $? -ne 0 ] && exit 1
fi
if [[ $RELEASE -eq 8 ]]; then
  yum -y remove postfix
  [ $? -ne 0 ] && exit 1
fi
