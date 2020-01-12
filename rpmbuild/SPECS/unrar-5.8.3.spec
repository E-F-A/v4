#-----------------------------------------------------------------------------#
# eFa SPEC file definition
#-----------------------------------------------------------------------------#
# Copyright (C) 2013~2020 https://efa-project.org
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
# yum -y install gcc-c++ gcc
#-----------------------------------------------------------------------------#
Summary:    Utility for extracting RAR archives
Name:       unrar
Version:    5.8.3
Release:    1.eFa%{?dist}

License:    Proprietary
Group:      Applications/Archiving
URL:        http://www.rarlab.com/download.htm
Source0:    http://www.rarlab.com/rar/unrarsrc-%{version}.tar.gz

%global debug_package %{nil}

%description
Utility for extracting, and viewing RAR archives

%prep
%setup -q -n %{name}


%build
make %{?_smp_mflags}

%install
mkdir -p %{buildroot}%{_bindir}
mkdir -p %{buildroot}%{_defaultdocdir}/%{name}-%{version}

# Install RAR files
install -pm 755 unrar %{buildroot}%{_bindir}/unrar
install -pm 644 acknow.txt %{buildroot}%{_defaultdocdir}/%{name}-%{version}/acknow.txt
install -pm 644 license.txt %{buildroot}%{_defaultdocdir}/%{name}-%{version}/license.txt
install -pm 644 readme.txt %{buildroot}%{_defaultdocdir}/%{name}-%{version}/readme.txt

%files
%{_bindir}/%{name}

%files -n unrar
%{_bindir}/unrar
%{_defaultdocdir}/%{name}-%{version}/*

%changelog
* Tue Oct 29 2019 darky83 <darky83@efa-project.org> - 5.8.3-1
- Updated build for eFa4 https://efa-project.org (CentOS 7)

* Tue Mar 20 2018 Shawn Iverson <shawniverson@efa-project.org> - 5.6.1-1
- Updated build for eFa4 https://efa-project.org (CentOS 7)

* Sun Jan 15 2017 eFa Project - 5.4.5-1
- Updated build for eFa4 (CentOS 7)

* Wed Jun 17 2015 eFa Project - 5.2.7-1
- initial build for CentOS & eFa Project
