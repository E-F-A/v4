#!/bin/bash
######################################################################
# eFa 4.0.0 Build script for local development builds
######################################################################
# Copyright (C) 2018  https://efa-project.org
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

yum -y install epel-release
yum update
yum -y install rpm-build rpmdevtools gcc-c++ gcc perl-Net-DNS perl-NetAddr-IP openssl-devel perl-Test-Pod perl-HTML-Parser perl-Archive-Tar perl-devel perl-libwww-perl perl-DB_File perl-Mail-SPF perl-Encode-Detect perl-IO-Socket-INET6 perl-Mail-DKIM perl-Net-DNS-Resolver-Programmable perl-Parse-RecDescent perl-Inline perl-Test-Manifest perl-YAML perl-ExtUtils-CBuilder perl-Module-Build perl-IO-String perl-Geo-IP perl-Net-CIDR-Lite perl-Sys-Hostname-Long perl-Net-IP perl-Net-Patricia perl-Data-Dump perl-generators libicu-devel openldap-devel mysql-devel postgresql-devel  sqlite-devel tinycdb-devel 
mkdir -p rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
echo '%_topdir $(pwd)/rpmbuild' > ~/.rpmmacros
cd rpmbuild/SPECS
rpmbuild -ba clamav-unofficial-sigs.spec
rpmbuild -ba perl-IP-Country.spec
echo "n" | rpmbuild -ba perl-libnet.spec
rpm -ivh ../RPMS/x86_64/perl-libnet-3.11-1.eFa.el7.centos.x86_64.rpm
rpmbuild -ba perl-Geography-Countries.spec
rpm -ivh ../RPMS/x86_64/perl-Geography-Countries-2009041301-1.eFa.el7.centos.x86_64.rpm
rpm -ivh ../RPMS/x86_64/perl-IP-Country-2.28-1.eFa.el7.centos.x86_64.rpm
rpmbuild -ba perl-Text-Balanced.spec
rpm -ivh ../RPMS/x86_64/perl-Text-Balanced-2.03-1.eFa.el7.centos.x86_64.rpm
rpmbuild -ba Spamassassin.spec
rpmbuild -ba dcc.spec
rpmbuild -ba perl-Mail-SPF-Query.spec
rpmbuild -ba mailwatch-1.2.7.spec
rpmbuild -ba postfix-3.3.0.spec
rpmbuild -ba unrar-5.6.1.spec
