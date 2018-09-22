#-----------------------------------------------------------------------------#
# eFa SPEC file definition
#-----------------------------------------------------------------------------#
# Copyright (C) 2013~2018 https://efa-project.org
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
Version:   4.0.0
Release:   1.eFa%{?dist}
Epoch:     1
Group:     Applications/System
URL:       https://efa-project.org
License:   GNU GPL v3+
Source0:   eFa-%{version}.tar.gz
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
# Control dependencies here as updates are released
# Use version and release numbers required for each update
# to maintain strict version control and dependency resolution
Requires:  clamav >= 0.100.0-2
    # clamav                                     # epel    # MailScanner
    # #     clamav-data                          #         #
    # #     clamav-filesystem                    #         #
    # #     clamav-lib                           #         #
Requires:  clamav-update >= 0.99.4-1
    # clamav-update                              # epel    # MailScanner
Requires:  clamav-server >= 0.99.4-1
    # clamav-server                              # epel    # MailScanner
    # #     nmap-ncat                            # base    #
Requires:  mariadb101u-server >= 1:10.1.32-1
    # mariadb101u-server                         # IUS     # postfix, mailwatch
    # #     mariadb101u-common                   #         #
    # #     perl-Compress-Raw-Bzip2              #         #
    # #     perl-Compress-Raw-Zlib               #         #
    # #     perl-DBI                             #         #
    # #     perl-Data-Dumper                     #         #
    # #     perl-IO-Compress                     #         #
    # #     perl-Net-Daemon                      #         #
    # #     perl-PlRPC                           #         #
    # #     mariadb101u-client                   #         #
    # #     mariadb101u-shared                   #         #
    # #     galera                               #         #
    # #     jemalloc                             #         #
Requires:  perl-DBD-MySQL >= 4.023-5
    # perl-DBD-mysql                             # base    # spamassassin
Requires:  php72u >= 7.2.5-2
    # php72u                                     # IUS     # mailwatch, frontend
    # #     libzip                               #         #
    # #     php72u-cli                           #         #
    # #     php72u-common                        #         #
Requires:  bzip2-devel >= 1.0.6-13
    # bzip2-devel                                # base    # MailScanner
Requires:  screen >= 4.1.0-0.23.20120314git3c2946
    # screen                                     # base    # basic system tools
Requires:  php72u-gd >= 7.2.5-2
    # php72u-gd                                  # IUS     # mailwatch, frontend
    # #     libXpm                               #         #
    # #     t11ib                                #         #
Requires:  php72u-mbstring >= 7.2.5-2
    # php72u-mbstring                            # IUS     # mailwatch, frontend
Requires:  php72u-mysqlnd >= 7.2.5-2
    # php72u-mysqlnd                             # IUS     # mailwatch, frontend
    # #     php72u-pdo                           #         #
Requires:  php72u-ldap >= 7.2.5-2
    # php72u-ldap                                # IUS     # mailwatch, frontend
Requires:  httpd >= 2.4.6-67
    # httpd                                      # base    # mailwatch, frontend
    # #     apr                                  #         #
    # #     apr-util                             #         #
    # #     httpd-tools                          #         #
    # #     mailcap                              #         #
Requires:  cyrus-sasl-md5 >= 2.1.26-21
    # cyrus-sasl-md5                             # base    # postfix
Requires:  mod_ssl >= 2.4.6-67
    # mod_ssl                                    # base    # httpd
Requires:  openssl-devel >= 1.0.2k-8
    # openssl-devel                              # base    # MailScanner
    # #     keyutils-libs-devel                  #         #
    # #     libcom_err-devel                     #         #
    # #     libselinux-devel                     #         #
    # #     libsepol-devel                       #         #
    # #     libverto-devel                       #         #
    # #     pcre-devel                           #         #
    # #     zlib-devel                           #         #
    # #     krb5-devel                           # updates #
    # #     libkadm5                             #         #
Requires:  patch >= 2.7.1-8
    # patch                                      # base    # MailScanner
Requires:  pyzor >= 0.5.0-10
    # pyzor                                      # epel    # MailScanner
Requires:  re2c >= 0.14.3-2
    # re2c                                       # epel    # MailScanner
Requires:  tnef >= 1.4.15-1
    # tnef                                       # epel    # MailScanner
Requires:  gcc >= 4.8.5-16
    # gcc                                        # base    # MailScanner
    # #     cpp                                  #         #
    # #     libmpc                               #         #
    # #     mpfr                                 #         #
