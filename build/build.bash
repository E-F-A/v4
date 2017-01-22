#!/bin/bash
action=$1
#-----------------------------------------------------------------------------#
# eFa 4.0.0 build script version 20170120
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
    # # @base                                    # base    # basic system tools
    # # @core                                    # base    # basic system tools
    # PKG='  bzip2-devel'                        # base    # MailScanner
    # PKG+=' screen'                             # base    # basic system tools
    # PKG+=' clamav'                             # epel    # MailScanner
    # #     clamav-data                          #         #
    # #     clamav-filesystem                    #         #
    # #     clamav-lib                           #         #
    # PKG+=' clamav-update'                      # epel    # MailScanner
    # PKG+=' clamav-server'                      # epel    # MailScanner
    # #     nmap-ncat                            # base    #
    # PKG+=' mariadb-server'                     # base    # postfix, mailwatch
    # #     mariadb                              #         #
    # #     perl-Compress-Raw-Bzip2              #         #
    # #     perl-Compress-Raw-Zlib               #         #
    # #     perl-DBD-MySQL                       #         #
    # #     perl-DBI                             #         #
    # #     perl-Data-Dumper                     #         #
    # #     perl-IO-Compress                     #         #
    # #     perl-Net-Daemon                      #         #
    # #     perl-PlRPC                           #         #
    # PKG+=' php'                                # base    # mailwatch
    # #     libzip                               #         #
    # #     php-cli                              #         #
    # #     php-common                           #         #
    # PKG+=' php-gd'                             # base    # mailwatch
    # #     libXpm                               #         #
    # #     t11ib                                #         #
    # PKG+=' php-mbstring'                       # base    # mailwatch
    # PKG+=' php-mysql'                          # base    # mailwatch
    # #     php-pdo                              #         #
    # PKG+=' php-ldap'                           # base    # mailwatch
    # PKG+=' httpd'                              # base    # mailwatch
    # #     apr                                  #         #
    # #     apr-util                             #         #
    # #     httpd-tools                          #         #
    # #     mailcap                              #         #
    # # rrdtool                                  # TODO    #
    # # rrdtool-perl                             # TODO    #
    # PKG+=' cyrus-sasl-md5'                     # base    # postfix
    # PKG+=' cyrus-sasl-sql'                     # base    # postfix
    # #     postgresql-libs                      #         #
    # PKG+=' cyrus-sasl-ldap'                    # base    # postfix
    # # ImageMagick                              # TODO    #
    # # python-setuptools                        # TODO    #
    # # libevent                                 # TODO    #
    # PKG+=' mod_ssl'                            # base    # httpd
    # # system-config-keyboard                   # TODO    #
    # PKG+=' openssl-devel'                      # base    # MailScanner
    # #     keyutils-libs-devel                  #         #
    # #     libcom_err-devel                     #         #
    # #     libselinux-devel                     #         #
    # #     libsepol-devel                       #         #
    # #     libverto-devel                       #         #
    # #     pcre-devel                           #         #
    # #     zlib-devel                           #         #
    # #     krb5-devel                           # updates #
    # #     libkadm5                             #         #
    # PKG+=' patch'                              # base    # MailScanner
    # PKG+=' pyzor'                              # epel    # MailScanner
    # PKG+=' re2c'                               # epel    # MailScanner
    # PKG+=' tnef'                               # epel    # MailScanner
    # # tree                                     # TODO    #
    # # rpm-build                                # TODO    #
    # # glibc-devel                              # TODO    #
    # PKG+=' gcc'                                # base    # MailScanner
    # #     cpp                                  #         #
    # #     libmpc                               #         #
    # #     mpfr                                 #         #
    # # opencv                                   # TODO    #
    # PKG+=' perl-Archive-Tar'                   # base    # MailScanner
    # #     perl-Compress-Raw-Bzip2              #         #
    # #     perl-Compress-Raw-Zlib               #         #
    # #     perl-Data-Dumper                     #         #
    # #     perl-IO-Compress                     #         #
    # #     perl-IO-Zlib                         #         #
    # #     perl-Package-Constants               #         #
    # PKG+=' perl-Archive-Zip'                   # base    # MailScanner
    # # perl-Cache-Memcached                     # TODO    #
    # # perl-CGI                                 # TODO    #
    # # perl-Class-Singleton                     # TODO    #
    # PKG+=' perl-Convert-BinHex'                # epel    # MailScanner
    # PKG+=' perl-Convert-TNEF'                  # epel    # MailScanner
    # #     perl-IO-Socket-IP                    # base    #
    # #     perl-IO-Socket-SSL                   #         #
    # #     perl-IO-stringy                      #         #
    # #     perl-MailTools                       #         #
    # #     perl-Net-LibIDN                      #         #
    # #     perl-Net-SMTP-SSL                    #         #
    # #     perl-Net-SSLeay                      #         #
    # #     perl-TimeDate                        #         #
    # #     perl-MIME-tools                      # epel    #
    # PKG+=' perl-CPAN'                          # base    # MailScanner
    # #     perl-local-lib                       #         #
    # PKG+=' perl-Data-Dump'                     # epel    # MailScanner
    # # perl-Date-Manip                          # TODO    #
    # # perl-DateTime                            # TODO    #
    # # perl-DBD-MySQL                           # TODO    #
    # PKG+=' perl-DBD-SQLite'                    # base    # MailScanner
    # #     perl-DBI                             #         #
    # #     perl-Net-Daemon                      #         #
    # #     perl-PlRPC                           #         #
    # # perl-DBD-Pg                              # TODO    #
    # PKG+=' perl-Digest-SHA1'                   # base    # MailScanner
    # PKG+=' perl-Digest-HMAC'                   # base    # MailScanner
    # #     perl-Digest                          #         #
    # #     perl-Digest-MD5                      #         #
    # #     perl-Digest-SHA                      #         #
    # PKG+=' perl-Encode-Detect'                 # base    # MailScanner
    # # perl-Email-Date-Format                   # TODO    #
    # PKG+=' perl-Env'                           # base    # MailScanner
    # PKG+=' perl-ExtUtils-CBuilder'             # base    # MailScanner
    # #     perl-IPC-Cmd                         #         #
    # #     perl-Locale-Maketext                 #         #
    # #     perl-Locale-Maketext-Simple          #         #
    # #     perl-Module-CoreList                 #         #
    # #     perl-Module-Load                     #         #
    # #     perl-Module-Load-Conditional         #         #
    # #     perl-Module-Metadata                 #         #
    # #     perl-Params-Check                    #         #
    # #     perl-Perl-OSType                     #         #
    # PKG+=' perl-ExtUtils-MakeMaker'            # base    # MailScanner
    # #     gdbm-devel                           #         #
    # #     libdb-devel                          #         #
    # #     perl-ExtUtils-Install                #         #
    # #     perl-ExtUtils-Manifest               #         #
    # #     perl-ExtUtils-ParseXS                #         #
    # #     perl-Test-Harness                    #         #
    # #     perl-devel                           #         #
    # #     pyparsing                            #         #
    # #     systemtap-sdt-devel                  #         #
    # # perl-File-Copy-Recursive                 # TODO    #
    # PKG+=' perl-File-ShareDir-Install'         # epel    # MailScanner
    # PKG+=' perl-Filesys-Df'                    # epel    # MailScanner
    # PKG+=' perl-HTML-Parser'                   # base    # MailScanner
    # #     mailcap                              #         #
    # #     perl-Business-ISBN                   #         #
    # #     perl-Business-ISBN-Data              #         #
    # #     perl-Encode-Locale                   #         #
    # #     perl-HTML-Tagset                     #         #
    # #     perl-HTTP-Date                       #         #
    # #     perl-HTTP-Message                    #         #
    # #     perl-IO-HTML                         #         #
    # #     perl-LWP-MediaTypes                  #         #
    # #     perl-URI                             #         #
    # PKG+=' perl-Inline'                        # base    # MailScanner
    # #     perl-Parse-RecDescent                #         #
    # PKG+=' perl-IO-String'                     # base    # MailScanner
    # # perl-List-MoreUtils                      # TODO    #
    # PKG+=' perl-LDAP'                          # base    # MailScanner
    # #     perl-Authen-SASL                     #         #
    # #     perl-Convert-ASN1                    #         #
    # #     perl-File-Listing                    #         #
    # #     perl-GSSAPI                          #         #
    # #     perl-HTTP-Cookies                    #         #
    # #     perl-HTTP-Daemon                     #         #
    # #     perl-HTTP-Negotiate                  #         #
    # #     perl-JSON                            #         #
    # #     perl-Net-HTTP                        #         #
    # #     perl-Text-Soundex                    #         #
    # #     perl-Text-Unidecode                  #         #
    # #     perl-WWW-RobotRules                  #         #
    # #     perl-XML-Filter-BufferText           #         #
    # #     perl-XML-NamespaceSupport            #         #
    # #     perl-XML-SAX-Base                    #         #
    # #     perl-XML-SAX-Writer                  #         #
    # #     perl-libwww-perl                     #         #
    # PKG+=' perl-Mail-DKIM'                     # base    # MailScanner
    # #     perl-Crypt-OpenSSL-Bignum            #         #
    # #     perl-Crypt-OpenSSL-RSA               #         #
    # #     perl-Crypt-OpenSSL-Random            #         #
    # #     perl-Net-DNS                         #         #
    # PKG+=' perl-Mail-IMAPClient'               # epel    # MailScanner
    # PKG+=' perl-Mail-SPF'                      # base    # MailScanner
    # #     perl-Error                           #         #
    # #     perl-NetAddr-IP                      #         #
    # #     perl-version                         #         #
    # # perl-MIME-Lite                           # TODO    #
    # # perl-MIME-Types                          # TODO    #
    # PKG+=' perl-Module-Build'                  # base    # MailScanner
    # #     perl-CPAN-Meta                       #         #
    # #     perl-CPAN-Meta-Requirements          #         #
    # #     perl-CPAN-Meta-YAML                  #         #
    # #     perl-JSON-PP                         #         #
    # #     perl-Parse-CPAN-Meta                 #         #
    # PKG+=' perl-Net-CIDR'                      # epel    # MailScanner
    # PKG+=' perl-Net-CIDR-Lite'                 # epel    # MailScanner
    # PKG+=' perl-Net-DNS-Resolver-Programmable' # base    # MailScanner
    # PKG+=' perl-Net-IP'                        # epel    # MailScanner
    # PKG+=' perl-OLE-Storage_Lite'              # epel    # MailScanner
    # # perl-Params-Validate                     # TODO    #
    # PKG+=' perl-Razor-Agent'                   # epel    # MailScanner
    # #     perl-Sys-Syslog                      # base    #
    # # perl-String-CRC32                        # TODO    #
    # PKG+=' perl-Sys-Hostname-Long'             # epel    # MailScanner
    # PKG+=' perl-Sys-SigAction'                 # epel    # MailScanner
    # # perl-Taint-Runtime                       # TODO    #
    # PKG+=' perl-Test-Manifest'                 # base    # MailScanner
    # PKG+=' perl-Test-Pod'                      # base    # MailScanner
    # #     perl-Test-Simple                     #         #
    # # perl-XML-DOM                             # TODO    #
    # # perl-XML-LibXML                          # TODO    #
    # # perl-XML-NamespaceSupport                # TODO    #
    # # perl-XML-Parser                          # TODO    #
    # # perl-XML-RegExp                          # TODO    #
    # # perl-XML-SAX                             # TODO    #
    # PKG+=' perl-YAML'                          # base    # MailScanner
    # # perl-YAML-Syck                           # TODO    #
    # PKG+=' libtool-ltdl'                       # base    # MailScanner

    # yum -y install $PKG

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
    # PKG='  unrar'                        # eFa     # MailScanner
    # PKG+=' postfix'                      # eFa     # MTA
    # #    libicu                          # base    #
    # #    mariadb-libs                    #         #
    # #    perl-Bit-Vector                 #         #
    # #    perl-Carp-Clan                  #         #
    # #    perl-Date-Calc postgresql-libs  #         #
    # #    tinycdb                         # epel    #
    # PKG+=' sqlgrey'                      # eFa     # Greylisting
    # PKG+=' spamassassin'                 # eFa     # MailScanner
    # #    perl-DB_File                    # base    #
    # #    perl-IO-Socket-INET6            #         #
    # #    perl-Socket6                    #         #
    # #    portreserve                     #         #
    # #    procmail                        #         #
    # #    perl-Geo-IP                     #         #
    # #    perl-Net-Patricia               #         #
    # PKG+=' MailScanner'                  # eFa     # MailScanner
    # PKG+=' clamav-unofficial-sigs'       # eFa     # clamav
    # PKG+=' perl-IP-Country'              # eFa     # MailScanner, Spamassassin
    # PKG+=' perl-Mail-SPF-Query'          # eFa     # MailScanner
    # # perl-Net-Ident                     # TODO    #
    # # perl-ExtUtils-Constant             # TODO    #
    # PKG+=' perl-Geography-Countries'     # eFa     # Spamassassin
    # PKG+=' perl-libnet'                  # eFa     # Spamassassin
    # # perl-Net-DNS-Nameserver            # TODO    #
    # # perl-IO-Multiplex                  # TODO    #
    # # perl-File-Tail                     # TODO    #
    # # perl-Net-Netmask                   # TODO    #
    # # perl-BerkeleyDB                    # TODO    #
    # # perl-Net-Server                    # TODO    #
    # PKG+=' perl-Encoding-FixLatin'       # eFa     # MailWatch
    # PKG+=' mailwatch'                    # eFa     # MailWatch Frontend
    # PKG+=' dcc'                          # eFa     # Spamassassin, MailScanner
    # PKG+-' eFa'                          # eFa     # The magic sauce

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
