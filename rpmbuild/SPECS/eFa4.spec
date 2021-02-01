#-----------------------------------------------------------------------------#
# eFa SPEC file definition
#-----------------------------------------------------------------------------#
# Copyright (C) 2013~2021 https://efa-project.org
#
# This SPEC is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This SPEC is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this SPEC. If not, see <http://www.gnu.org/licenses/>.
#-----------------------------------------------------------------------------#

#-----------------------------------------------------------------------------#
# Required packages for building this RPM
#-----------------------------------------------------------------------------#
# yum -y install
#-----------------------------------------------------------------------------#

Name:      eFa
Summary:   eFa Maintenance rpm
Version:   4.0.4
Release:   5.eFa%{?dist}
Epoch:     1
Group:     Applications/System
URL:       https://efa-project.org
License:   GNU GPL v3+
Source0:   eFa-%{version}.tar.gz
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch: noarch
# Control dependencies here as updates are released
# Use version and release numbers required for each update
# to maintain strict version control and dependency resolution
Requires:  clamav >= 0.101.0-1
    # clamav                                     # epel    # MailScanner
Requires:  clamav-update >= 0.101.0-1
    # clamav-update                              # epel    # MailScanner
Requires:  clamd >= 0.101.0-1
    # clamd			                             # epel    # MailScanner
%{?el7:Requires:  mariadb101u-server >= 1:10.1.35-1}
    # mariadb101u-server                         # IUS     # postfix, mailwatch
%{?el8:Requires:  mariadb-server >= 1:10.1.35-1}
    # mariadb-server                             # base    # postfix, mailwatch
Requires:  perl-DBD-MySQL >= 4.023-6
    # perl-DBD-mysql                             # base    # spamassassin
%{?el7:Requires:  php72u >= 7.2.13-2}
    # php72u                                     # IUS     # mailwatch, frontend
%{?el8:Requires:  php >= 7.2.13-2}
    # php                                        # base    # mailwatch, frontend
Requires:  bzip2-devel >= 1.0.6-13
    # bzip2-devel                                # base    # MailScanner
Requires:  screen >= 4.1.0-0.23.20120314git3c2946
    # screen                                     # base    # basic system tools
%{?el7:Requires:  php72u-gd >= 7.2.13-2}
    # php72u-gd                                  # IUS     # mailwatch, frontend
%{?el8:Requires:  php-gd >= 7.2.13-2}
    # php-gd                                     # base    # mailwatch, frontend
%{?el7:Requires:  php72u-mbstring >= 7.2.13-2}
    # php72u-mbstring                            # IUS     # mailwatch, frontend
%{?el8:Requires:  php-mbstring >= 7.2.13-2}
    # php-mbstring                               # base    # mailwatch, frontend
%{?el7:Requires:  php72u-mysqlnd >= 7.2.13-2}
    # php72u-mysqlnd                             # IUS     # mailwatch, frontend
%{?el8:Requires:  php-mysqlnd >= 7.2.13-2}
    # php-mysqlnd                                # base    # mailwatch, frontend
%{?el7:Requires:  php72u-ldap >= 7.2.13-2}
    # php72u-ldap                                # IUS     # mailwatch, frontend
%{?el8:Requires:  php-ldap >= 7.2.13-2}
    # php-ldap                                   # base    # mailwatch, frontend
Requires:  httpd >= 2.4.6-67
    # httpd                                      # base    # mailwatch, frontend
Requires:  cyrus-sasl-md5 >= 2.1.26-21
    # cyrus-sasl-md5                             # base    # postfix
Requires:  mod_ssl >= 2.4.6-88
    # mod_ssl                                    # base    # httpd
Requires:  openssl-devel >= 1.0.2k-16
    # openssl-devel                              # base    # MailScanner
Requires:  patch >= 2.7.1-10
    # patch                                      # base    # MailScanner
Requires:  pyzor >= 0.5.0-10
    # pyzor                                      # epel    # MailScanner
Requires:  re2c >= 0.14.3-2
    # re2c                                       # epel    # MailScanner
%{?el7:Requires:  tnef >= 1.4.15-1}
    # tnef                                       # epel    # MailScanner
%{?el8:Requires:  tnef >= 1:1.4.18-1}
    # tnef                                       # eFa     # MailScanner
Requires:  gcc >= 4.8.5-36
    # gcc                                        # base    # MailScanner
Requires:  perl-Archive-Tar >= 1.92-2
    # perl-Archive-Tar                           # base    # MailScanner
Requires:  perl-Archive-Zip >= 1.30-11
    # perl-Archive-Zip                           # base    # MailScanner
Requires:  perl-Convert-BinHex >= 1.119-20
    # perl-Convert-BinHex                        # epel    # MailScanner
Requires:  perl-Convert-TNEF >= 0.18-2
    # perl-Convert-TNEF                          # epel    # MailScanner
Requires:  perl-CPAN >= 1.9800-293
    # perl-CPAN                                  # base    # MailScanner
Requires:  perl-Data-Dump >= 1.22-1
    # perl-Data-Dump                             # epel    # MailScanner
Requires:  perl-DBD-SQLite >= 1.39-3
    # perl-DBD-SQLite                            # base    # MailScanner
Requires:  perl-Digest-SHA1 >= 2.13-9
    # perl-Digest-SHA1                           # base    # MailScanner
Requires:  perl-Digest-SHA >= 5.85-4
    # perl-Digest-SHA                            # base    # MailScanner
Requires:  perl-Digest-HMAC >= 1.03-5
    # perl-Digest-HMAC                           # base    # MailScanner
Requires:  perl-Encode-Detect >= 1.01-13
    # perl-Encode-Detect                         # base    # MailScanner
Requires:  perl-Env >= 1.04-2
    # perl-Env                                   # base    # MailScanner
Requires:  perl-ExtUtils-CBuilder >= 0.28.2.6-293
    # perl-ExtUtils-CBuilder                     # base    # MailScanner
Requires:  perl-ExtUtils-MakeMaker >= 6.68-3
    # perl-ExtUtils-MakeMaker                    # base    # MailScanner
Requires:  perl-File-ShareDir-Install >= 0.08-1
    # perl-File-ShareDir-Install                 # epel    # MailScanner
Requires:  perl-Filesys-Df >= 0.92-20
    # perl-Filesys-Df                            # epel    # MailScanner