Requires:  perl-Archive-Tar >= 1.92-2
    # perl-Archive-Tar                           # base    # MailScanner
    # #     perl-Compress-Raw-Bzip2              #         #
    # #     perl-Compress-Raw-Zlib               #         #
    # #     perl-Data-Dumper                     #         #
    # #     perl-IO-Compress                     #         #
    # #     perl-IO-Zlib                         #         #
    # #     perl-Package-Constants               #         #
Requires:  perl-Archive-Zip >= 1.30-11
    # perl-Archive-Zip                           # base    # MailScanner
Requires:  perl-Convert-BinHex >= 1.119-20
    # perl-Convert-BinHex                        # epel    # MailScanner
Requires:  perl-Convert-TNEF >= 0.18-2
    # perl-Convert-TNEF                          # epel    # MailScanner
    # #     perl-IO-Socket-IP                    # base    #
    # #     perl-IO-Socket-SSL                   #         #
    # #     perl-IO-stringy                      #         #
    # #     perl-MailTools                       #         #
    # #     perl-Net-LibIDN                      #         #
    # #     perl-Net-SMTP-SSL                    #         #
    # #     perl-Net-SSLeay                      #         #
    # #     perl-TimeDate                        #         #
    # #     perl-MIME-tools                      # epel    #
Requires:  perl-CPAN >= 1.9800-292
    # perl-CPAN                                  # base    # MailScanner
    # #     perl-local-lib                       #         #
Requires:  perl-Data-Dump >= 1.22-1
    # perl-Data-Dump                             # epel    # MailScanner
Requires:  perl-DBD-SQLite >= 1.39-3
    # perl-DBD-SQLite                            # base    # MailScanner
    # #     perl-DBI                             #         #
    # #     perl-Net-Daemon                      #         #
    # #     perl-PlRPC                           #         #
Requires:  perl-Digest-SHA1 >= 2.13-9
    # perl-Digest-SHA1                           # base    # MailScanner
Requires:  perl-Digest-HMAC >= 1.03-5
    # perl-Digest-HMAC                           # base    # MailScanner
    # #     perl-Digest                          #         #
    # #     perl-Digest-MD5                      #         #
    # #     perl-Digest-SHA                      #         #
Requires:  perl-Encode-Detect >= 1.01-13
    # perl-Encode-Detect                         # base    # MailScanner
Requires:  perl-Env >= 1.04-2
    # perl-Env                                   # base    # MailScanner
Requires:  perl-ExtUtils-CBuilder >= 0.28.2.6-292
    # perl-ExtUtils-CBuilder                     # base    # MailScanner
    # #     perl-IPC-Cmd                         #         #
    # #     perl-Locale-Maketext                 #         #
    # #     perl-Locale-Maketext-Simple          #         #
    # #     perl-Module-CoreList                 #         #
    # #     perl-Module-Load                     #         #
    # #     perl-Module-Load-Conditional         #         #
    # #     perl-Module-Metadata                 #         #
    # #     perl-Params-Check                    #         #
    # #     perl-Perl-OSType                     #         #
Requires:  perl-ExtUtils-MakeMaker >= 6.68-3
    # perl-ExtUtils-MakeMaker                    # base    # MailScanner
    # #     gdbm-devel                           #         #
    # #     libdb-devel                          #         #
    # #     perl-ExtUtils-Install                #         #
    # #     perl-ExtUtils-Manifest               #         #
    # #     perl-ExtUtils-ParseXS                #         #
    # #     perl-Test-Harness                    #         #
    # #     perl-devel                           #         #
    # #     pyparsing                            #         #
    # #     systemtap-sdt-devel                  #         #
Requires:  perl-File-ShareDir-Install >= 0.08-1
    # perl-File-ShareDir-Install                 # epel    # MailScanner
Requires:  perl-Filesys-Df >= 0.92-20
    # perl-Filesys-Df                            # epel    # MailScanner
Requires:  perl-HTML-Parser >= 3.71-4
    # perl-HTML-Parser                           # base    # MailScanner
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
Requires:  perl-Inline >= 0.53-4
    # perl-Inline                                # base    # MailScanner
    # #     perl-Parse-RecDescent                #         #
Requires:  perl-IO-String >= 1.08-19
    # perl-IO-String                             # base    # MailScanner
