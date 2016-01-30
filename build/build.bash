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
# Update system before we start
#-----------------------------------------------------------------------------#
function upgradeOS () {
    yum -y upgrade
}
#-----------------------------------------------------------------------------#

#-----------------------------------------------------------------------------#
# add EFA Repo
#-----------------------------------------------------------------------------#
function efarepo () {
   cd /etc/yum.repos.d/
   /usr/bin/wget --no-check-certificate $mirror/rpm/EFA.repo
}
#-----------------------------------------------------------------------------#

#-----------------------------------------------------------------------------#
# Main function
#-----------------------------------------------------------------------------#
function main() {
  # If $action is empty we run the normal setup
  if [[ -z "$action" ]]; then
    prebuild
    upgradeOS
    efarepo
      elif [[ "$action" == "--frontend" ]]; then
    # If $action is --frontend, we do a frontend only install.
    prebuild
    upgradeOS
    efarepo
  fi
}
#-----------------------------------------------------------------------------#

#-----------------------------------------------------------------------------#
# Run the main script
#-----------------------------------------------------------------------------#
main
#-----------------------------------------------------------------------------#
#EOF