Requires:  perl-HTML-Parser >= 3.71-4
    # perl-HTML-Parser                           # base    # MailScanner
Requires:  perl-Inline >= 0.53-4
    # perl-Inline                                # base    # MailScanner
Requires:  perl-IO-String >= 1.08-19
    # perl-IO-String                             # base    # MailScanner
Requires:  perl-LDAP >= 0.56-6
    # perl-LDAP                                  # base    # MailScanner
Requires:  perl-Mail-DKIM >= 0.39-8
    # perl-Mail-DKIM                             # base    # MailScanner
Requires:  perl-Mail-IMAPClient >= 3.37-1
    # perl-Mail-IMAPClient                       # epel    # MailScanner
Requires:  perl-Mail-SPF >= 2.8.0-4
    # perl-Mail-SPF                              # base    # MailScanner
Requires:  perl-Module-Build >= 0.40.05-2
    # perl-Module-Build                          # base    # MailScanner
Requires:  perl-Net-CIDR >= 0.18-1
    # perl-Net-CIDR                              # epel    # MailScanner
Requires:  perl-Net-CIDR-Lite >= 0.21-11
    # perl-Net-CIDR-Lite                         # epel    # MailScanner
Requires:  perl-Net-DNS-Resolver-Programmable >= 0.003-15
    # perl-Net-DNS-Resolver-Programmable         # base    # MailScanner
Requires:  perl-Net-IP >= 1.26-4
    # perl-Net-IP                                # epel    # MailScanner
Requires:  perl-OLE-Storage_Lite >= 0.19-9
    # perl-OLE-Storage_Lite                      # epel    # MailScanner
Requires:  perl-Razor-Agent >= 2.85-15
    # perl-Razor-Agent                           # epel    # MailScanner
Requires:  perl-Sys-Hostname-Long >= 1.5-1
    # perl-Sys-Hostname-Long                     # epel    # MailScanner
Requires:  perl-Sys-SigAction >= 0.20-1
    # perl-Sys-SigAction                         # epel    # MailScanner
Requires:  perl-Test-Manifest >= 1.23-2
    # perl-Test-Manifest                         # base    # MailScanner
Requires:  perl-Test-Pod >= 1.48-3
    # perl-Test-Pod                              # base    # MailScanner
Requires:  perl-YAML >= 0.84-5
    # perl-YAML                                  # base    # MailScanner
Requires:  libtool-ltdl >= 2.4.2-22
    # libtool-ltdl                               # base    # MailScanner
Requires:  unrar >= 5.8.3-1
    # unrar                                      # eFa     # MailScanner
Requires:  postfix_eFa >= 3.5.9-1
    # postfix_eFa                                # eFa     # MTA
%{?el7:Requires:  sqlgrey >= 1.8.0-8}
    # sqlgrey                                    # epel    # Greylisting
%{?el8:Requires:  sqlgrey >= 1:1.8.0-8}
    # sqlgrey                                    # eFa     # Greylisting
Requires:  spamassassin >= 3.4.4-2
    # spamassassin                               # eFa     # MailScanner
Requires:  MailScanner >= 5.4.1-1
    # MailScanner                                # eFa     # MailScanner
Requires:  clamav-unofficial-sigs >= 7.2.2-1
    # clamav-unofficial-sigs                     # eFa     # clamav
Requires:  perl-IP-Country >= 2.28-1
    # perl-IP-Country                            # eFa     # MailScanner, Spamassassin
Requires:  perl-Mail-SPF-Query >= 1.999.1-1
    # perl-Mail-SPF-Query                        # eFa     # MailScanner
Requires:  perl-Geography-Countries >= 2009041301-17
    # perl-Geography-Countries                   # eFa     # Spamassassin
Requires:  perl-libnet >= 3.11-1
    # perl-libnet                                # eFa     # Spamassassin
Requires:  perl-Encoding-FixLatin >= 1.04-1
    # perl-Encoding-FixLatin                     # eFa     # MailWatch
Requires:  MailWatch >= 1:1.2.16-1
    # MailWatch                                  # eFa     # MailWatch Frontend
Requires:  dcc >= 2.3.167-1
    # dcc                                        # eFa     # Spamassassin, MailScanner
Requires:  unbound >= 1.11.0-1
    # unbound                                    # eFa     # DNS
%{?el7:Requires:  yum-cron >= 3.4.3-154}
    # Yum auto updates                           # base    # yum-cron
%{?el8:Requires:  dnf-automatic >= 4.2.17-7}
    # dnf auto updates                           # base    # dnf-automatic
Requires:  checkpolicy >= 2.5-4
    # checkpolicy                                # base    # selinux
%{?el7:Requires:  policycoreutils-python >= 2.5-17.1}
    # policycoreutils-python                     # base    # selinux
%{?el7:Requires: perl-Net-DNS-Nameserver >= 0.72-6}
    # perl-Net-DNS-Nameserver                    # base    # Spamassassin
%{?el8:Requires: perl-Net-DNS >= 1.25-1}
    # perl-Net-DNS                               # eFa     # Spamassassin
Requires:  p7zip >= 16.02-2
    # p7zip                                      # epel    # MailScanner
Requires:  p7zip-plugins >= 16.02-2
    # p7zip-plugins                              # epel    # MailScanner
Requires:  tmpwatch >= 2.11-5
    # tmpwatch                                   # base    # Spamassassin
%{?el7:Requires: php72u-fpm >= 7.2.5-2}
    # php72u-fpm                                 # IUS     # mailwatch, frontend
%{?el8:Requires: php-fpm >= 7.2.5-2}
    # php-fpm                                    # base    # mailwatch, frontend
%{?el7:Requires: system-config-keyboard >= 1.4.0-4}
    # system-config-keyboard                     # base    # eFa
%{?el7:Requires: php72u-process >= 7.2.5-2}
    # php72u-process                             # IUS     # eFaInit
%{?el8:Requires: php-process >= 7.2.5-2}
    # php-process                                # base    # eFaInit
%{?el7:Requires: php72u-json >= 7.2.5-2}
    # php72u-json                                # IUS     # eFaInit
%{?el8:Requires: php-json >= 7.2.5-2}
    # php-json                                   # base    # eFaInit
