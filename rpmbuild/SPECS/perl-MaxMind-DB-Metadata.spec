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

Name:           perl-Maxmind-DB-Metadata
Version:        0.040001
Release:        1.eFa%{?dist}
Summary:        A class for metadata related to a MaxMind DB database
License:        artistic_2
Group:          Development/Libraries
URL:            https://metacpan.org/pod/MaxMind::DB::Metadata
Source0:        https://cpan.metacpan.org/authors/id/M/MA/MAXMIND/MaxMind-DB-Common-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
Requires:       perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))
BuildRequires:  perl-ExtUtils-MakeMaker >= 6.68
BuildRequires:  perl(File::Spec) => 3.40
BuildRequires:  perl(Test::More) => 0.98
Requires:       perl-Carp >= 1.26
Requires:       perl(Data::Dumper::Concise)
Requires:       perl(DateTime)
Requires:       perl-Exporter => 5.68
Requires:       perl(List::AllUtils)
Requires:       perl(Math::BigInt) => 1.998
Requires:       perl(Moo)
Requires:       perl(Moo:Role)
Requires:       perl(MooX::StrictConstructor)
Requires:       perl(Scalar::Util) => 1.27
Requires:       perl(Sub::Quote)
Requires:       perl(autodie)
Requires:       perl-constant => 1.27
Requires:       perl(namespace::autoclean)
Requires:       perl(overload) => 1.18
Requires:       perl(strict) >= 1.07
Requires:       perl(warnings) >= 1.13

%description
This class provides an API for representing the metadata of a MaxMind DB database.
See http://maxmind.github.io/MaxMind-DB/ for the official format spec.

%prep
%setup -q -n MaxMind-DB-Common-%{version}

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
%dir %{perl_vendorlib}/MaxMind
%dir %{perl_vendorlib}/MaxMind/DB
%dir %{perl_vendorlib}/MaxMind/DB/Role
%dir %{perl_vendorlib}/Test
%dir %{perl_vendorlib}/Test/Maxmind
%dir %{perl_vendorlib}/Test/Maxmind/DB
%dir %{perl_vendorlib}/Test/Maxmind/DB/Common
%{perl_vendorlib}/MaxMind/DB/*
%{perl_vendorlib}/MaxMind/DB/Role/*
%{perl_vendorlib}/Test/Maxmind/DB/Common/*
#%{_mandir}/man3

%changelog
* Sat Feb 01 2020 Shawn Iverson <shawniverson@efa-project.org> - 0.040001-1
- Built for eFa https://efa-project.org
