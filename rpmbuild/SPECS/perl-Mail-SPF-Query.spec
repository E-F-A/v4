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
Name:           perl-Mail-SPF-Query
Version:        1.999.1
Release:        1.eFa%{?dist}
Summary:        Object-oriented implementation of Sender Policy Framework
License:        GPL2+ or Artistic
Group:          Development/Libraries
URL:            http://search.cpan.org/dist/Mail-SPF-Query/
Source0:        https://cpan.metacpan.org/authors/id/J/JM/JMEHNLE/mail-spf-query/Mail-SPF-Query-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch:      noarch
Requires:       perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))
Requires:       perl(Net::CIDR::Lite) >= 0.21
Requires:       perl(Net::DNS) >= 0.72
Requires:       perl(Sys::Hostname::Long) >= 1.5
Requires:       perl(Socket) >= 2.010
Requires:       perl(Getopt::Long) >= 2.40
BuildRequires:  perl(Sys::Hostname::Long) >= 1.5
BuildRequires:  perl(Net::DNS) >= 0.72
BuildRequires:  perl(Net::CIDR::Lite) >= 0.21
BuildRequires:  perl(URI) >= 1.60

%description
The SPF protocol relies on sender domains to describe their designated outbound mailers in DNS.
Given an email address, Mail::SPF::Query determines the legitimacy of an SMTP client IP address.

%prep
%setup -q -n Mail-SPF-Query-%{version}

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
# Tests failing to no longer existant DNS records
#%{__make} test

%clean
%{__rm} -rf %{buildroot}

%files
%defattr(-,root,root,-)
%doc CHANGES README MANIFEST
%{perl_vendorlib}/*
%{_mandir}/man1/*
%{_mandir}/man3/*
/usr/bin/*

%changelog
* Sun Jan 15 2017 Shawn Iverson <shawniverson@gmail.com> - 1.999.1-1
- Created for eFa https://efa-project.org
