#!/bin/bash
action=$1
#-----------------------------------------------------------------------------#
# EFA 4.0.0.0 build script version 20160130
#-----------------------------------------------------------------------------#
# Copyright (C) 2013~2016 https://efa-project.org
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
# Variables
#-----------------------------------------------------------------------------#
version="4"
logdir="/var/log/EFA"
password="EfaPr0j3ct"
mirror="https://dl.efa-project.org"
mirrorpath="/build/$version"
#-----------------------------------------------------------------------------#

#-----------------------------------------------------------------------------#
# Pre-build
#-----------------------------------------------------------------------------#
function prebuild () {
    # mounting /tmp without nosuid and noexec while building
    # as it breaks building some components.
    mount -o remount rw /tmp
}
#-----------------------------------------------------------------------------#

#-----------------------------------------------------------------------------#
# add EFA Repo
#-----------------------------------------------------------------------------#
function efarepo () {
   cd /etc/yum.repos.d/
   /usr/bin/wget $mirror/rpm/EFA4.repo
   rpm --import http://dl.efa-project.org/rpm/RPM-GPG-KEY-E.F.A.Project
}
#-----------------------------------------------------------------------------#

#-----------------------------------------------------------------------------#
# Update system before we start
#-----------------------------------------------------------------------------#
function upgrade_os () {
    yum -y upgrade
}
#-----------------------------------------------------------------------------#

#-----------------------------------------------------------------------------#
# Full install setup, front & backend
#-----------------------------------------------------------------------------#
function full_install() {
    echo "Full install"
}
#-----------------------------------------------------------------------------#

#-----------------------------------------------------------------------------#
# Frontend setup, just mail handling
#-----------------------------------------------------------------------------#
function frontend_install() {
    echo "frontend install"
}
#-----------------------------------------------------------------------------#

#-----------------------------------------------------------------------------#
# Backend setup, just mail handling
#-----------------------------------------------------------------------------#
function backend_install() {
    echo "Backend install"
}
#-----------------------------------------------------------------------------#

#-----------------------------------------------------------------------------#
# Prepare OS if the system has not been installed from kickstart
#-----------------------------------------------------------------------------#
function prepare_os() {
    echo "Starting Prepare OS"
    #-------------------------------------------------------------------------#
    OSVERSION=`cat /etc/centos-release | sed 's/\..*//'`
    if ! [[ "$OSVERSION" == "CentOS Linux release 7" ]]; then
      echo "ERROR: You are not running CentOS 7.x"
      echo "ERROR: Unsupported system, stopping now"
      exit 1
    fi
    # Upgrade the OS before we start
    upgrade_os
    # Install base & core packages
    yum -y install @base @core
    # Create base dirs
    mkdir /var/log/EFA
    mkdir /usr/src/EFA
    # Change the root password
    echo "root:EfaPr0j3ct" | chpasswd --md5 root
    # Configure firewall
    firewall-cmd --add-service=http
    firewall-cmd --add-service=ssh
    firewall-cmd --add-service=smtp
    firewall-cmd --add-port=443/tcp
    #-------------------------------------------------------------------------#
    echo "Prepare is finished, you can now run the script again and select"
    echo "one of the installation options to build the system."
    exit 1
}
#-----------------------------------------------------------------------------#

#-----------------------------------------------------------------------------#
# Main function
#-----------------------------------------------------------------------------#
function main() {
 case "$action" in
   --frontend)
        frontend_install
        ;;
   --backend)
        backend_install
        ;;
   --full)
        full_install
        ;;
   --prepare)
        prepare_os
        ;;
   *)
        echo "Usage: $0 <option>"
        echo "where <option> is one of:"
        echo "  --prepare     Prepare the OS for installation"
        echo "  --full        Install an full system"
        echo "  --frontend    Install frontend only"
        echo "  --backend     Install backend only"
        exit 3
        ;;
 esac
}
#-----------------------------------------------------------------------------#

#-----------------------------------------------------------------------------#
# Run the main script if we are root
#-----------------------------------------------------------------------------#
if [ `whoami` == root ]; then
  main
else
  echo "Please become root first."
  exit 1
fi
#-----------------------------------------------------------------------------#
#EOF