Requires:  perl-LDAP >= 0.56-5
    # perl-LDAP                                  # base    # MailScanner
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
Requires:  perl-Mail-DKIM >= 0.39-8
    # perl-Mail-DKIM                             # base    # MailScanner
    # #     perl-Crypt-OpenSSL-Bignum            #         #
    # #     perl-Crypt-OpenSSL-RSA               #         #
    # #     perl-Crypt-OpenSSL-Random            #         #
    # #     perl-Net-DNS                         #         #
Requires:  perl-Mail-IMAPClient >= 3.37-1
    # perl-Mail-IMAPClient                       # epel    # MailScanner
Requires:  perl-Mail-SPF >= 2.8.0-4
    # perl-Mail-SPF                              # base    # MailScanner
    # #     perl-Error                           #         #
    # #     perl-NetAddr-IP                      #         #
    # #     perl-version                         #         #
Requires:  perl-Module-Build >= 0.40.05-2
    # perl-Module-Build                          # base    # MailScanner
    # #     perl-CPAN-Meta                       #         #
    # #     perl-CPAN-Meta-Requirements          #         #
    # #     perl-CPAN-Meta-YAML                  #         #
    # #     perl-JSON-PP                         #         #
    # #     perl-Parse-CPAN-Meta                 #         #
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
    # #     perl-Sys-Syslog                      # base    #
Requires:  perl-Sys-Hostname-Long >= 1.5-1
    # perl-Sys-Hostname-Long                     # epel    # MailScanner
Requires:  perl-Sys-SigAction >= 0.20-1
    # perl-Sys-SigAction                         # epel    # MailScanner
Requires:  perl-Test-Manifest >= 1.23-2
    # perl-Test-Manifest                         # base    # MailScanner
Requires:  perl-Test-Pod >= 1.48-3
    # perl-Test-Pod                              # base    # MailScanner
    # #     perl-Test-Simple                     #         #
Requires:  perl-YAML >= 0.84-5
    # perl-YAML                                  # base    # MailScanner
Requires:  libtool-ltdl >= 2.4.2-22
    # libtool-ltdl                               # base    # MailScanner
Requires:  unrar >= 5.4.5-1
    # unrar                                      # eFa     # MailScanner
Requires:  postfix_eFa >= 3.2.4-1
    # postfix_eFa                                # eFa     # MTA
    # #    libicu                                # base    #
    # #    mariadb-libs                          #         #
    # #    perl-Bit-Vector                       #         #
    # #    perl-Carp-Clan                        #         #
    # #    perl-Date-Calc postgresql-libs        #         #
    # #    tinycdb                               # epel    #
Requires:  sqlgrey >= 1.8.0-1
    # sqlgrey                                    # epel    # Greylisting
Requires:  spamassassin >= 3.4.1-1
    # spamassassin                               # eFa     # MailScanner
    # #    perl-DB_File                          # base    #
    # #    perl-IO-Socket-INET6                  #         #
    # #    perl-Socket6                          #         #
    # #    portreserve                           #         #
    # #    procmail                              #         #
    # #    perl-Geo-IP                           #         #
    # #    perl-Net-Patricia                     #         #
Requires:  MailScanner >= 5.0.7-4
    # MailScanner                                # eFa     # MailScanner
Requires:  clamav-unofficial-sigs >= 5.6.2-3
    # clamav-unofficial-sigs                     # eFa     # clamav
Requires:  perl-IP-Country >= 2.28-1
    # perl-IP-Country                            # eFa     # MailScanner, Spamassassin
Requires:  perl-Mail-SPF-Query >= 1.999.1-1
    # perl-Mail-SPF-Query                        # eFa     # MailScanner
Requires:  perl-Geography-Countries >= 2009041301-17
    # perl-Geography-Countries                   # eFa     # Spamassassin
Requires:  perl-libnet >= 3.10-1
    # perl-libnet                                # eFa     # Spamassassin
Requires:  perl-Encoding-FixLatin >= 1.04-1
    # perl-Encoding-FixLatin                     # eFa     # MailWatch
Requires:  MailWatch >= 1:1.2.9-1
    # MailWatch                                  # eFa     # MailWatch Frontend
Requires:  dcc >= 1.3.159-1
    # dcc                                        # eFa     # Spamassassin, MailScanner
Requires:  unbound >= 1.4.20-34
    # unbound                                    # base    # DNS
    #     ldns                                   #         #
    #     libevent                               #         #
    #     unbound-libs                           #         #
Requires:  yum-cron >= 3.4.3-154
    # Yum auto updates                           # base    # yum-cron
