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
# yum -y install
#-----------------------------------------------------------------------------#
%define perl_vendorlib %(eval "`%{__perl} -V:installvendorlib`"; echo $installvendorlib)
%define perl_vendorarch %(eval "`%{__perl} -V:installvendorarch`"; echo $installvendorarch)

Name:           perl-IP-Country-DB_File
Version:        3.03
Release:        1.eFa%{?dist}
Summary:        IPv4 and IPv6 to country translation using DB_File
License:        perl_5
Group:          Development/Libraries
URL:            https://metacpan.org/pod/IP::Country::DB_File
Source0:        https://cpan.metacpan.org/authors/id/N/NW/NWELLNHOF/IP-Country-DB_File-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildRequires:  perl-ExtUtils-MakeMaker >= 6.68
BuildRequires:  perl-Math-Int64 >= 0.52
Requires:       perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))
Requires:       perl-DB_File >= 1.830
Requires:       perl-Math-Int64 >= 0.52
Requires:       perl(Net::FTP) >= 3.11
Requires:       perl-Socket >= 2.010

%description
IP::Country::DB_File is a light-weight module for fast IP address to country translation based on DB_File. The country code database is stored in a Berkeley DB file. You have to build the database using build_ipcc.pl or IP::Country::DB_File::Builder before you can lookup country codes.

This module tries to be API compatible with the other IP::Country modules. The installation of IP::Country is not required.

There are many other modules for locating IP addresses. Neil Bowers posted an excellent review. Some features that make this module unique:
    IPv6 support.
    Pure Perl. Math::Int64 is needed to build a database with IPv6 addresses but the lookup code only uses Perl core modules.
    Reasonably fast and accurate.
    Builds the database directly from the statistics files of the regional internet registries. No third-party tie-in.


%prep
%setup -q -n IP-Country-DB_File-%{version}

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
%doc Changes MANIFEST LICENSE README
%dir %{perl_vendorlib}/*
%{_mandir}/man1/build_ipcc.pl.1.gz
%{_mandir}/man3/*.3pm*
/usr/bin/build_ipcc.pl

%changelog
* Sat Feb 01 2020 Shawn Iverson <shawniverson@efa-project.org> - 3.03-1
- Built for eFa https://efa-project.org
