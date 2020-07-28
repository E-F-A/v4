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
%undefine _disable_source_fetch

Name:           perl-MaxMind-DB-Reader
Version:        1.000014
Release:        1.eFa%{?dist}
Summary:        Read MaxMind DB files and look up IP addresses
License:        artistic_2
Group:          Development/Libraries
URL:            https://metacpan.org/pod/MaxMind::DB::Reader
Source0:        https://cpan.metacpan.org/authors/id/M/MA/MAXMIND/MaxMind-DB-Reader-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch:      noarch
Requires:       perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))
BuildRequires:  perl-ExtUtils-MakeMaker >= 6.68
BuildRequires:  perl-Exporter => 5.68
BuildRequires:  perl(File::Spec) => 3.40
BuildRequires:  perl-Path-Class >= 0.33
BuildRequires:  perl(Scalar::Util) => 1.27
BuildRequires:  perl(Test::Bits)
BuildRequires:  perl-Test-Fatal >= 0.010
BuildRequires:  perl(Test::MaxMind::DB::Common::Data) >= 0.040001
BuildRequires:  perl(Test::MaxMind::DB::Common::Util) >= 0.040001
BuildRequires:  perl(Test::More) => 0.98
BuildRequires:  perl-Test-Number-Delta >= 1.06
BuildRequires:  perl-Test-Requires >= 0.06
BuildRequires:  perl(lib) >= 0.63
BuildRequires:  perl(utf8) >= 1.09
Requires:       perl-Carp >= 1.26
Requires:       perl(Data::IEEE754)
Requires:       perl(Data::Validate::IP)
Requires:       perl-DateTime >= 1.04
Requires:       perl-Encode >= 2.51
Requires:       perl-Getopt-Long >= 2.40
Requires:       perl-List-AllUtils >= 0.15
Requires:       perl(Math::BigInt) => 1.998
Requires:       perl-MaxMind-DB-Metadata >= 0.040001
Requires:       perl(MaxMind::DB::Common) >= 0.040001
Requires:       perl(MaxMind::DB::Role::Debugs) >= 0.040001
Requires:       perl(MaxMind::DB::Types) >= 0.040001
Requires:       perl-Module-Implementation >= 0.06
Requires:       perl-Moo >= 2.003006
Requires:       perl(Moo::Role) >= 2.003006
Requires:       perl-MooX-StrictConstructor >= 0.010
Requires:       perl-Role-Tiny => 2.001004
Requires:       perl-Socket >= 2.010
Requires:       perl-autodie >= 2.16
Requires:       perl(bytes) >= 1.04
Requires:       perl-constant => 1.27
Requires:       perl-namespace-autoclean => 0.19
Requires:       perl(strict) >= 1.07
Requires:       perl(warnings) >= 1.13

%description
This module provides a low-level interface to the MaxMind DB file format.

If you are looking for an interface to MaxMind's GeoIP2 or GeoLite2
downloadable databases, you should also check out the GeoIP2 distribution. That
distribution provides a higher level OO interface to those databases.

This API will work with any MaxMind DB databases, regardless of whether it is a
GeoIP2 database or not. In addition, if speed is critical, this API will always
be faster than the GeoIP2 modules, since it returns results as a raw Perl data
structure rather than as an object.

%prep
%setup -q -n MaxMind-DB-Reader-%{version}

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
%doc Changes MANIFEST INSTALL README.md LICENSE
%{perl_vendorlib}/*
%{_bindir}/mmdb-dump-metadata
%{_bindir}/mmdb-dump-search-tree
%{_mandir}/man3/*

%changelog
* Sun Feb 02 2020 Shawn Iverson <shawniverson@efa-project.org> - 1.000014-1
- Built for eFa https://efa-project.org
