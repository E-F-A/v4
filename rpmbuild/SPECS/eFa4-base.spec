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

Name:      eFa-base
Summary:   eFa-base files rpm
Version:   4.0.0
Release:   1.eFa%{?dist}
Epoch:     1
Group:     Applications/System
URL:       https://efa-project.org
License:   GNU GPL v3+
Source0:   eFa-base-%{version}.tar.gz
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch: noarch
%{?el7:BuildRequires: php74-cli >= 7.4.15-1}
%{?el8:BuildRequires: php-cli >= 7.2.13-2}
BuildRequires: wget >= 1.14-18
%{?el7:BuildRequires: php74-json >= 7.4.15-1}
%{?el7:BuildRequires: php74-xml >= 7.4.15-1}
%{?el7:BuildRequires: php74-pdo >= 7.4.15-1}
%{?el8:BuildRequires: php-json >= 7.2.21-1}
%{?el8:BuildRequires: php-xml >= 7.2.21-1}
%{?el8:BuildRequires: php-pdo >= 7.2.21-1}


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

# Move modules into position
mkdir -p $RPM_BUILD_ROOT%{_sbindir}
mv eFa/eFa-Init $RPM_BUILD_ROOT%{_sbindir}
mv eFa/eFa-Commit $RPM_BUILD_ROOT%{_sbindir}
mv eFa/eFa-Post-Init $RPM_BUILD_ROOT%{_sbindir}

# move remaining contents of source straight into rpm
mkdir -p $RPM_BUILD_ROOT%{_usrsrc}/eFa
mv * $RPM_BUILD_ROOT%{_usrsrc}/eFa

# Install composer and build the eFaInit app
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

cd $RPM_BUILD_ROOT%{_localstatedir}/www/eFaInit
$RPM_BUILD_ROOT%{_bindir}/composer install --quiet

# Cleanup composer for rpm build
find $RPM_BUILD_ROOT%{_localstatedir}/www/eFaInit/var/cache/prod/ -type f -print0 | xargs -0 sed -i "s|$RPM_BUILD_ROOT||g" $i

%pre

%preun

%postun

%post

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-, root, root, -)
%{_usrsrc}/eFa
%{_localstatedir}/www/eFaInit
%attr(0755, root, root) %{_bindir}/composer
%attr(0755, root, root) %{_sbindir}/eFa-Init
%attr(0755, root, root) %{_sbindir}/eFa-Commit
%attr(0755, root, root) %{_sbindir}/eFa-Post-Init

%changelog
* Sat Jan 19 2019 eFa Project <shawniverson@efa-project.org> - 4.0.0-1
- Intitial Build <https://efa-project.org>
