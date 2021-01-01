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

#-----------------------------------------------------------------------------#
# Required packages for building this RPM
#-----------------------------------------------------------------------------#
# yum -y install
#-----------------------------------------------------------------------------#
%define perl_vendorlib %(eval "`%{__perl} -V:installvendorlib`"; echo $installvendorlib)
%define perl_vendorarch %(eval "`%{__perl} -V:installvendorarch`"; echo $installvendorarch)
%undefine _disable_source_fetch


Name:           perl-IP-Country
Version:        2.28
Release:        1.eFa%{?dist}
Summary:        fast lookup of country codes from IP addresses
License:        GPL+ or Artistic
Group:          Development/Libraries
URL:            https://metacpan.org/pod/IP::Country
Source0:        https://cpan.metacpan.org/authors/id/N/NW/NWETTERS/IP-Country-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch:      noarch
BuildRequires:  perl(Test)
Requires:       perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))
Requires:       perl(Geography::Countries)
Requires:       perl(Socket)
Requires:       perl(Exporter)
Requires:       perl(Carp)

%description
Finding the home country of a client using only the IP address can be difficult.
Looking up the domain name associated with that address can provide some help,
but many IP address are not reverse mapped to any useful domain,
and the most common domain (.com) offers no help when looking for country.

This module comes bundled with a database of countries where various IP addresses have been assigned.
Although the country of assignment will probably be the country associated with a large ISP rather than the client herself,
this is probably good enough for most log analysis applications,
and under test has proved to be as accurate as reverse-DNS and WHOIS lookup.

%prep
%setup -q -n IP-Country-%{version}

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

# Remove man conflict with perl package
#%{__rm} -rf %{buildroot}/%{_mandir}/man3

%{_fixperms} %{buildroot}/*

%check
%{__make} test

%clean
%{__rm} -rf %{buildroot}

%files
%defattr(-,root,root,-)
%doc CHANGES MANIFEST INSTALL README
%{perl_vendorlib}/*
%{_mandir}/man1/ip2cc.1.gz
%{_mandir}/man3/*.3pm*
/usr/bin/ip2cc


%changelog
* Sun Aug 28 2016 Shawn Iverson <shawniverson@gmail.com> - 2.28-1
- Built for eFa https://efa-project.org
