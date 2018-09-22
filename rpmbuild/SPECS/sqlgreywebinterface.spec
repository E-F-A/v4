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
Summary:       SQLGrey Web Interface Legacy
Name:          sqlgreywebinterface
Version:       1.1.9
Epoch:         1
Release:       2.eFa%{?dist}
License:       GNU GPL v2
Group:         Applications/Utilities
URL:           https://github.com/flok99/sgwi
Source:        %{name}-%{version}.tar.gz
BuildRoot:     %{_tmppath}/%{name}-%{version}-%{release}-root
Requires:      httpd >= 2.4.6
Requires:      php72u >= 7.2.5-2

%description
A SQLGrey webinterface

%prep
%setup -q -n %{name}-%{version}

%build
# Nothing to do

%install
%{__rm} -rf %{buildroot}

# Copy files to proper locations
mkdir -p %{buildroot}%{_localstatedir}/www/html/sgwi
cp -ra * %{buildroot}%{_localstatedir}/www/html/sgwi

# Remove doc info
rm %{buildroot}%{_localstatedir}/www/html/sgwi/{README.md,license.txt,readme.txt}

%pre
# Nothing to do

%post
# Nothing to do

%clean
%{__rm} -rf %{buildroot}

%files
%defattr(-, root, root)
%doc README.md license.txt readme.txt
%{_localstatedir}/www/html/sgwi/awl.php
%{_localstatedir}/www/html/sgwi/connect.php
%{_localstatedir}/www/html/sgwi/index.php
%{_localstatedir}/www/html/sgwi/main.css
%{_localstatedir}/www/html/sgwi/opt_in_out.php
%{_localstatedir}/www/html/sgwi/includes/awl.inc.php
%{_localstatedir}/www/html/sgwi/includes/connect.inc.php
%{_localstatedir}/www/html/sgwi/includes/functions.inc.php
%{_localstatedir}/www/html/sgwi/includes/config.inc.php
%{_localstatedir}/www/html/sgwi/includes/copyright.inc.php
%{_localstatedir}/www/html/sgwi/includes/opt_in_out.inc.php

%changelog
* Sat Sep 22 2018 Shawn Iverson <shawniverson@efa-project.org> - 1.1.9-2
- Include as legacy interface for eFa v4
