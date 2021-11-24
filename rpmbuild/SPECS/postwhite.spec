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
Summary:       Postwhite Automatic Postscreen Whitelist & Blacklist Generator
Name:          postwhite
Version:       3.4
Release:       1.eFa%{?dist}
License:       MIT License
Group:         Applications/Utilities
URL:           https://github.com/stevejenkins/postwhite
Source:        https://github.com/stevejenkins/postwhite/archive/refs/tags/v%{version}.tar.gz
BuildRoot:     %{_tmppath}/%{name}-%{version}-%{release}-root
BuildArch:     noarch


%description
Postwhite - Automatic Postcreen Whitelist & Blacklist Generator

%prep
%setup -q -n %{name}-%{version}

%build
# Nothing to do

%install
%{__rm} -rf %{buildroot}

# Copy files to proper locations
mkdir -p %{buildroot}%{_sysconfdir}
mkdir -p %{buildroot}%{_bindir}
cp -a postwhite.conf %{buildroot}%{_sysconfdir}
cp -a postwhite %{buildroot}%{_bindir}
cp -a scrape_yahoo %{buildroot}%{_bindir}
cp -a query_mailer_ovh %{buildroot}%{_bindir}

%pre
# Nothing to do

%post
# Nothing to do

%clean
%{__rm} -rf %{buildroot}

%files
%defattr(-, root, root)
%doc README.md LICENSE.md examples/*
%attr(0755, root, root) %{_bindir}/*
%config(noreplace) %{_sysconfdir}/postwhite.conf

%changelog
* Tue Nov 23 2021 Shawn Iverson <shawniverson@efa-project.org> - 3.4-1
- Initial build for eFa