Requires: sqlgreywebinterface >= 1.1.9-2
    # sqlgreywebinterrface                       # eFa     # mailwatch
Requires: perl-Sendmail-PMilter >= 1.00-1
    # perl-Sendmail-PMilter                      # eFa     # MailScanner
%{?el7:Requires: php72u-cli >= 7.2.13-2}
    # php72u-cli                                 # IUS     # mailwatch, frontend
%{?el8:Requires: php-cli >= 7.2.13-2}
    # php-cli                                    # base    # mailwatch, frontend
%{?el7:Requires: php72u-xml >= 7.2.13-2}
    # php72u-xml                                 # IUS     # mailwatch, frontend
%{?el8:Requires: php-xml >= 7.2.13-2}
    # php-xml                                    # base    # mailwatch, frontend
Requires: dovecot >= 1:2.2.36-3
    # clucene-core                               # base    # postfix
Requires: virt-what >= 1.18-4
    # virt-what                                  # base    # eFa
Requires: openssh-server >= 7.4p1-16
    # openssh-server                             # base    # eFa
Requires: sudo >= 1.8.23-3
    # sudo                                       # base    # eFa
Requires: chrony >= 3.2-2
    # chrony                                     # base    # eFa
Requires: firewalld >= 0.5.3-5
    # firewalld                                  # base    # eFa
Requires: file >= 5.11-35
    # file                                       # base    # MailScanner
Requires: eFa-base >= 4.0.0-1
    # eFa-base                                   # eFa     # eFa
%{?el7:Requires: python2-certbot-apache >= 0.29.1-1}
    #                                            # epel    # mailwatch, frontend
%{?el8:Requires: python3-certbot-apache >= 1.6.0-1}
    #                                            # epel    # mailwatch, frontend
%{?el8:Requires: rsync => 3.1.3-7}
    #                                            # base    # clamd
Requires: opendkim >= 2.11.0-0.1
    #                                            # epel    # eFa
Requires: opendmarc >= 1.3.2-0.12
    #                                            # epel    # eFa
Requires: cyrus-sasl >= 2.1.26-23
    #                                            # base    # eFa
Requires: cyrus-sasl-lib >= 2.1.26-23
    #                                            # base    # eFa
Requires: cyrus-sasl-plain >= 2.1.26-23
    #                                            # base    # eFa
Requires: perl-Math-Int64 >= 0.52
    #                                            # epel    # spamassassin
Requires: perl-IP-Country-DB_File >= 3.03-1
    #                                            # eFa     # spamassassin
Requires: perl-namespace-autoclean >= 0.19-1
    #                                            # epel    # spamassassin
Requires: perl-Data-IEEE754 >= 0.02-1
    #                                            # eFa     # spamassassin
Requires: perl-Data-Printer >= 0.40-1
    #                                            # eFa     # spamassassin
Requires: perl-Data-Validate-IP >= 0.27-1
    #                                            # eFa     # spamassassin
Requires: perl-GeoIP2-Country-Reader >= 2.006002-1
    #                                            # eFa     # spamassassin
Requires: perl-IP-Country-DB_File >= 3.03-1
    #                                            # eFa     # spamassassin
Requires: perl-List-AllUtils >= 0.15-1
    #                                            # eFa     # spamassassin
Requires: perl-List-SomeUtils >= 0.58-1
    #                                            # eFa     # spamassassin
Requires: perl-List-UtilsBy >= 0.11-1
    #                                            # eFa     # spamassassin
Requires: perl-MaxMind-DB-Metadata >= 0.040001-1
    #                                            # eFa     # spamassassin
Requires: perl-MaxMind-DB-Reader >= 1.000014-1
    #                                            # eFa     # spamassassin
Requires: perl-Module-Runtime >= 0.016-1
    #                                            # eFa     # spamassassin
Requires: perl-Moo >= 2.003006-1
    #                                            # eFa     # spamassassin
Requires: perl-MooX-StrictConstructor >= 0.010-1
    #                                            # eFa     # spamassassin
Requires: perl-Role-Tiny >= 2.001004-1
    #                                            # eFa     # spamassassin
Requires: perl-Scalar-List-Utils >= 1.53-1
    #                                            # eFa     # spamassassin
Requires: perl-strictures >= 2.000006-1
    #                                            # eFa     # spamassassin
Requires: perl-Sub-Quote >= 2.006006-1
    #                                            # eFa     # spamassassin
Requires: perl-Math-Int128 >= 0.22-1
    #                                            # eFa     # spamassassin
Requires: perl-Net-Works-Network >= 0.22-1
    #                                            # eFa     # spamassassin
Requires: perl-MaxMind-DB-Reader-XS >= 1.000008-1
    #                                            # eFa     # spamassassin
%{?el8:Requires: perl-Switch >= 2.17-10}
    #                                            # base    # opendmarc
Requires: fail2ban >= 0.11.1-9
    #                                            # epel    # eFa
%{?el8:Requires: rsyslog >= 8.1911.0-3}
    #                                            # base    # eFa
Requires: tar >= 1.26-35
    #                                            # base    # eFa

%description
eFa stands for Email Filter Appliance. eFa is born out of a need for a
cost-effective email virus & spam scanning solution after the ESVA project
died.

We try to create a complete package using existing open-source anti-spam
projects and combine them to a single easy to use (virtual) appliance.

For more information go to https://efa-project.org

eFa V4 is a rebuild of the previous ESVA; the same components are used whenever
possible but are all updated to the latest version.

%prep
%setup -q

%build

%install
rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT

