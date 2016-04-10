#!/bin/bash
action=$1
#-----------------------------------------------------------------------------#
# EFA 4.0.0.0 build script version 20160410
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

# Todo:
# - Build for Ubuntu LTS
# - Consider using makeself for updates (http://stephanepeter.com/makeself/)
# - Consider using mysql for transports instead of text file
# -

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
# Pre-build
#-----------------------------------------------------------------------------#
function prebuild () {
    # mounting /tmp without nosuid and noexec while building
    # as it breaks building some components.
    mount -o remount rw /tmp
}
#-----------------------------------------------------------------------------#

#-----------------------------------------------------------------------------#
# add EFA Repo (Debian packages)
#-----------------------------------------------------------------------------#
function efarepo () {
  # TODO
   echo "todo"
}
#-----------------------------------------------------------------------------#

#-----------------------------------------------------------------------------#
# Update system before we start
#-----------------------------------------------------------------------------#
function upgrade_os () {
   apt-get update
   apt-get -y upgrade
}
#-----------------------------------------------------------------------------#

#-----------------------------------------------------------------------------#
# Check Network
#-----------------------------------------------------------------------------#
function check_network () {
  # TODO
    echo "Check if network is functioning correctly before we start"
}
#-----------------------------------------------------------------------------#

#-----------------------------------------------------------------------------#
# Full install setup, front & backend
#-----------------------------------------------------------------------------#
function full_install() {
    echo "Full install"
    check_network
    prebuild
}
#-----------------------------------------------------------------------------#

#-----------------------------------------------------------------------------#
# Frontend setup, just mail handling
#-----------------------------------------------------------------------------#
function frontend_install() {
    echo "frontend install"
    check_network
    prebuild
}
#-----------------------------------------------------------------------------#

#-----------------------------------------------------------------------------#
# Backend setup, just mail handling
#-----------------------------------------------------------------------------#
function backend_install() {
    echo "Backend install"
    check_network
    prebuild
}
#-----------------------------------------------------------------------------#

#-----------------------------------------------------------------------------#
# Prepare OS if the system has not been installed from kickstart
#-----------------------------------------------------------------------------#
function prepare_os() {
    echo "Starting Prepare OS"
    #-------------------------------------------------------------------------#
    OSVERSION=`lsb_release -c -s`
    if ! [[ "$OSVERSION" == "xenial" ]]; then
      echo "ERROR: You are not running Ubuntu 16.04 (Xenial)"
      echo "ERROR: Unsupported system, stopping now"
      exit 1
    fi
    # Check network connectivity
    check_network

    # Upgrade the OS before we start
    upgrade_os

    # Create base dirs
    mkdir /var/log/EFA
    mkdir /usr/src/EFA
    # Change the root password
    echo "root:EfaPr0j3ct" | chpasswd --md5 root
    #-------------------------------------------------------------------------#
    echo "Prepare is finished, you can now run the script again and select"
    echo "one of the installation options to build the system."
    exit 1
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
