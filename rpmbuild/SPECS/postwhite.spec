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
Release:       2.eFa%{?dist}
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
mkdir -p %{buildroot}%{_sysconfdir}/cron.d
mkdir -p %{buildroot}%{_bindir}
mkdir -p %{buildroot}%{_datarootdir}/postwhite
cp -a postwhite.conf %{buildroot}%{_sysconfdir}
cp -a {postwhite,scrape_yahoo,query_mailer_ovh} %{buildroot}%{_bindir}
cp -a yahoo_static_hosts.txt %{buildroot}%{_datarootdir}/postwhite

sed -i "/^spftoolspath=/ c\spftoolspath=/usr/bin" %{buildroot}%{_sysconfdir}/postwhite.conf
sed -i "/^yahoo_static_hosts=/ c\yahoo_static_hosts=/usr/share/postwhite" %{buildroot}%{_sysconfdir}/postwhite.conf

cat > %{buildroot}%{_sysconfdir}/cron.d/postwhite << 'EOF'
@daily /usr/bin/postwhite >/dev/null 2>&1 #Update Postscreen Whitelists
@weekly /usr/bin/scrape_yahoo >/dev/null 2>&1 #Update Yahoo! IPs for Postscreen Whitelists
EOF

%pre
# Nothing to do

%post
echo ""
echo "To enable postwhite, add the following to your /etc/postfix/main.cf:
echo ""
echo "postscreen_access_list = permit_mynetworks,"
echo "..."
echo "        cidr:/etc/postfix/postscreen_spf_whitelist.cidr,"
echo "..."
echo ""

%clean
%{__rm} -rf %{buildroot}

%files
%defattr(-, root, root)
%doc README.md LICENSE.md examples/*
%attr(0755, root, root) %{_bindir}/*
%config(noreplace) %{_sysconfdir}/postwhite.conf
%{_datarootdir}/postwhite/yahoo_static_hosts.txt
%{_sysconfdir}/cron.d/postwhite

%changelog
* Wed Nov 24 2021 Shawn Iverson <shawniverson@efa-project.org> - 3.4-2
- Adjust paths in postwhite.conf, add yahoo_static_hosts.txt, add cron

* Tue Nov 23 2021 Shawn Iverson <shawniverson@efa-project.org> - 3.4-1
- Initial build for eFa