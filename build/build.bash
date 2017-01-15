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
  NetworkManager-wifi \
  wpa_supplicant \
  postfix
}
#-----------------------------------------------------------------------------#

#-----------------------------------------------------------------------------#
# Install RPM packages
#-----------------------------------------------------------------------------#
function install_rpm_packages () {
  # Force yum to always pull certain packages from eFa Repo instead
  # Prevents future yum updates from breaking custom packages
  echo "Excluding custom packages from CentOS Base"
  sed -i '/^\[base\]$/ a\exclude=postfix, spamassassin' /etc/yum.repos.d/CentOS-Base.repo

  echo "Installing RPM packages"
    echo "- Installing <> packages"
    # TODO writing all out for now packages from eFa 3, defining all packages
    # needed and include for what we need them and which repo we get them from
    yum -y install \
      @base \                                # REPO: base, # For: basic system tools
      @core \                                # REPO: base, # For: basic system tools
      bzip2-devel \                          # REPO: base, # For: MailScanner
      screen \                               # REPO: base, # For: basic system tools
      clamav \                               # REPO: epel, # For: MailScanner
        # Auto added dependencies:
        # Epel: clamav-data, clamav-filesystem, clamav-lib
      clamav-update \                        # REPO: epel, # For: MailScanner
      clamav-server \                        # REPO: epel, # For: MailScanner
        # Auto added dependencies:
        # Base: nmap-ncat
      mariadb-server                         # REPO: base, # For: postfix, mailwatch
        # Auto added dependencies:
        # Base:  mariadb, perl-Compress-Raw-Bzip2, perl-Compress-Raw-Zlib,
        #        perl-DBD-MySQL, perl-DBI, perl-Data-Dumper, perl-IO-Compress,
        #        perl-Net-Daemon, perl-PlRPC
      #php \                                 # REPO: <>, # For: <>
      #php-gd \                              # REPO: <>, # For: <>
      #php-mbstring \                        # REPO: <>, # For: <>
      #php-mysql \                           # REPO: <>, # For: <>
      httpd \                                # REPO: base, # For: MailWatch
       # Auto added dependencies:
       # Base: apr, apr-util, httpd-tools
      #rrdtool \                             # REPO: <>, # For: <>
      #rrdtool-perl \                        # REPO: <>, # For: <>
      #cyrus-sasl-md5 \                      # REPO: <>, # For: <>
      ##cyrus-sasl-sql \                     # REPO: <>, # For: <>
      ##cyrus-sasl-ldap \                    # REPO: <>, # For: <>
      #ImageMagick \                         # REPO: <>, # For: <>
      #python-setuptools \                   # REPO: <>, # For: <>
      #libevent \                            # REPO: <>, # For: <>
      libtool-ltdl \                         # REPO: base, # For: MailScanner
      #mod_ssl \                             # REPO: <>, # For: <>
      #system-config-keyboard \              # REPO: <>, # For: <>
      openssl-devel \                        # REPO: base, # For: MailScanner
        # Auto added dependencies:
        # Base: keyutils-libs-devel, libcom_err-devel, libselinux-devel,
        #       libsepol-devel, libverto-devel, pcre-devel, zlib-devel
        # Updates: krb5-devel, libkadm5
      patch \                                # REPO: base, # For: MailScanner
      pyzor \                                # REPO: epel, # For: MailScanner
      re2c \                                 # REPO: epel, # For: MailScanner
      tnef \                                 # REPO: epel, # For: MailScanner
      #tree \                                # REPO: <>, # For: <>
      #rpm-build \                           # REPO: <>, # For: <>
      #glibc-devel \                         # REPO: <>, # For: <>
      gcc \                                  # REPO: base, # For: MailScanner
        # Auto added dependencies:
        # Base: cpp, libmpc, mpfr
      #opencv \                              # REPO: <>, # For: <>

      perl-Archive-Tar \                     # REPO: base, # For: MailScanner
        # Auto added dependencies:
        # Base: perl-Compress-Raw-Bzip2, perl-Compress-Raw-Zlib,
        #       perl-Data-Dumper, perl-IO-Compress
        #       (perl-Compress-Zlib perl-IO-Compress-Bzip2),
        #       perl-IO-Zlib, perl-Package-Constants
      perl-Archive-Zip \                     # REPO: base, # For: MailScanner
      #perl-Cache-Memcached \                # REPO: <>, # For: <>
      #perl-CGI \                            # REPO: <>, # For: <>
      #perl-Class-Singleton \                # REPO: <>, # For: <>
      perl-Convert-BinHex \                  # REPO: epel, # For: MailScanner
      perl-Convert-TNEF \                    # REPO: epel, # For: MailScanner
        # Auto added dependencies:
        # Base: perl-IO-Socket-IP perl-IO-Socket-SSL perl-IO-stringy,
        #       perl-MailTools, perl-Net-LibIDN, perl-Net-SMTP-SSL,
        #       perl-Net-SSLeay, perl-TimeDate
        # Epel: perl-MIME-tools
      perl-CPAN \                            # REPO: base, # For: MailScanner
        # Auto added dependencies:
        # Base: perl-local-lib
      perl-Data-Dump \                       # REPO: epel, # For: MailScanner
      #perl-Date-Manip \                     # REPO: <>, # For: <>
      #perl-DateTime \                       # REPO: <>, # For: <>
      #perl-DBD-MySQL \                      # REPO: <>, # For: <>
      perl-DBD-SQLite \                      # REPO: base, # For: MailScanner
        # Auto added dependencies:
        # Base: perl-DBI, perl-Net-Daemon, perl-PlRPC
      #perl-DBD-Pg \                         # REPO: <>, # For: <>
      perl-Digest-SHA1 \                     # REPO: base, # For: MailScanner
      perl-Digest-HMAC \                     # REPO: base, # For: MailScanner
        # Auto added dependencies:
        # Base: perl-Digest, perl-Digest-MD5, perl-Digest-SHA
      perl-Encode-Detect \                   # REPO: base, # For: MailScanner
      #perl-Email-Date-Format \              # REPO: <>, # For: <>
      perl-Env \                             # REPO: base, # For: MailScanner
      perl-ExtUtils-CBuilder \               # REPO: base, # For: MailScanner
        # Auto added dependencies:
        # Base: perl-IPC-Cmd, perl-Locale-Maketext,
        #       perl-Locale-Maketext-Simple,
        #       perl-Module-CoreList, perl-Module-Load,
        #       perl-Module-Load-Conditional, perl-Module-Metadata,
        #       perl-Params-Check, perl-Perl-OSType
      perl-ExtUtils-MakeMaker \              # REPO: base, # For: MailScanner
        # Auto added dependencies:
        # Base: gdbm-devel, libdb-devel, perl-ExtUtils-Install,
        #       perl-ExtUtils-Manifest, perl-ExtUtils-ParseXS,
        #       perl-Test-Harness, perl-devel, pyparsing,
        #       systemtap-sdt-devel
      #perl-File-Copy-Recursive \            # REPO: <>, # For: <>
      perl-File-ShareDir-Install \           # REPO: epel, # For: MailScanner
      perl-Filesys-Df \                      # REPO: epel, # For: MailScanner
      perl-HTML-Parser \                     # REPO: base, # For: MailScanner
        # Auto added dependencies:
        # Base: mailcap, perl-Business-ISBN, perl-Business-ISBN-Data,
        #       perl-Encode-Locale, perl-HTML-Tagset, perl-HTTP-Date,
        #       perl-HTTP-Message, perl-IO-HTML, perl-LWP-MediaTypes,
        #       perl-URI
      perl-Inline \                          # REPO: base, # For: MailScanner
        # Auto added dependencies:
        # Base: perl-Parse-RecDescent
      perl-IO-String \                       # REPO: base, # For: MailScanner
      #perl-List-MoreUtils \                 # REPO: <>, # For: <>
      perl-LDAP \                            # REPO: base, # For: MailScanner
        # Auto added dependencies:
        # Base: perl-Authen-SASL, perl-Convert-ASN1, perl-File-Listing
        #       perl-GSSAPI, perl-HTTP-Cookies, perl-HTTP-Daemon,
        #       perl-HTTP-Negotiate, perl-JSON, perl-Net-HTTP,
        #       perl-Text-Soundex, perl-Text-Unidecode,
        #       perl-WWW-RobotRules perl-XML-Filter-BufferText,
        #       perl-XML-NamespaceSupport, perl-XML-SAX-Base,
        #       perl-XML-SAX-Writer, perl-libwww-perl
      perl-Mail-DKIM \                       # REPO: base, # For: MailScanner
        # Auto added dependencies:
        # Base: perl-Crypt-OpenSSL-Bignum, perl-Crypt-OpenSSL-RSA,
        #       perl-Crypt-OpenSSL-Random, perl-Net-DNS
      perl-Mail-IMAPClient \                 # REPO: epel, # For: MailScanner
      perl-Mail-SPF \                        # REPO: base, # For: MailScanner
        # Auto added dependencies:
        # Base: perl-Error, perl-NetAddr-IP, perl-version
      #perl-MIME-Lite \                      # REPO: <>, # For: <>
      #perl-MIME-Types \                     # REPO: <>, # For: <>
      perl-Module-Build \                    # REPO: base, # For: MailScanner
        # Auto added dependencies:
        # Base: perl-CPAN-Meta, perl-CPAN-Meta-Requirements,
        #       perl-CPAN-Meta-YAML
        #       perl-JSON-PP, perl-Parse-CPAN-Meta
      perl-Net-CIDR \                        # REPO: epel, # For: MailScanner
      perl-Net-CIDR-Lite \                   # REPO: epel, # For: MailScanner
      perl-Net-DNS-Resolver-Programmable \   # REPO: base, # For: MailScanner
      perl-Net-IP \                          # REPO: epel, # For: MailScanner
      perl-OLE-Storage_Lite \                # REPO: epel, # For: MailScanner
      #perl-Params-Validate \                # REPO: <>, # For: <>
      perl-Razor-Agent \                     # REPO: epel, # For: MailScanner
        # Auto added dependencies:
        # Base: perl-Sys-Syslog
      #perl-String-CRC32 \                   # REPO: <>, # For: <>
      perl-Sys-Hostname-Long \               # REPO: epel, # For: MailScanner
      perl-Sys-SigAction \                   # REPO: epel, # For: MailScanner
      #perl-Taint-Runtime \                  # REPO: <>, # For: <>
      perl-Test-Manifest \                   # REPO: base, # For: MailScanner
      perl-Test-Pod \                        # REPO: base, # For: MailScanner
        # Auto added dependencies:
        # Base: perl-Test-Simple
      #perl-XML-DOM \                        # REPO: <>, # For: <>
      #perl-XML-LibXML \                     # REPO: <>, # For: <>
      #perl-XML-NamespaceSupport \           # REPO: <>, # For: <>
      #perl-XML-Parser \                     # REPO: <>, # For: <>
      #perl-XML-RegExp \                     # REPO: <>, # For: <>
      #perl-XML-SAX \                        # REPO: <>, # For: <>
      perl-YAML                              # REPO: base, # For: MailScanner
      #perl-YAML-Syck \                      # REPO: <>, # For: <>

## Removed
#mysql-server   # replaced by mariadb-server
#mysql          # Replaced by mariadb
#ntp            # Replaced by chrony

    echo "- Installing eFa packages"
    # TODO writing all out for now packages from eFa 3, defining all packages
    # needed and include for what we need them and which repo we get them from
    yum -y install \
     unrar \                                 # REPO: eFa, # For: MailScanner
     postfix \                               # REPO: eFa, # For: MTA
       # Auto added dependencies:
       # Base: libicu, mariadb-libs, perl-Bit-Vector, perl-Carp-Clan
       #       perl-Date-Calc postgresql-libs
       # Epel: tinycdb
       # Replaces: postfix in CentOS Base
     sqlgrey \                               # REPO: eFa, # For: Greylisting
     spamassassin \                          # REPO: eFa, # For: MailScanner
       # Auto added dependencies:
       # Base: perl-DB_File, perl-IO-Socket-INET6, perl-Socket6,
       #       portreserve, procmail, perl-Geo-IP, perl-Net-Patricia
       # Replaces: spamassassin in CentOS Base
     MailScanner \                           # REPO: eFa, # For: MailScanner
     clamav-unofficial-sigs \                # REPO: eFa, # For: clamav
     perl-IP-Country \                       # REPO: eFa, # For: MailScanner, Spamassassin
     perl-Mail-SPF-Query \                   # REPO: eFa, # For: MailScanner
     #perl-Net-Ident \                       # REPO: <>, # For: <>
     #perl-ExtUtils-Constant \               # REPO: <>, # For: <>
     perl-Geophgraphy-Countries \            # REPO: eFa, # For: Spamassassin
     perl-libnet                             # REPO: eFa, # For: Spamassassin
     #perl-Net-DNS-Nameserver \              # REPO: <>, # For: <>
     #perl-IO-Multiplex \                    # REPO: <>, # For: <>
     #perl-File-Tail \                       # REPO: <>, # For: <>
     #perl-Net-Netmask \                     # REPO: <>, # For: <>
     #perl-BerkeleyDB \                      # REPO: <>, # For: <>
     #perl-Net-Server \                      # REPO: <>, # For: <>
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
