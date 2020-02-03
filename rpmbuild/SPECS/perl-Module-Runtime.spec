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

Name:           perl-Module-Runtime
Version:        0.016
Release:        1.eFa%{?dist}
Summary:        Module::Runtime - runtime module handling
License:        perl_5
Group:          Development/Libraries
URL:            https://metacpan.org/pod/Module::Runtime
Source0:        https://cpan.metacpan.org/authors/id/Z/ZE/ZEFRAM/Module-Runtime-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
Requires:       perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))
BuildRequires:  perl-ExtUtils-MakeMaker >= 6.68
BuildRequires:  perl(Test::More) => 0.98
BuildRequires:  perl(strict) >= 1.07
BuildRequires:  perl(warnings) >= 1.13
BuildRequires:  perl-Module-Build >= 0.40.05

%description
The functions exported by this module deal with runtime handling of Perl
modules, which are normally handled at compile time. This module avoids using
any other modules, so that it can be used in low-level infrastructure.

The parts of this module that work with module names apply the same syntax that
is used for barewords in Perl source. In principle this syntax can vary between
versions of Perl, and this module applies the syntax of the Perl on which it is
running. In practice the usable syntax hasn't changed yet. There's some intent
for Unicode module names to be supported in the future, but this hasn't yet
amounted to any consistent facility.

The functions of this module whose purpose is to load modules include
workarounds for three old Perl core bugs regarding require. These workarounds
are applied on any Perl version where the bugs exist, except for a case where
one of the bugs cannot be adequately worked around in pure Perl.

%prep
%setup -q -n Module-Runtime-%{version}

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
%doc Changes MANIFEST README SIGNATURE
%{perl_vendorlib}/*
%{_mandir}/man3/*

%changelog
* Sat Feb 01 2020 Shawn Iverson <shawniverson@efa-project.org> - 2.003006-1
- Built for eFa https://efa-project.org
