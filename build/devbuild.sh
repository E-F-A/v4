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

# Git path
GITPATH="/root/v4"

# check if user is root
if [ `whoami` == root ]; then
  echo "Good you are root."
else
  echo "ERROR: Please become root first."
  exit 1
fi

# check if we run CentOS 7
OSVERSION=`cat /etc/centos-release`
if [[ $OSVERSION =~ .*'release 7.'.* ]]; then
  echo "- Good you are running CentOS 7"
else
  echo "- ERROR: You are not running CentOS 7"
  echo "- ERROR: Unsupported system, stopping now"
  exit 1
fi

yum -y install epel-release
[ $? != 0 ] && exit 1

# echo "- Adding mariadb Repo"
# cat > /etc/yum.repos.d/mariadb.repo << 'EOF'
# # MariaDB 10.1 CentOS repository list - created 2017-03-19 11:09 UTC
# # http://downloads.mariadb.org/mariadb/repositories/
# [mariadb]
# name = MariaDB
# baseurl = http://yum.mariadb.org/10.1/centos7-amd64
# gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
# gpgcheck=1
# enabled=1
# EOF

echo "- Adding IUS Repo"
yum -y install https://centos7.iuscommunity.org/ius-release.rpm
[ $? != 0 ] && exit 1
rpm --import /etc/pki/rpm-gpg/IUS-COMMUNITY-GPG-KEY
[ $? != 0 ] && exit 1

yum -y update
[ $? != 0 ] && exit 1

yum -y remove mariadb-libs
[ $? != 0 ] && exit 1

yum -y install rpm-build rpmdevtools gcc-c++ gcc perl-Net-DNS perl-NetAddr-IP openssl-devel perl-Test-Pod perl-HTML-Parser perl-Archive-Tar perl-devel perl-libwww-perl perl-DB_File perl-Mail-SPF perl-Encode-Detect perl-IO-Socket-INET6 perl-Mail-DKIM perl-Net-DNS-Resolver-Programmable perl-Parse-RecDescent perl-Inline perl-Test-Manifest perl-YAML perl-ExtUtils-CBuilder perl-Module-Build perl-IO-String perl-Geo-IP perl-Net-CIDR-Lite perl-Sys-Hostname-Long perl-Net-IP perl-Net-Patricia perl-Data-Dump perl-generators libicu-devel openldap-devel mysql-devel postgresql-devel sqlite-devel tinycdb-devel perl-Date-Calc perl-Sys-Syslog clamav perl-Geography-Countries php72u mariadb101u-server perl-Digest-SHA1 php72u-gd php72u-ldap php72u-mbstring php72u-mysqlnd php72u-xml perl-Archive-Zip perl-Env perl-Filesys-Df perl-IO-stringy perl-Net-CIDR perl-OLE-Storage_Lite perl-Sys-SigAction perl-MIME-tools wget php72u-json perl-Test-Simple
[ $? != 0 ] && exit 1

