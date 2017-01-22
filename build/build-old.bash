#!/bin/bash
action=$1
#-----------------------------------------------------------------------------#
# eFa 4.0.0 build script version 20170120
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

# Todo:
# - Build for CentOS 7
# - Consider using makeself for updates (http://stephanepeter.com/makeself/)
# - Consider using mysql for transports instead of text file
# -

#-----------------------------------------------------------------------------#
# Variables
#-----------------------------------------------------------------------------#
version="4"
logdir="/var/log/eFa"
password="EfaPr0j3ct"
mirror="https://dl.efa-project.org"
mirrorpath="/build/$version"
#-----------------------------------------------------------------------------#

#-----------------------------------------------------------------------------#
# Main function
#-----------------------------------------------------------------------------#
function main() {
  prepare_os
  configure_firewall
  install_rpm_packages
}
#-----------------------------------------------------------------------------#

#-----------------------------------------------------------------------------#
# Prepare OS for eFa
#-----------------------------------------------------------------------------#
function prepare_os() {
  echo "Starting Prepare OS"
  #---------------------------------------------------------------------------#
  local OSVERSION=`cat /etc/centos-release`
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

  # mounting /tmp without nosuid and noexec while building
  # as it breaks building some components if /tmp is a dedicated partition.
  local tmppar="`mount | grep -i /tmp`"
  if [[ -n "$tmppar" ]]
  then
    echo "- Mounting /tmp RW"
    mount -o remount rw /tmp
  fi

  # Remove unwanted packages
  echo "- Removing unwanted packages"
  remove_rpm_packages

  # Update the OS before we start
  echo "- Updating the OS"
  yum -y update

  # Create base dirs
  echo "- Creating Base Dirs"
  mkdir /var/log/eFa
  mkdir /usr/src/eFa

  # Change the root password
  echo "- Changing the root password"
  echo "root:EfaPr0j3ct" | chpasswd --md5 root

  # Add eFa Repo
  echo "- Adding eFa Repo"
  rpm --import $mirror/rpm/eFa4/RPM-GPG-KEY-eFa-Project
  cd /etc/yum.repos.d/
  /usr/bin/wget $mirror/rpm/eFa4/eFa4.repo

  # Add epel Repo
  echo "- Adding epel Repo"
  yum -y install epel-release
  yum -y update
}
#-----------------------------------------------------------------------------#

#-----------------------------------------------------------------------------#
# Configure firewall
#-----------------------------------------------------------------------------#
function configure_firewall () {
  echo "Adding Firewall rules"
  firewall-cmd --permanent --add-service=smtp
  firewall-cmd --permanent --add-service=ssh
  firewall-cmd --permanent --add-port 80/tcp
  firewall-cmd --permanent --add-port 443/tcp
  firewall-cmd --permanent --add-port 587/tcp
  firewall-cmd --reload
}
#-----------------------------------------------------------------------------#

#-----------------------------------------------------------------------------#
# Remove not needed RPM packages
#-----------------------------------------------------------------------------#
function remove_rpm_packages () {
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
}
#-----------------------------------------------------------------------------#

#-----------------------------------------------------------------------------#
# Install RPM packages
#-----------------------------------------------------------------------------#
function install_rpm_packages () {
  # Force yum to always pull certain packages from eFa Repo instead
  # Prevents future yum updates from breaking custom packages
  # postfix and spamassassin are customized builds in eFa
  echo "Excluding custom packages from CentOS Base"
  sed -i '/^\[base\]$/ a\exclude=postfix, spamassassin' /etc/yum.repos.d/CentOS-Base.repo

  # echo "Installing RPM packages"
    # echo "- Installing <> packages"
    # PKG=''
    # # TODO writing all out for now packages from eFa 3, defining all packages
    # # needed and include for what we need them and which repo we get them from
    # #-------------------------------------------------------------------------#
    # # PACKAGES WITH DEPENDENCIES               # REPO    # PURPOSE            #
    # #-------------------------------------------------------------------------#
    # # rrdtool                                  # TODO    #
    # # rrdtool-perl                             # TODO    #
    # # ImageMagick                              # TODO    #
    # # python-setuptools                        # TODO    #
    # # libevent                                 # TODO    #
    # # system-config-keyboard                   # TODO    #
    # # tree                                     # TODO    #
    # # rpm-build                                # TODO    #
    # # glibc-devel                              # TODO    #
    # # opencv                                   # TODO    #
    # # perl-Cache-Memcached                     # TODO    #
    # # perl-CGI                                 # TODO    #
    # # perl-Class-Singleton                     # TODO    #
    # # perl-Date-Manip                          # TODO    #
    # # perl-DateTime                            # TODO    #
    # # perl-DBD-MySQL                           # TODO    #
    # # perl-DBD-Pg                              # TODO    #
    # # perl-Email-Date-Format                   # TODO    #
    # # perl-File-Copy-Recursive                 # TODO    #
    # # perl-List-MoreUtils                      # TODO    #
    # # perl-MIME-Lite                           # TODO    #
    # # perl-MIME-Types                          # TODO    #
    # # perl-Params-Validate                     # TODO    #
    # # perl-String-CRC32                        # TODO    #
    # # perl-Taint-Runtime                       # TODO    #
    # # perl-XML-DOM                             # TODO    #
    # # perl-XML-LibXML                          # TODO    #
    # # perl-XML-NamespaceSupport                # TODO    #
    # # perl-XML-Parser                          # TODO    #
    # # perl-XML-RegExp                          # TODO    #
    # # perl-XML-SAX                             # TODO    #
    # # perl-YAML-Syck                           # TODO    #

# ## Removed
# #mysql-server   # replaced by mariadb-server
# #mysql          # Replaced by mariadb
# #ntp            # Replaced by chrony

    # echo "- Installing eFa packages"
    # PKG=''
    # # TODO writing all out for now packages from eFa 3, defining all packages
    # # needed and include for what we need them and which repo we get them from
    # #-------------------------------------------------------------------------#
    # # PACKAGES WITH DEPENDENCIES         # REPO    # PURPOSE                  #
    # #-------------------------------------------------------------------------#
    # # perl-Net-Ident                     # TODO    #
    # # perl-ExtUtils-Constant             # TODO    #
    # # perl-Net-DNS-Nameserver            # TODO    #
    # # perl-IO-Multiplex                  # TODO    #
    # # perl-File-Tail                     # TODO    #
    # # perl-Net-Netmask                   # TODO    #
    # # perl-BerkeleyDB                    # TODO    #
    # # perl-Net-Server                    # TODO    #

    yum -y install eFa
}
#-----------------------------------------------------------------------------#

#-----------------------------------------------------------------------------#
# Run the main script if we are root
#-----------------------------------------------------------------------------#
if [ `whoami` == root ]; then
  main
else
  echo "ERROR: Please become root first."
  exit 1
fi
#-----------------------------------------------------------------------------#
#EOF
