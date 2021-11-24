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

%undefine _disable_source_fetch

#-----------------------------------------------------------------------------#
# Required packages for building this RPM
#-----------------------------------------------------------------------------#
# yum -y install 
#-----------------------------------------------------------------------------#
Summary:       spf-tools - simple tools for keeping the SPF TXT records tidy
Name:          spf-tools
Version:       2.1
Release:       1.eFa%{?dist}
License:       Apache License 2.0
Group:         Applications/Utilities
URL:           https://github.com/spf-tools/spf-tools/
Source:        https://github.com/spf-tools/spf-tools/archive/refs/tags/v%{version}.tar.gz
BuildRoot:     %{_tmppath}/%{name}-%{version}-%{release}-root
BuildArch:     noarch


%description
Simple tools for keeping the SPF TXT records tidy in order to fight 10 maximum DNS look-ups.

%prep
%setup -q -n %{name}-%{version}

%build
# Nothing to do

%install
%{__rm} -rf %{buildroot}

# Copy files to proper locations
mkdir -p %{buildroot}%{_bindir}/include
cp -a *sh %{buildroot}%{_bindir}
cp -a include/* %{buildroot}%{_bindir}/include
mkdir -p 

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
%doc README.md LICENSE AUTHORS
%{_bindir}/*

%changelog
* Tue Nov 23 2021 Shawn Iverson <shawniverson@efa-project.org> - 2.1-1
- Initial Build for eFa