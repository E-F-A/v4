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

# dcc fails to generate debuginfo packages on CentOS 8
%global debug_package %{nil} 

#-----------------------------------------------------------------------------#
# Required packages for building this RPM
#-----------------------------------------------------------------------------#
# yum -y install sendmail-devel
#-----------------------------------------------------------------------------#
Name:      dcc-ena
Summary:   DCC Distributed Checksum Clearinghouse
Version:   2.3.167
Release:   2.eFa%{?dist}
Epoch:     1
Group:     System Environment/Daemons
URL:       https://www.rhyolite.com/dcc
License:   Copyright (c) 2014 by Rhyolite Software, LLC
Source0:   dcc-%{version}.tar.gz
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
Requires: postfix >= 3.1.3
Requires: spamassassin-ena >= 3.4.6
Requires: MailScanner-ena >= 5.0.4-3

%description
The DCC or Distributed Checksum Clearinghouse is an anti-spam content filter
that runs on a variety of operating systems. The idea of the DCC is that if
mail recipients could compare the mail they receive, they could recognize
unsolicited bulk mail. A DCC server totals reports of "fuzzy" checksums of
messages from clients and answers queries about the total counts for checksums
of mail messages.

%prep
%setup -q dcc-%{version}

%build
./configure --disable-dccm --with-installroot=$RPM_BUILD_ROOT --mandir=/usr/share/man --bindir=/usr/bin

make %{?_smp_mflags}

%install
rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT

make install

%preun

%postun

%post

%clean
rm -rf $RPM_BUILD_ROOT

%files
%doc CHANGES LICENSE
%defattr(-, root, root, -)
%{_bindir}/*
%{_mandir}/man8/*
%attr(-, postfix, postfix) %{_localstatedir}/dcc


%changelog
* Sun Jul 8 2018 darky83 <darky83@efa-project.org> - 2.3.167-1
- Updated for eFa https://efa-project.org

* Sun Jul 8 2018 shawniverson <shawniverson@efa-project.org> - 1.3.163-1
- Update requirements for postfix_eFa

* Tue Mar 20 2018 shawniverson <shawniverson@efa-project.org> - 1.3.163-1
- Updated for eFa https://efa-project.org

* Sat Nov 11 2017 darky83 <darky83@efa-project.org> - 1.3.159-1
- Updated for eFa https://efa-project.org

* Sun Jan 22 2017 Shawn Iverson <shawniverson@gmail.com> - 1.3.158-1
- Initial Build for eFa v4 on CentOS7 <https://efa-project.org>
