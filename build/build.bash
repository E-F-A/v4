#!/bin/bash
action=$1
#-----------------------------------------------------------------------------#
# eFa 4.0.0.0 build script version 20160410
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
  firewall-cmd --reload
}
#-----------------------------------------------------------------------------#

#-----------------------------------------------------------------------------#
# Install RPM packages
#-----------------------------------------------------------------------------#
function install_rpm_packages () {
  echo "Installing RPM packages"
    echo "- Installing <> packages"
    # TODO writing all out for now packages from eFa 3, defining all packages
    # needed and include for what we need them and which repo we get them from
    yum -y install \
      @base \                               # REPO: CentOS, # For: basic system tools
      @core \                               # REPO: CentOS, # For: basic system tools
      screen \                              # REPO: CentOS, # For: basic system tools
      ntp \                                 # REPO: CentOS, # For: Time sync
        # Auto added dependencies for NTP from CentOS repo are:
        # autogen-libopts
      mariadb-server                        # REPO: CentOS, # For: postfix, mailwatch
        # Auto added dependencies for mariadb-server from CentOS repo are:
        # mariadb, perl-Compress-Raw-Bzip2, perl-Compress-Raw-Zlib, perl-DBD-MySQL
        # perl-DBI, perl-Data-Dumper, perl-IO-Compress, perl-Net-Daemon, perl-PlRPC

      #gpg \                                 # REPO: <>, # For: <>
      #php \                                 # REPO: <>, # For: <>
      #php-gd \                              # REPO: <>, # For: <>
      #php-mbstring \                        # REPO: <>, # For: <>
      #php-mysql \                           # REPO: <>, # For: <>
      #httpd \                               # REPO: <>, # For: <>
      #rrdtool \                             # REPO: <>, # For: <>
      #rrdtool-perl \                        # REPO: <>, # For: <>
      #cyrus-sasl-md5 \                      # REPO: <>, # For: <>
      ##cyrus-sasl-sql \                     # REPO: <>, # For: <>
      ##cyrus-sasl-ldap \                    # REPO: <>, # For: <>
      #ImageMagick \                         # REPO: <>, # For: <>
      #python-setuptools \                   # REPO: <>, # For: <>
      #libevent \                            # REPO: <>, # For: <>
      #mod_ssl \                             # REPO: <>, # For: <>
      #system-config-keyboard \              # REPO: <>, # For: <>
      #openssl-devel                         # REPO: <>, # For: <>
      #patch \                               # REPO: <>, # For: <>
      #tree \                                # REPO: <>, # For: <>
      #rpm-build \                           # REPO: <>, # For: <>
      #binutils \                            # REPO: <>, # For: <>
      #glibc-devel \                         # REPO: <>, # For: <>
      #gcc \                                 # REPO: <>, # For: <>
      #make \                                # REPO: <>, # For: <>
      #opencv \                              # REPO: <>, # For: <>

      #perl-Archive-Tar \                    # REPO: <>, # For: <>
      #perl-Archive-Zip \                    # REPO: <>, # For: <>
      #perl-Business-ISBN \                  # REPO: <>, # For: <>
      #perl-Business-ISBN-Data \             # REPO: <>, # For: <>
      #perl-Cache-Memcached \                # REPO: <>, # For: <>
      #perl-CGI \                            # REPO: <>, # For: <>
      #perl-Class-Singleton \                # REPO: <>, # For: <>
      #perl-Compress-Zlib \                  # REPO: <>, # For: <>
      #perl-Compress-Raw-Zlib  \             # REPO: <>, # For: <>
      #perl-Convert-BinHex \                 # REPO: <>, # For: <>
      #perl-Crypt-OpenSSL-Random \           # REPO: <>, # For: <>
      #perl-Crypt-OpenSSL-RSA \              # REPO: <>, # For: <>
      #perl-Date-Manip \                     # REPO: <>, # For: <>
      #perl-DateTime \                       # REPO: <>, # For: <>
      #perl-DBI \                            # REPO: <>, # For: <>
      #perl-DBD-MySQL \                      # REPO: <>, # For: <>
      #perl-DBD-SQLite \                     # REPO: <>, # For: <>
      #perl-DBD-Pg \                         # REPO: <>, # For: <>
      #perl-Digest-SHA1 \                    # REPO: <>, # For: <>
      #perl-Encode-Detect \                  # REPO: <>, # For: <>
      #perl-Email-Date-Format \              # REPO: <>, # For: <>
      #perl-Error \                          # REPO: <>, # For: <>
      #perl-ExtUtils-CBuilder \              # REPO: <>, # For: <>
      #perl-ExtUtils-MakeMaker \             # REPO: <>, # For: <>
      #perl-ExtUtils-ParseXS \               # REPO: <>, # For: <>
      #perl-File-Copy-Recursive \            # REPO: <>, # For: <>
      #perl-HTML-Parser \                    # REPO: <>, # For: <>
      #perl-HTML-Tagset \                    # REPO: <>, # For: <>
      #perl-IO-String \                      # REPO: <>, # For: <>
      #perl-IO-stringy \                     # REPO: <>, # For: <>
      #perl-IO-Socket-INET6 \                # REPO: <>, # For: <>
      #perl-IO-Socket-SSL \                  # REPO: <>, # For: <>
      #perl-IO-Zlib \                        # REPO: <>, # For: <>
      #perl-libwww-perl \                    # REPO: <>, # For: <>
      #perl-List-MoreUtils \                 # REPO: <>, # For: <>
      #perl-Mail-DKIM \                      # REPO: <>, # For: <>
      #perl-MailTools \                      # REPO: <>, # For: <>
      #perl-MIME-tools \                     # REPO: <>, # For: <>
      #perl-MIME-Lite \                      # REPO: <>, # For: <>
      #perl-MIME-Types \                     # REPO: <>, # For: <>
      #perl-Module-Build \                   # REPO: <>, # For: <>
      #perl-Net-DNS \                        # REPO: <>, # For: <>
      #perl-Net-IP \                         # REPO: <>, # For: <>
      #perl-Net-SSLeay \                     # REPO: <>, # For: <>
      #perl-Module-Build \                   # REPO: <>, # For: <>
      #perl-Params-Validate \                # REPO: <>, # For: <>
      #perl-Pod-Escapes \                    # REPO: <>, # For: <>
      #perl-Pod-Simple \                     # REPO: <>, # For: <>
      #perl-Parse-RecDescent \               # REPO: <>, # For: <>
      #perl-String-CRC32 \                   # REPO: <>, # For: <>
      #perl-Taint-Runtime \                  # REPO: <>, # For: <>
      #perl-Test-Harness \                   # REPO: <>, # For: <>
      #perl-Test-Manifest \                  # REPO: <>, # For: <>
      #perl-Test-Pod \                       # REPO: <>, # For: <>
      #perl-Test-Simple \                    # REPO: <>, # For: <>
      #perl-TimeDate \                       # REPO: <>, # For: <>
      #perl-Time-HiRes \                     # REPO: <>, # For: <>
      #perl-URI \                            # REPO: <>, # For: <>
      #perl-version \                        # REPO: <>, # For: <>
      #perl-XML-DOM \                        # REPO: <>, # For: <>
      #perl-XML-LibXML \                     # REPO: <>, # For: <>
      #perl-XML-NamespaceSupport \           # REPO: <>, # For: <>
      #perl-XML-Parser \                     # REPO: <>, # For: <>
      #perl-XML-RegExp \                     # REPO: <>, # For: <>
      #perl-XML-SAX \                        # REPO: <>, # For: <>
      #perl-YAML \                           # REPO: <>, # For: <>
      #perl-YAML-Syck \                      # REPO: <>, # For: <>



## Removed
#mysql-server   # replaced by mariadb-server
#mysql          # Replaced by mariadb


    echo "- Installing eFa packages"
    # TODO writing all out for now packages from eFa 3, defining all packages
    # needed and include for what we need them and which repo we get them from
    yum -y install \
     #unrar \                                # REPO: <>, # For: <>
     #postfix \                              # REPO: <>, # For: <>
     #re2c \                                 # REPO: <>, # For: <>
     #spamassassin \                         # REPO: <>, # For: <>
     #MailScanner \                          # REPO: <>, # For: <>
     #clamav-unofficial-sigs \               # REPO: <>, # For: <>
     #tnef \                                 # REPO: <>, # For: <>
     #bzip2-devel \                          # REPO: <>, # For: <>
     #perl-IP-Country \                      # REPO: <>, # For: <>
     #perl-Mail-SPF-Query \                  # REPO: <>, # For: <>
     #perl-Net-Ident \                       # REPO: <>, # For: <>
     #perl-Mail-ClamAV \                     # REPO: <>, # For: <>
     #perl-NetAddr-IP \                      # REPO: <>, # For: <>
     #perl-Digest-SHA \                      # REPO: <>, # For: <>
     #perl-Mail-SPF \                        # REPO: <>, # For: <>
     #perl-Digest-HMAC \                     # REPO: <>, # For: <>
     #perl-Net-DNS \                         # REPO: <>, # For: <>
     #perl-Net-DNS-Resolver-Programmable \   # REPO: <>, # For: <>
     #perl-Digest \                          # REPO: <>, # For: <>
     #perl-Digest-MD5 \                      # REPO: <>, # For: <>
     #perl-DB_File \                         # REPO: <>, # For: <>
     #perl-ExtUtils-Constant \               # REPO: <>, # For: <>
     #perl-Geo-IP \                          # REPO: <>, # For: <>
     #perl-IO-Socket-INET6 \                 # REPO: <>, # For: <>
     #perl-Socket \                          # REPO: <>, # For: <>
     #perl-IO-Socket-IP \                    # REPO: <>, # For: <>
     #perl-libnet \                          # REPO: <>, # For: <>
     #perl-File-ShareDir-Install \           # REPO: <>, # For: <>
     #perl-LDAP \                            # REPO: <>, # For: <>
     #perl-IO-Compress-Bzip2 \               # REPO: <>, # For: <>
     #perl-Net-DNS-Nameserver \              # REPO: <>, # For: <>
     #perl-Mail-IMAPClient \                 # REPO: <>, # For: <>
     #perl-OLE-Storage_Lite \                # REPO: <>, # For: <>
     #perl-Inline \                          # REPO: <>, # For: <>
     #perl-Text-Balanced \                   # REPO: <>, # For: <>
     #perl-Net-CIDR-Lite \                   # REPO: <>, # For: <>
     #perl-Sys-Hostname-Long \               # REPO: <>, # For: <>
     #perl-Net-Patricia \                    # REPO: <>, # For: <>
     #perl-IO-Multiplex \                    # REPO: <>, # For: <>
     #perl-File-Tail \                       # REPO: <>, # For: <>
     #perl-Data-Dump \                       # REPO: <>, # For: <>
     #perl-Sys-SigAction \                   # REPO: <>, # For: <>
     #perl-Net-Netmask \                     # REPO: <>, # For: <>
     #perl-Filesys-Df \                      # REPO: <>, # For: <>
     #perl-Net-CIDR \                        # REPO: <>, # For: <>
     #perl-BerkeleyDB \                      # REPO: <>, # For: <>
     #perl-Net-Server \                      # REPO: <>, # For: <>
     #perl-Convert-TNEF \                    # REPO: <>, # For: <>
     #perl-IP-Country                        # REPO: <>, # For: <>
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