# Move eFa-Configure into position
mkdir -p $RPM_BUILD_ROOT%{_localstatedir}/eFa/lib/eFa-Configure
mkdir -p $RPM_BUILD_ROOT%{_sbindir}
mv eFa/lib-eFa-Configure/* $RPM_BUILD_ROOT%{_localstatedir}/eFa/lib/eFa-Configure
mv eFa/eFa-Configure $RPM_BUILD_ROOT%{_sbindir}

# Move modules into position
mkdir -p $RPM_BUILD_ROOT%{_localstatedir}/eFa/lib/selinux
mkdir -p $RPM_BUILD_ROOT%{_localstatedir}/eFa/lib/token
mkdir -p $RPM_BUILD_ROOT%{_localstatedir}/www/html/mailscanner/
mv eFa/eFa-release.php $RPM_BUILD_ROOT%{_localstatedir}/www/html/mailscanner/
mv eFa/CustomAction.pm $RPM_BUILD_ROOT%{_localstatedir}/eFa/lib/token
mv eFa/efatokens.sql $RPM_BUILD_ROOT%{_localstatedir}/eFa/lib/token
mv eFa/eFavmtools.te $RPM_BUILD_ROOT%{_localstatedir}/eFa/lib/selinux
mv eFa/eFahyperv.te $RPM_BUILD_ROOT%{_localstatedir}/eFa/lib/selinux
mv eFa/eFaqemu.te $RPM_BUILD_ROOT%{_localstatedir}/eFa/lib/selinux
mv eFa/eFa.fc $RPM_BUILD_ROOT%{_localstatedir}/eFa/lib/selinux
mv eFa/eFa.te $RPM_BUILD_ROOT%{_localstatedir}/eFa/lib/selinux
mv eFa/eFa8.te $RPM_BUILD_ROOT%{_localstatedir}/eFa/lib/selinux
mv eFa/eFa-Monitor-cron $RPM_BUILD_ROOT%{_sbindir}
mv eFa/eFa-Backup-cron $RPM_BUILD_ROOT%{_sbindir}
mv eFa/eFa-Weekly-DMARC $RPM_BUILD_ROOT%{_sbindir}
mv eFa/eFa-Daily-DMARC $RPM_BUILD_ROOT%{_sbindir}
mkdir -p $RPM_BUILD_ROOT%{_sysconfdir}/cron.daily
mkdir -p $RPM_BUILD_ROOT%{_sysconfdir}/logrotate.d
mv eFa/eFa-Tokens.cron $RPM_BUILD_ROOT%{_sysconfdir}/cron.daily
mv eFa/eFa-Backup.cron $RPM_BUILD_ROOT%{_sysconfdir}/cron.daily
mv eFa/eFa-logrotate $RPM_BUILD_ROOT%{_sysconfdir}/logrotate.d
mv eFa/mysqltuner.pl $RPM_BUILD_ROOT%{_sbindir}
mkdir -p $RPM_BUILD_ROOT%{_usrsrc}/eFa/mariadb
mv eFa/schema.mysql $RPM_BUILD_ROOT%{_usrsrc}/eFa/mariadb
# Move update scripts into position
mv updates $RPM_BUILD_ROOT%{_usrsrc}/eFa

%pre

%preun

# leave files alone during uninstall (eFa package installs are permanent)

%postun

# leave files alone during uninstall (eFa package installs are permanent)

%post

flag=0
if [ "$1" = "1" ]; then
    # Perform Installation tasks

    # Sanity check in case rpm was removed
    if [[ -e %{_sysconfdir}/eFa-Version ]]; then
        echo "Previous eFa install detected."
        echo "Skipping post phase configuration tasks and executing all updates."
        flag=1
    else
        echo -e "\nPreparing to install eFa"

        /bin/sh %{_usrsrc}/eFa/postfix-config-4.0.0.sh
        /bin/sh %{_usrsrc}/eFa/mailscanner-config-4.0.0.sh
        /bin/sh %{_usrsrc}/eFa/clamav-config-4.0.0.sh
        /bin/sh %{_usrsrc}/eFa/clamav-unofficial-sigs-config-4.0.0.sh
        /bin/sh %{_usrsrc}/eFa/spamassassin-config-4.0.0.sh
        /bin/sh %{_usrsrc}/eFa/apache-config-4.0.0.sh
        /bin/sh %{_usrsrc}/eFa/sqlgrey-config-4.0.0.sh
        /bin/sh %{_usrsrc}/eFa/mailwatch-config-4.0.0.sh
        /bin/sh %{_usrsrc}/eFa/sgwi-config-4.0.0.sh
        /bin/sh %{_usrsrc}/eFa/pyzor-config-4.0.0.sh
        /bin/sh %{_usrsrc}/eFa/razor-config-4.0.0.sh
        /bin/sh %{_usrsrc}/eFa/dcc-config-4.0.0.sh
        /bin/sh %{_usrsrc}/eFa/unbound-config-4.0.0.sh
        /bin/sh %{_usrsrc}/eFa/yum-cron-config-4.0.0.sh
        /bin/sh %{_usrsrc}/eFa/service-config-4.0.0.sh
        /bin/sh %{_usrsrc}/eFa/eFa-config-4.0.0.sh
        /bin/sh %{_usrsrc}/eFa/eFaInit-config-4.0.0.sh

        echo "eFa-%{version}" > %{_sysconfdir}/eFa-Version
        echo "Build completed!"
    fi
fi
if [[ "$1" == "2" || "$flag" == "1" ]]; then
    # Perform Update tasks
    echo -e "\nPreparing to update eFa..."

   # 4.0.0-x cumulative fixes
   if [[ %{version} == "4.0.0" || "$flag" == "1" ]]; then
     {
       /bin/sh %{_usrsrc}/eFa/updates/update-4.0.0.sh
       [[ $? -ne 0 ]] && echo "Error while updating eFa, Please visit https://efa-project.org to report the commands executed above." && exit 0
     } 2>&1 | tee -a /var/log/eFa/update.log
   fi
   if [[ %{version} == "4.0.1" || "$flag" == "1" ]]; then
     {
       /bin/sh %{_usrsrc}/eFa/updates/update-4.0.1.sh
       [[ $? -ne 0 ]] && echo "Error while updating eFa, Please visit https://efa-project.org to report the commands executed above." && exit 0
     } 2>&1 | tee -a /var/log/eFa/update.log
   fi

   if [[ %{version} == "4.0.2" || "$flag" == "1" ]]; then
     {
       /bin/sh %{_usrsrc}/eFa/updates/update-4.0.2.sh
       [[ $? -ne 0 ]] && echo "Error while updating eFa, Please visit https://efa-project.org to report the commands executed above." && exit 0
     } 2>&1 | tee -a /var/log/eFa/update.log
   fi

   if [[ %{version} == "4.0.3" || "$flag" == "1" ]]; then
     {
       /bin/sh %{_usrsrc}/eFa/updates/update-4.0.3.sh
       [[ $? -ne 0 ]] && echo "Error while updating eFa, Please visit https://efa-project.org to report the commands executed above." && exit 0
     } 2>&1 | tee -a /var/log/eFa/update.log
   fi

    if [[ %{version} == "4.0.4" || "$flag" == "1" ]]; then
     {
       /bin/sh %{_usrsrc}/eFa/updates/update-4.0.4.sh
       [[ $? -ne 0 ]] && echo "Error while updating eFa, Please visit https://efa-project.org to report the commands executed above." && exit 0
     } 2>&1 | tee -a /var/log/eFa/update.log
   fi

    # cleanup if sucessful
    rm -rf /usr/src/eFa
    echo "eFa-%{version}" > %{_sysconfdir}/eFa-Version

    echo "Update completed successfully!"
fi

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-, root, root, -)
%{_usrsrc}/eFa
%{_localstatedir}/eFa/lib/eFa-Configure
%attr(0755, root, root) %{_sbindir}/eFa-Configure
%attr(0755, root, root) %{_sbindir}/eFa-Monitor-cron
%attr(0755, root, root) %{_sbindir}/eFa-Backup-cron
%attr(0755, root, root) %{_sbindir}/mysqltuner.pl
%attr(0755, root, root) %{_sbindir}/eFa-Weekly-DMARC
%attr(0755, root, root) %{_sbindir}/eFa-Daily-DMARC
%attr(0755, root, root) %{_localstatedir}/eFa/lib/selinux/eFavmtools.te
%attr(0755, root, root) %{_localstatedir}/eFa/lib/selinux/eFahyperv.te
%attr(0755, root, root) %{_localstatedir}/eFa/lib/selinux/eFaqemu.te
%attr(0755, root, root) %{_localstatedir}/eFa/lib/selinux/eFa.fc
%attr(0755, root, root) %{_localstatedir}/eFa/lib/selinux/eFa.te
%attr(0755, root, root) %{_localstatedir}/eFa/lib/selinux/eFa8.te
%attr(0755, root, root) %{_localstatedir}/eFa/lib/token/efatokens.sql
%attr(0644, root, root) %{_localstatedir}/eFa/lib/token/CustomAction.pm
%attr(0644, root, root) %{_localstatedir}/www/html/mailscanner/eFa-release.php
%attr(0755, root, root) %{_sysconfdir}/cron.daily/eFa-Backup.cron
%attr(0755, root, root) %{_sysconfdir}/cron.daily/eFa-Tokens.cron
%attr(0644, root, root) %{_sysconfdir}/logrotate.d/eFa-logrotate

%changelog
* Sun Jan 31 2021 eFa Project <shawniverson@efa-project.org> - 4.0.4-5
- Fix SQLGrey initial load and db character set conversion

* Sun Jan 31 2021 eFa Project <shawniverson@efa-project.org> - 4.0.4-4
- Tidy up permissions on key files

* Sun Jan 31 2021 eFa Project <shawniverson@efa-project.org> - 4.0.4-3
- Fix hang on update for token db creation

* Sun Jan 31 2021 eFa Project <shawniverson@efa-project.org> - 4.0.4-2
- Fix error on update for token db creation

* Sat Jan 30 2021 eFa Project <shawniverson@efa-project.org> - 4.0.4-1
- Add spam release logic back to eFa

* Wed Jan 27 2021 eFa Project <shawniverson@efa-project.org> - 4.0.3-19
- Update MailScanner, fix yara rules, sqlgrey unicode, etc.

* Tue Jan 05 2021 eFa Project <shawniverson@efa-project.org> - 4.0.3-18
- Update clamav-unofficial-sigs, MailWatch, cleanup eFaInit view

* Wed Dec 30 2020 eFa Project <shawniverson@efa-project.org> - 4.0.3-17
- Revert requirements for php and move development to dev repo

* Sun Dec 27 2020 eFa Project <shawniverson@efa-project.org> - 4.0.3-16
- Relax requirements for php in preparation for php upgrades

* Sat Dec 12 2020 eFa Project <shawniverson@efa-project.org> - 4.0.3-15
- Use https for web bug replacement

* Fri Nov 13 2020 eFa Project <shawniverson@efa-project.org> - 4.0.3-14
- MailScanner, clamav-unofficial-sigs, eFa updates

* Fri Nov 13 2020 eFa Project <shawniverson@efa-project.org> - 4.0.3-13
- MailScanner update for eFa to fix recipient issue

* Sat Nov 01 2020 eFa Project <shawniverson@efa-project.org> - 4.0.3-12
- Multiple updates and fixes for eFa

* Sat Oct 25 2020 eFa Project <shawniverson@efa-project.org> - 4.0.3-11
- Fix sample-spam path variable

* Sat Oct 25 2020 eFa Project <shawniverson@efa-project.org> - 4.0.3-10
- Fix quotes on sample-spam path variable

* Sat Oct 25 2020 eFa Project <shawniverson@efa-project.org> - 4.0.3-9
- Fix spacing on sample-spam path variable

* Sat Oct 25 2020 eFa Project <shawniverson@efa-project.org> - 4.0.3-8
- Lower verbosy of Razor during update and fix sample-spam path

* Sat Oct 25 2020 eFa Project <shawniverson@efa-project.org> - 4.0.3-7
- Razor fixes and CentOS 7 unbound backport

* Sat Sep 19 2020 eFa Project <shawniverson@efa-project.org> - 4.0.3-6
- Ensure clamav-freshclam is enabled and started

* Sat Sep 19 2020 eFa Project <shawniverson@efa-project.org> - 4.0.3-5
- Fixes for update script

* Sat Sep 19 2020 eFa Project <shawniverson@efa-project.org> - 4.0.3-4
- Enable mod_negotiation.so for Apache to allow LanguagePriority

* Sat Sep 19 2020 eFa Project <shawniverson@efa-project.org> - 4.0.3-3
- Fix DNS resolution during eFa Initialization

* Sat Sep 12 2020 eFa Project <shawniverson@efa-project.org> - 4.0.3-2
- Fail2ban eFa-Configure

* Sat Sep 12 2020 eFa Project <shawniverson@efa-project.org> - 4.0.3-1
- Fail2ban support and eFa-SAClean fix

* Sat Aug 29 2020 eFa Project <shawniverson@efa-project.org> - 4.0.2-31
- Include perl-Switch CentOS 8 and include OpenDMARC in restores

* Sun Aug 27 2020 eFa Project <shawniverson@efa-project.org> - 4.0.2-30
- SELinux update and MailWatch update

* Sun Aug 23 2020 eFa Project <shawniverson@efa-project.org> - 4.0.2-29
- SELinux update

* Sun Aug 23 2020 eFa Project <shawniverson@efa-project.org> - 4.0.2-28
- Fix for unbound segfault CentOS 8

* Sun Aug 23 2020 eFa Project <shawniverson@efa-project.org> - 4.0.2-27
- SELinux update

* Sat Aug 22 2020 eFa Project <shawniverson@efa-project.org> - 4.0.2-26
- SELinux update

* Sat Aug 22 2020 eFa Project <shawniverson@efa-project.org> - 4.0.2-25
- Prep for CentOS 8

* Sun Aug 09 2020 eFa Project <shawniverson@efa-project.org> - 4.0.2-24
- SELinux update

* Sun Aug 09 2020 eFa Project <shawniverson@efa-project.org> - 4.0.2-23
- Write RECURSIVEDNS setting to eFa-Config

* Sun Aug 09 2020 eFa Project <shawniverson@efa-project.org> - 4.0.2-22
- Fix RECURSIVEDNS for IP Settings CLI

* Sun Aug 02 2020 eFa Project <shawniverson@efa-project.org> - 4.0.2-21
- Additional fixes for IP Settings CLI

* Sun Aug 02 2020 eFa Project <shawniverson@efa-project.org> - 4.0.2-20
- Fix settings hostname with IP Settings CLI

* Sun Jul 26 2020 eFa Project <shawniverson@efa-project.org> - 4.0.2-19
- Improve IP Settings CLI

* Sun Jul 19 2020 eFa Project <shawniverson@efa-project.org> - 4.0.2-18
- Apply SELinux updates

* Sun Jul 19 2020 eFa Project <shawniverson@efa-project.org> - 4.0.2-17
- SELinux updates

* Sat Jun 06 2020 eFa Project <shawniverson@efa-project.org> - 4.0.2-16
- Update MailScanner

* Sat May 03 2020 eFa Project <shawniverson@efa-project.org> - 4.0.2-15
- Update MailScanner and MailWatch

* Tue Apr 18 2020 eFa Project <shawniverson@efa-project.org> - 4.0.2-14
- Fix for spamassassin symlink

* Tue Apr 14 2020 eFa Project <shawniverson@efa-project.org> - 4.0.2-13
- Fix for dns

* Sun Apr 12 2020 eFa Project <shawniverson@efa-project.org> - 4.0.2-12
- Update for MailScanner

* Sun Apr 12 2020 eFa Project <shawniverson@efa-project.org> - 4.0.2-11
- Fix 1x1 spacer

* Sun Apr 12 2020 eFa Project <shawniverson@efa-project.org> - 4.0.2-10
- Update for MailScanner

* Sun Mar 01 2020 eFa Project <shawniverson@efa-project.org> - 4.0.2-9
- Disable NetworkManager overriding dns

* Tue Feb 25 2020 eFa Project <shawniverson@efa-project.org> - 4.0.2-8
- Fix sudden package name change in epel repo clamav-server to clamd

* Sat Feb 08 2020 eFa Project <shawniverson@efa-project.org> - 4.0.2-7
- Update MailWatchConf.pm after updating MailWatch

* Sat Feb 08 2020 eFa Project <shawniverson@efa-project.org> - 4.0.2-6
- Updates for MailWatch

* Wed Feb 05 2020 eFa Project <shawniverson@efa-project.org> - 4.0.2-5
- Additional modules for MaxMind DB lookup performance

* Sun Feb 02 2020 eFa Project <shawniverson@efa-project.org> - 4.0.2-4
- Fix missed files in packaging

* Sun Feb 02 2020 eFa Project <shawniverson@efa-project.org> - 4.0.2-3
- Fix new archive rulesets

* Sun Feb 02 2020 eFa Project <shawniverson@efa-project.org> - 4.0.2-2
- Enable RelayCountry plugin for Spamassassin

* Sat Feb 01 2020 eFa Project <shawniverson@efa-project.org> - 4.0.2-1
- Add modules for Spamassassin and GeoIP2

* Sun Jan 26 2020 eFa Project <shawniverson@efa-project.org> - 4.0.1-15
- Fix missing rules entries

* Sun Jan 26 2020 eFa Project <shawniverson@efa-project.org> - 4.0.1-14
- Detect and run sa-update/sa-compile if needed plus other fixes

* Sat Jan 25 2020 eFa Project <shawniverson@efa-project.org> - 4.0.1-13
- Fix password.rules again during update

* Sat Jan 25 2020 eFa Project <shawniverson@efa-project.org> - 4.0.1-12
- Fix password.rules during update

* Sun Jan 19 2020 eFa Project <shawniverson@efa-project.org> - 4.0.1-11
- Fix queue permissions for Mailwatch queue polling

* Sun Jan 19 2020 eFa Project <shawniverson@efa-project.org> - 4.0.1-10
- Add MailScanner, Spamssassin, and postfix updates

* Sun Jan 12 2020 eFa Project <shawniverson@efa-project.org> - 4.0.1-9
- Add logic to implement all updates on reinstall

* Mon Dec 30 2019 eFa Project <shawniverson@efa-project.org> - 4.0.1-8
- Fix missing ) in update-4.0.1.sh

* Mon Dec 30 2019 eFa Project <shawniverson@efa-project.org> - 4.0.1-7
- Redefine password in MailWatchConf.pm after update

* Sun Dec 29 2019 eFa Project <shawniverson@efa-project.org> - 4.0.1-6
- Display current maxmind key if present

* Sat Dec 28 2019 eFa Project <shawniverson@efa-project.org> - 4.0.1-5
- Fix eFa-Configure maxmind key entry

* Sat Dec 28 2019 eFa Project <shawniverson@efa-project.org> - 4.0.1-4
- Fix eFa-Configure maxmind menu option

* Sat Dec 28 2019 eFa Project <shawniverson@efa-project.org> - 4.0.1-3
- Fix update script sed

* Sat Dec 28 2019 eFa Project <shawniverson@efa-project.org> - 4.0.1-2
- Fix spec file to allow updates

* Fri Dec 27 2019 eFa Project <shawniverson@efa-project.org> - 4.0.1-1
- Updates and Fixes for eFa 4.0.1 <https://efa-project.org>

* Fri Nov 15 2019 eFa Project <shawniverson@efa-project.org> - 4.0.0-68
- Updates and Fixes for eFa 4.0.0 <https://efa-project.org>

* Sun Nov 03 2019 eFa Project <shawniverson@efa-project.org> - 4.0.0-67
- Updates and Fixes for eFa 4.0.0 <https://efa-project.org>

* Sun Aug 18 2019 eFa Project <shawniverson@efa-project.org> - 4.0.0-66
- Updates and Fixes for eFa 4.0.0 <https://efa-project.org>

* Mon Jul 08 2019 eFa Project <shawniverson@efa-project.org> - 4.0.0-65
- Updates and Fixes for eFa 4.0.0 <https://efa-project.org>

* Mon Jul 08 2019 eFa Project <shawniverson@efa-project.org> - 4.0.0-64
- Updates and Fixes for eFa 4.0.0 <https://efa-project.org>

* Sun Jul 07 2019 eFa Project <shawniverson@efa-project.org> - 4.0.0-63
- Updates and Fixes for eFa 4.0.0 <https://efa-project.org>

* Sun Jul 07 2019 eFa Project <shawniverson@efa-project.org> - 4.0.0-62
- Updates and Fixes for eFa 4.0.0 <https://efa-project.org>

* Sun Mar 17 2019 eFa Project <shawniverson@efa-project.org> - 4.0.0-61
- Updates and Fixes for eFa 4.0.0 <https://efa-project.org>

* Sun Mar 03 2019 eFa Project <shawniverson@efa-project.org> - 4.0.0-60
- Updates and Fixes for eFa 4.0.0 <https://efa-project.org>

* Sun Mar 03 2019 eFa Project <shawniverson@efa-project.org> - 4.0.0-59
- Updates and Fixes for eFa 4.0.0 <https://efa-project.org>

* Sun Mar 03 2019 eFa Project <shawniverson@efa-project.org> - 4.0.0-58
- Updates and Fixes for eFa 4.0.0 <https://efa-project.org>

* Sun Mar 03 2019 eFa Project <shawniverson@efa-project.org> - 4.0.0-57
- Updates and Fixes for eFa 4.0.0 <https://efa-project.org>

* Sun Mar 03 2019 eFa Project <shawniverson@efa-project.org> - 4.0.0-56
- Updates and Fixes for eFa 4.0.0 <https://efa-project.org>

* Sun Mar 03 2019 eFa Project <shawniverson@efa-project.org> - 4.0.0-55
- Updates and Fixes for eFa 4.0.0 <https://efa-project.org>

* Sun Mar 03 2019 eFa Project <shawniverson@efa-project.org> - 4.0.0-54
- Updates and Fixes for eFa 4.0.0 <https://efa-project.org>

* Sun Mar 03 2019 eFa Project <shawniverson@efa-project.org> - 4.0.0-53
- Updates and Fixes for eFa 4.0.0 <https://efa-project.org>

* Sun Mar 03 2019 eFa Project <shawniverson@efa-project.org> - 4.0.0-52
- Updates and Fixes for eFa 4.0.0 <https://efa-project.org>

* Sun Mar 03 2019 eFa Project <shawniverson@efa-project.org> - 4.0.0-51
- Updates and Fixes for eFa 4.0.0 <https://efa-project.org>

* Sat Mar 02 2019 eFa Project <shawniverson@efa-project.org> - 4.0.0-50
- Updates and Fixes for eFa 4.0.0 <https://efa-project.org>

* Sat Mar 02 2019 eFa Project <shawniverson@efa-project.org> - 4.0.0-49
- Updates and Fixes for eFa 4.0.0 <https://efa-project.org>

* Sat Feb 23 2019 eFa Project <shawniverson@efa-project.org> - 4.0.0-48
- Updates and Fixes for eFa 4.0.0 <https://efa-project.org>

* Sat Feb 23 2019 eFa Project <shawniverson@efa-project.org> - 4.0.0-47
- Updates and Fixes for eFa 4.0.0 <https://efa-project.org>

* Sat Feb 23 2019 eFa Project <shawniverson@efa-project.org> - 4.0.0-46
- Updates and Fixes for eFa 4.0.0 <https://efa-project.org>

* Sat Feb 23 2019 eFa Project <shawniverson@efa-project.org> - 4.0.0-45
- Updates and Fixes for eFa 4.0.0 <https://efa-project.org>

* Sat Feb 23 2019 eFa Project <shawniverson@efa-project.org> - 4.0.0-44
- Updates and Fixes for eFa 4.0.0 <https://efa-project.org>

* Mon Feb 18 2019 eFa Project <shawniverson@efa-project.org> - 4.0.0-43
- Updates and Fixes for eFa 4.0.0 <https://efa-project.org>

* Mon Feb 18 2019 eFa Project <shawniverson@efa-project.org> - 4.0.0-42
- Updates and Fixes for eFa 4.0.0 <https://efa-project.org>

* Mon Feb 18 2019 eFa Project <shawniverson@efa-project.org> - 4.0.0-41
- Updates and Fixes for eFa 4.0.0 <https://efa-project.org>

* Sun Feb 17 2019 eFa Project <shawniverson@efa-project.org> - 4.0.0-40
- Updates and Fixes for eFa 4.0.0 <https://efa-project.org>

* Sun Feb 17 2019 eFa Project <shawniverson@efa-project.org> - 4.0.0-39
- Updates and Fixes for eFa 4.0.0 <https://efa-project.org>

* Sun Feb 17 2019 eFa Project <shawniverson@efa-project.org> - 4.0.0-38
- Updates and Fixes for eFa 4.0.0 <https://efa-project.org>

* Sat Feb 16 2019 eFa Project <shawniverson@efa-project.org> - 4.0.0-37
- Updates and Fixes for eFa 4.0.0 <https://efa-project.org>

* Sat Feb 16 2019 eFa Project <shawniverson@efa-project.org> - 4.0.0-36
- Updates and Fixes for eFa 4.0.0 <https://efa-project.org>

* Sat Feb 16 2019 eFa Project <shawniverson@efa-project.org> - 4.0.0-35
- Updates and Fixes for eFa 4.0.0 <https://efa-project.org>

* Sat Feb 16 2019 eFa Project <shawniverson@efa-project.org> - 4.0.0-34
- Updates and Fixes for eFa 4.0.0 <https://efa-project.org>

* Sat Feb 16 2019 eFa Project <shawniverson@efa-project.org> - 4.0.0-33
- Updates and Fixes for eFa 4.0.0 <https://efa-project.org>

* Sat Feb 16 2019 eFa Project <shawniverson@efa-project.org> - 4.0.0-32
- Updates and Fixes for eFa 4.0.0 <https://efa-project.org>

* Sat Feb 16 2019 eFa Project <shawniverson@efa-project.org> - 4.0.0-31
- Updates and Fixes for eFa 4.0.0 <https://efa-project.org>

* Sat Feb 16 2019 eFa Project <shawniverson@efa-project.org> - 4.0.0-30
- Updates and Fixes for eFa 4.0.0 <https://efa-project.org>

* Sat Feb 16 2019 eFa Project <shawniverson@efa-project.org> - 4.0.0-29
- Updates and Fixes for eFa 4.0.0 <https://efa-project.org>

* Fri Feb 15 2019 eFa Project <shawniverson@efa-project.org> - 4.0.0-28
- Updates and Fixes for eFa 4.0.0 <https://efa-project.org>

* Fri Feb 15 2019 eFa Project <shawniverson@efa-project.org> - 4.0.0-27
- Updates and Fixes for eFa 4.0.0 <https://efa-project.org>

* Fri Feb 15 2019 eFa Project <shawniverson@efa-project.org> - 4.0.0-26
- Updates and Fixes for eFa 4.0.0 <https://efa-project.org>

* Sat Feb 07 2019 eFa Project <shawniverson@efa-project.org> - 4.0.0-25
- Updates and Fixes for eFa 4.0.0 <https://efa-project.org>

* Sat Feb 07 2019 eFa Project <shawniverson@efa-project.org> - 4.0.0-24
- Updates and Fixes for eFa 4.0.0 <https://efa-project.org>

* Sat Feb 02 2019 eFa Project <shawniverson@efa-project.org> - 4.0.0-23
- Updates and Fixes for eFa 4.0.0 <https://efa-project.org>

* Sat Feb 02 2019 eFa Project <shawniverson@efa-project.org> - 4.0.0-22
- Updates and Fixes for eFa 4.0.0 <https://efa-project.org>

* Thu Jan 31 2019 eFa Project <shawniverson@efa-project.org> - 4.0.0-21
- Updates and Fixes for eFa 4.0.0 <https://efa-project.org>

* Thu Jan 31 2019 eFa Project <shawniverson@efa-project.org> - 4.0.0-20
- Updates and Fixes for eFa 4.0.0 <https://efa-project.org>

* Thu Jan 31 2019 eFa Project <shawniverson@efa-project.org> - 4.0.0-19
- Updates and Fixes for eFa 4.0.0 <https://efa-project.org>

* Thu Jan 31 2019 eFa Project <shawniverson@efa-project.org> - 4.0.0-18
- Updates and Fixes for eFa 4.0.0 <https://efa-project.org>

* Thu Jan 31 2019 eFa Project <shawniverson@efa-project.org> - 4.0.0-17
- Updates and Fixes for eFa 4.0.0 <https://efa-project.org>

* Wed Jan 30 2019 eFa Project <shawniverson@efa-project.org> - 4.0.0-16
- Updates and Fixes for eFa 4.0.0 <https://efa-project.org>

* Wed Jan 30 2019 eFa Project <shawniverson@efa-project.org> - 4.0.0-15
- Updates and Fixes for eFa 4.0.0 <https://efa-project.org>

* Wed Jan 30 2019 eFa Project <shawniverson@efa-project.org> - 4.0.0-14
- Updates and Fixes for eFa 4.0.0 <https://efa-project.org>

* Tue Jan 29 2019 eFa Project <shawniverson@efa-project.org> - 4.0.0-13
- Updates and Fixes for eFa 4.0.0 <https://efa-project.org>

* Tue Jan 29 2019 eFa Project <shawniverson@efa-project.org> - 4.0.0-12
- Updates and Fixes for eFa 4.0.0 <https://efa-project.org>

* Tue Jan 29 2019 eFa Project <shawniverson@efa-project.org> - 4.0.0-11
- Updates and Fixes for eFa 4.0.0 <https://efa-project.org>

* Sun Jan 27 2019 eFa Project <shawniverson@efa-project.org> - 4.0.0-10
- Updates and Fixes for eFa 4.0.0 <https://efa-project.org>

* Sun Jan 27 2019 eFa Project <shawniverson@efa-project.org> - 4.0.0-9
- Updates and Fixes for eFa 4.0.0 <https://efa-project.org>

* Wed Jan 23 2019 eFa Project <shawniverson@efa-project.org> - 4.0.0-8
- Updates and Fixes for eFa 4.0.0 <https://efa-project.org>

* Tue Jan 22 2019 eFa Project <shawniverson@efa-project.org> - 4.0.0-7
- Updates and Fixes for eFa 4.0.0 <https://efa-project.org>

* Mon Jan 21 2019 eFa Project <shawniverson@efa-project.org> - 4.0.0-6
- Updates and Fixes for eFa 4.0.0 <https://efa-project.org>

* Sun Jan 20 2019 eFa Project <shawniverson@efa-project.org> - 4.0.0-5
- Updates and Fixes for eFa 4.0.0 <https://efa-project.org>

* Sun Jan 20 2019 eFa Project <shawniverson@efa-project.org> - 4.0.0-4
- Updates and Fixes for eFa 4.0.0 <https://efa-project.org>

* Sat Jan 19 2019 eFa Project <shawniverson@efa-project.org> - 4.0.0-3
- Split eFa and eFa-base files <https://efa-project.org>

* Sat Jan 19 2019 eFa Project <shawniverson@efa-project.org> - 4.0.0-2
- Test LXC building and updating on CentOS7 <https://efa-project.org>

* Sat Jan 19 2019 eFa Project <shawniverson@efa-project.org> - 4.0.0-1
- Initial Build for eFa v4 on CentOS7 <https://efa-project.org>