mkdir -p $GITPATH/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
[ $? != 0 ] && exit 1
echo "%_topdir $GITPATH/rpmbuild" > ~/.rpmmacros
[ $? != 0 ] && exit 1
cd $GITPATH/rpmbuild/SPECS
[ $? != 0 ] && exit 1
rpmbuild -ba postfix_eFa-3.3.0.spec
[ $? != 0 ] && exit 1
yum -y remove postfix postfix32u
[ $? != 0 ] && exit 1
yum -y install $GITPATH/rpmbuild/RPMS/x86_64/postfix_eFa-3.3.0-1.eFa.el7.x86_64.rpm
[ $? != 0 ] && exit 1
rpmbuild -ba clamav-unofficial-sigs.spec
[ $? != 0 ] && exit 1
yum -y install $GITPATH/rpmbuild/RPMS/x86_64/clamav-unofficial-sigs-5.6.2-3.eFa.el7.x86_64.rpm
[ $? != 0 ] && exit 1
echo "n" | rpmbuild -ba perl-libnet.spec
[ $? != 0 ] && exit 1
yum -y install $GITPATH/rpmbuild/RPMS/x86_64/perl-libnet-3.11-1.eFa.el7.x86_64.rpm
[ $? != 0 ] && exit 1
rpmbuild -ba perl-IP-Country.spec
[ $? != 0 ] && exit 1
yum -y install $GITPATH/rpmbuild/RPMS/x86_64/perl-IP-Country-2.28-1.eFa.el7.x86_64.rpm
[ $? != 0 ] && exit 1
rpmbuild -ba perl-Text-Balanced.spec
[ $? != 0 ] && exit 1
yum -y install $GITPATH/rpmbuild/RPMS/x86_64/perl-Text-Balanced-2.03-1.eFa.el7.x86_64.rpm
[ $? != 0 ] && exit 1
rpmbuild -ba perl-Mail-SPF-Query.spec
[ $? != 0 ] && exit 1
yum -y install $GITPATH/rpmbuild/RPMS/x86_64/perl-Mail-SPF-Query-1.999.1-1.eFa.el7.x86_64.rpm
[ $? != 0 ] && exit 1
rpmbuild -ba unrar-5.6.1.spec
[ $? != 0 ] && exit 1
yum -y install $GITPATH/rpmbuild/RPMS/x86_64/unrar-5.6.1-1.eFa.el7.x86_64.rpm
[ $? != 0 ] && exit 1
rpmbuild -ba Spamassassin.spec
[ $? != 0 ] && exit 1
yum -y install $GITPATH/rpmbuild/RPMS/x86_64/spamassassin-3.4.1-1.eFa.el7.x86_64.rpm
[ $? != 0 ] && exit 1
rpmbuild -ba perl-Encoding-FixLatin.spec
[ $? != 0 ] && exit 1
yum -y install $GITPATH/rpmbuild/RPMS/x86_64/perl-Encoding-FixLatin-1.04-1.eFa.el7.x86_64.rpm
[ $? != 0 ] && exit 1
rpmbuild -ba perl-Sendmail-PMilter.spec
[ $? != 0 ] && exit 1
yum -y install $GITPATH/rpmbuild/RPMS/x86_64/perl-Sendmail-PMilter-1.00-1.eFa.el7.x86_64.rpm
[ $? != 0 ] && exit 1
rpmbuild -ba MailWatch-1.2.9.spec
[ $? != 0 ] && exit 1
yum -y install $GITPATH/rpmbuild/RPMS/x86_64/MailWatch-1.2.9-1.eFa.el7.x86_64.rpm
[ $? != 0 ] && exit 1
cd $GITPATH/rpmbuild/SOURCES
[ $? != 0 ] && exit 1
rm -f eFa-4.0.0.tar.gz
[ $? != 0 ] && exit 1
tar czvf eFa-4.0.0.tar.gz eFa-4.0.0/
[ $? != 0 ] && exit 1
tar xzvf MailScanner-5.1.1-1.rhel.tar.gz
[ $? != 0 ] && exit 1
yum -y install MailScanner-5.1.1-1/MailScanner-5.1.1-1.noarch.rpm
[ $? != 0 ] && exit 1
cd $GITPATH/rpmbuild/SPECS
[ $? != 0 ] && exit 1
rpmbuild -ba dcc.spec
[ $? != 0 ] && exit 1
yum -y install $GITPATH/rpmbuild/RPMS/x86_64/dcc-1.3.163-1.eFa.el7.x86_64.rpm
[ $? != 0 ] && exit 1
rpmbuild -ba eFa4.spec
[ $? != 0 ] && exit 1
yum -y install $GITPATH/rpmbuild/RPMS/x86_64/eFa-4.0.0-1.eFa.el7.x86_64.rpm
[ $? != 0 ] && exit 1


