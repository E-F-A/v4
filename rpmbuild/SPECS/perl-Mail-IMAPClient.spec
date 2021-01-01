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
Name:           perl-Mail-IMAPClient
Version:        3.42
Release:        1.eFa%{?dist}
Summary:        An IMAP Client API
License:        perl_5
Group:          Development/Libraries
URL:            https://metacpan.org/pod/distribution/Mail-IMAPClient
Source:         https://cpan.metacpan.org/authors/id/P/PL/PLOBBES/Mail-IMAPClient-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch:      noarch
Requires:       perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))

%description
This module provides methods implementing the IMAP protocol to support interacting
with IMAP message stores.

The module is used by constructing or instantiating a new IMAPClient object via the
"new" constructor method. Once the object has been instantiated, the "connect" method
is either implicitly or explicitly called. At that point methods are available that
implement the IMAP client commands as specified in RFC3501. When processing is complete, 
the "logout" object method should be called.

This documentation is not meant to be a replacement for RFC3501 nor any other
IMAP related RFCs.

Note that this documentation uses the term folder in place of RFC3501's use of mailbox.
This documentation reserves the use of the term mailbox to refer to the set of folders
owned by a specific IMAP id.

%prep
%setup -q -n Mail-IMAPClient-%{version}

%build
%{__perl} Makefile.PL INSTALLDIRS="vendor" PREFIX="%{buildroot}%{_prefix}"
%{__make} %{?_smp_mflags}

%install
%{__rm} -rf %{buildroot}
%{__make} install

### Clean up buildroot
find %{buildroot} -name .packlist -exec %{__rm} {} \;
find %{buildroot} -name perllocal.pod -exec %{__rm} {} \;
find %{buildroot} -depth -type d -exec rmdir {} 2>/dev/null \;

%{_fixperms} %{buildroot}/*

%check
%{__make} test

%clean
%{__rm} -rf %{buildroot}

%files
%defattr(-,root,root,-)
%doc Changes README MANIFEST
%{perl_vendorlib}/*
%{_mandir}/man3/*

%changelog
* Sun Aug 02 2020 Shawn Iverson <shawniverson@efa-project.org> - 3.42
- Build for eFa https://efa-project.org
