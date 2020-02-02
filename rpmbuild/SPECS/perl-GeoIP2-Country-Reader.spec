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

Name:           perl-GeoIP2-Country-Reader
Version:        2.006002
Release:        1.eFa%{?dist}
Summary:        fast lookup of country codes from IP addresses
License:        perl_5
Group:          Development/Libraries
URL:            https://metacpan.org/pod/GeoIP2::Database::Reader
Source0:        https://cpan.metacpan.org/authors/id/M/MA/MAXMIND/GeoIP2-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
Requires:       perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))
BuildRequires:  perl-ExtUtils-MakeMaker >= 6.68
BuildRequires:  perl-PathTools >= 3.40
BuildRequires:  perl(HTTP::Response) >= 6.04
BuildRequires:  perl(HTTP::Status) >= 6.03
BuildRequires:  perl-IO-Compress >= 2.061
BuildRequires:  perl-MaxMind-DB-Metadata >= 0.040001
BuildRequires:  perl-Path-Class >= 0.33
BuildRequires:  perl(Test::Builder) >= 0.98
BuildRequires:  perl-Test-Fatal >= 0.010
BuildRequires:  perl(Test::More) >= 0.98
BuildRequires:  perl-Test-Number-Delta >= 1.06
BuildRequires:  perl(base) >= 2.18
BuildRequires:  perl(utf8) >= 1.09
Requires:       perl-ExtUtils-MakeMaker >= 6.68
Requires:       perl(B) >= 1.35
Requires:       perl-Data-Dumper >= 2.145
Requires:       perl(Data::Validate::IP) >= 0.25
Requires:       perl-Exporter >= 5.68
Requires:       perl-Getopt-Long >= 2.40
Requires:       perl(HTTP::Headers) >= 6.05
Requires:       perl(HTTP::Request) >= 6.00
Requires:       perl(JSON::MaybeXS)
Requires:       perl-LWP-Protocol-https >= 6.04
Requires:       perl(LWP::UserAgent) >= 6.05
Requires:       perl-List-SomeUtils >= 0.58
Requires:       perl(List::Util) >= 1.53
Requires:       perl(MIME::Base64) >= 3.15
Requires:       perl(MaxMind::DB::Reader) >= 1.000000
Requires:       perl-Moo >= 2.003006
Requires:       perl(Moo::Role) >= 2.003006
Requires:       perl-Params-Validate >= 1.08
Requires:       perl(Scalar::Util) >= 1.53
Requires:       perl-Sub-Quote >= 2.006006
Requires:       perl(Throwable::Error)
Requires:       perl-Try-Tiny >= 0.12
Requires:       perl-URI >= 1.60
Requires:       perl(lib) >= 0.63
Requires:       perl-namespace-clean >= 0.24
Requires:       perl(strict) >= 1.07
Requires:       perl(warnings) >= 1.13

%description
This class provides a reader API for all GeoIP2 databases. Each method returns a different model class.

If the database does not return a particular piece of data for an IP address, the associated attribute is not populated.

%prep
%setup -q -n GeoIP2-%{version}

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
%doc Changes MANIFEST INSTALL README LICENSE
%{perl_vendorlib}/*
%dir %{perl_vendorlib}/GeoIP2
%{perl_vendorlib}/GeoIP2/*
%dir %{perl_vendorlib}/GeoIP2/Database
%dir %{perl_vendorlib}/GeoIP2/Error
%dir %{perl_vendorlib}/GeoIP2/Model
%dir %{perl_vendorlib}/GeoIP2/Record
%dir %{perl_vendorlib}/GeoIP2/Role
%dir %{perl_vendorlib}/GeoIP2/Role/Error
%dir %{perl_vendorlib}/GeoIP2/Role/Model
%dir %{perl_vendorlib}/GeoIP2/Role/Record
%dir %{perl_vendorlib}/GeoIP2/WebService
%{perl_vendorlib}/GeoIP2/Database/*
%{perl_vendorlib}/GeoIP2/Error/*
%{perl_vendorlib}/GeoIP2/Model/*
%{perl_vendorlib}/GeoIP2/Record/*
%{perl_vendorlib}/GeoIP2/Role/*
%{perl_vendorlib}/GeoIP2/Role/Error/*
%{perl_vendorlib}/GeoIP2/Role/Model/*
%{perl_vendorlib}/GeoIP2/Role/Record/*
%{perl_vendorlib}/GeoIP2/WebService/*
#%{_mandir}/man3
/usr/bin/web-service-request

%changelog
* Sat Feb 01 2020 Shawn Iverson <shawniverson@efa-project.org> - 2.006002-1
- Built for eFa https://efa-project.org
