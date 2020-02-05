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

Name:           perl-MaxMind-DB-Reader-XS
Version:        1.000008
Release:        1.eFa%{?dist}
Summary:        Fast XS implementation of MaxMind DB reader
License:        artistic_2
Group:          Development/Libraries
URL:            https://metacpan.org/pod/MaxMind::DB::Reader::XS
Source0:        https://cpan.metacpan.org/authors/id/M/MA/MAXMIND/MaxMind-DB-Reader-XS-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
Requires:       perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))
BuildRequires:  perl-ExtUtils-MakeMaker >= 6.68
BuildRequires:  perl(File::Spec) => 3.40
BuildRequires:  perl-MaxMind-DB-Reader >= 1.000014
BuildRequires:  perl-Module-Build >= 0.40.05
BuildRequires:  perl-Module-Implementation >= 0.06
BuildRequires:  perl(Net::Works::Network) >= 0.21
BuildRequires:  perl-Path-Class >= 0.33
BuildRequires:  perl-Test-Fatal >= 0.010
BuildRequires:  perl(Test::MaxMind::DB::Common::Util) >= 0.040001
BuildRequires:  perl(Test::More) => 0.98
BuildRequires:  perl-Test-Number-Delta >= 1.06
BuildRequires:  perl-Test-Requires >= 0.06
BuildRequires:  perl-autodie >= 2.16
BuildRequires:  perl(lib) >= 0.63
BuildRequires:  perl(utf8) >= 1.09
BuildRequires:  perl(version) >= 0.9907
BuildRequires:  libmaxminddb-devel >= 1.2.0
Requires:       perl(Math::Int128)
Requires:       perl-Math-Int64 >= 0.52
Requires:       perl-MaxMind-DB-Metadata >= 0.040001
Requires:       perl(MaxMind::DB::Reader::Role::HasMetadata) >= 1.000014
Requires:       perl(MaxMind::DB::Types) >= 0.040001
Requires:       perl-Moo >= 2.003006
Requires:       perl(XSLoader) >= 0.01
Requires:       perl-namespace-autoclean => 0.19
Requires:       perl(strict) >= 1.07
Requires:       perl(warnings) >= 1.13

%description
Simply installing this module causes MaxMind::DB::Reader to use the XS
implementation, which is much faster than the Perl implementation.

The XS implementation links against the libmaxminddb library.

See MaxMind::DB::Reader for API details.

%prep
%setup -q -n MaxMind-DB-Reader-XS-%{version}

%build
%{__perl} Build.PL installdirs="vendor" destdir="%{buildroot}%{_prefix}"
%{__perl} Build 
%{__perl} Build test

%install
%{__rm} -rf %{buildroot}
%{__perl} Build install

### Clean up buildroot
find %{buildroot} -name .packlist -exec %{__rm} {} \;
find %{buildroot} -name perllocal.pod -exec %{__rm} {} \;
find %{buildroot} -depth -type d -exec rmdir {} 2>/dev/null \;

# Remove man conflict with perl package
#%{__rm} -rf %{buildroot}/%{_mandir}/man3

%{_fixperms} %{buildroot}/*

%clean
%{__rm} -rf %{buildroot}

%files
%defattr(-,root,root,-)
%doc Changes MANIFEST INSTALL README.md LICENSE
%{perl_vendorarch}/*
%{_mandir}/man3/*

%changelog
* Mon Feb 03 2020 Shawn Iverson <shawniverson@efa-project.org> - 1.000008-1
- Built for eFa https://efa-project.org