Requires:  checkpolicy >= 2.5-4
    # checkpolicy                                # base    # selinux
Requires:  policycoreutils-python >= 2.5-17.1
    # policycoreutils-python                     # base    # selinux
Requires: perl-Net-DNS-Nameserver >= 0.72-6
    # perl-Net-DNS-Nameserver                    # base    # Spamassassin
#Requires:  mod_security_crs
    # mod_security rule set                      # base    # httpd
    # #     mod_security                         #         #
Requires:  p7zip >= 16.02-2
    # p7zip     `                                # epel    # MailScanner
Requires:  p7zip-plugins >= 16.02-2
    # p7zip-plugins                              # epel    # MailScanner
Requires:  tmpwatch >= 2.11-5
    # tmpwatch                                   # base    # Spamassassin
    #   psmisc                                   #         #
Requires: php72u-fpm >= 7.2.5-2
    # php72u-fpm                                 # IUS     # mailwatch, frontend
Requires: system-config-keyboard >= 1.4.0-4
    # system-config-keyboard                     # base    # eFa
Requires: php72u-process >= 7.2.5-2
    # php72u-process                             # IUS     # eFaInit
Requires: php72u-json >= 7.2.5-2
    # php72u-json                                # IUS     # eFaInit
Requires: sqlgreywebinterface >= 1.1.9-2
    # sqlgreywebinterrface                       # eFa     # mailwatch
Requires: perl-Sendmail-PMilter >= 1.0.0-1
    # perl-Sendmail-PMilter                      # eFa     # MailScanner

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

# Move eFaInit into position
mkdir -p $RPM_BUILD_ROOT%{_localstatedir}/www
mv eFaInit $RPM_BUILD_ROOT%{_localstatedir}/www

# move remaining contents of source straight into rpm
mkdir -p $RPM_BUILD_ROOT%{_usrsrc}/eFa
mv * $RPM_BUILD_ROOT%{_usrsrc}/eFa

# Install composer for building symfony apps
EXPECTED_SIGNATURE=$(wget -q -O - https://composer.github.io/installer.sig)
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
ACTUAL_SIGNATURE=$(php -r "echo hash_file('SHA384', 'composer-setup.php');")

if [ "$EXPECTED_SIGNATURE" != "$ACTUAL_SIGNATURE" ]; then
    >&2 echo 'ERROR: Invalid installer signature'
    rm composer-setup.php
    exit 1
fi

mkdir -p $RPM_BUILD_ROOT%{_bindir}
php composer-setup.php --quiet --install-dir=$RPM_BUILD_ROOT%{_bindir} --filename=composer
rm composer-setup.php

%pre

%preun

%postun

%post

if [ "$1" = "1" ]; then
    # Perform Installation tasks
    
    # Sanity check in case rpm was removed
    if [[ -e %{_sysconfdir}/eFa-Version ]]; then
        echo "Previous eFa install detected."
        echo "Skipping post phase configuration tasks."
    else
        echo -e "\nPreparing to install eFa"

        /bin/sh %{_usrsrc}/eFa/prepare-os-4.0.0.sh
        /bin/sh %{_usrsrc}/eFa/mariadb-config-4.0.0.sh
        /bin/sh %{_usrsrc}/eFa/postfix-config-4.0.0.sh
        /bin/sh %{_usrsrc}/eFa/mailscanner-config-4.0.0.sh
        /bin/sh %{_usrsrc}/eFa/clamav-config-4.0.0.sh
        /bin/sh %{_usrsrc}/eFa/clamav-unofficial-sigs-config-4.0.0.sh
        /bin/sh %{_usrsrc}/eFa/spamassassin-config-4.0.0.sh
        /bin/sh %{_usrsrc}/eFa/apache-config-4.0.0.sh
        /bin/sh %{_usrsrc}/eFa/sqlgrey-config-4.0.0.sh
        /bin/sh %{_usrsrc}/eFa/mailwatch-config-4.0.0.sh
        /bin/sh %{_usrsrc}/eFa/sgwi-config.4.0.0.sh
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

elif [ "$1" = "2" ]; then
    # Perform Update tasks
    echo "no update available yet"
fi

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-, root, root, -)
%{_usrsrc}/eFa
%{_localstatedir}/www/eFaInit
%{_bindir}/composer

%changelog
* Thu Mar 22 2017 eFa Project <somebody@efa-project.org> - 4.0.0-1
- Initial Build for eFa v4 on CentOS7 <https://efa-project.org>
