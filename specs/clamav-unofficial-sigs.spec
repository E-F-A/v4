#-----------------------------------------------------------------------------#
# eFa SPEC file definition
#-----------------------------------------------------------------------------#
# Copyright (C) 2013~2017 https://efa-project.org
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
Summary:       clamav-unofficial-sigs Maintained and provided by https://eXtremeSHOK.com
Name:          clamav-unofficial-sigs
Version:       5.4.1
Epoch:         1
Release:       1.eFa%{?dist}
License:       Copyright (c) Adrian Jon Kriel admin@extremeshok.com
Group:         Applications/Utilities
URL:           https://github.com/extremeshok/clamav-unofficial-sigs
Source:        %{name}-%{version}.tar.gz
BuildRoot:     %{_tmppath}/%{name}-%{version}-%{release}-root
Requires:      clamav >= 0.99

%description
The clamav-unofficial-sigs script provides a simple way to download, test, and update third-party
signature databases provided by Sanesecurity, FOXHOLE, OITC, Scamnailer, BOFHLAND, CRDF,
Porcupine, Securiteinfo, MalwarePatrol, Yara-Rules Project, etc.
The script will also generate and install cron, logrotate, and man files.

%prep
%setup -q -n %{name}-%{version}

%build
# Nothing to do

%install
%{__rm} -rf %{buildroot}

mkdir -p %{buildroot}/usr/bin
mkdir %{buildroot}/etc
cp clamav-unofficial-sigs.sh %{buildroot}/usr/bin
mkdir %{buildroot}/etc/clamav-unofficial-sigs
cp config/master.conf %{buildroot}/etc/clamav-unofficial-sigs
cp config/os.centos7.conf %{buildroot}/etc/clamav-unofficial-sigs/os.conf
cp config/user.conf %{buildroot}/etc/clamav-unofficial-sigs
mkdir -p %{buildroot}/var/log/clamav-unofficial-sigs

%pre
# Nothing to do

%post
/usr/bin/clamav-unofficial-sigs.sh --install-cron
/usr/bin/clamav-unofficial-sigs.sh --install-logrotate
/usr/bin/clamav-unofficial-sigs.sh --install-man

%clean
%{__rm} -rf %{buildroot}

%files
%defattr(-, root, root)
%doc INSTALL LICENSE README.md 
%attr(0755, root, root) %{_bindir}/clamav-unofficial-sigs.sh
%dir %{_sysconfdir}/clamav-unofficial-sigs/
%config(noreplace) %{_sysconfdir}/clamav-unofficial-sigs/*
%dir %{_var}/log/clamav-unofficial-sigs/

%changelog
* Sun Aug 21 2016 Shawn Iverson <shawniverson@gmail.com> - 5.4.1-1
- Updated for eFa https://efa-project.org

* Sat Jun 11 2016 Shawn Iverson <shawniverson@gmail.com> - 5.3.2-1
- Updated for eFa https://efa-project.org

* Sun May 22 2016 Shawn Iverson <shawniverson@gmail.com> - 5.3.1-1
- Created for eFa https://efa-project.org
