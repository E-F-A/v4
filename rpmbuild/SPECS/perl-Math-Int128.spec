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

Name:           perl-Math-Int128
Version:        0.22
Release:        1.eFa%{?dist}
Summary:        Manipulate 128 bits integers in Perl
License:        perl_5
Group:          Development/Libraries
URL:            https://metacpan.org/pod/Math::Int128
Source0:        https://cpan.metacpan.org/authors/id/S/SA/SALVA/Math-Int128-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
Requires:       perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))
BuildRequires:  perl-ExtUtils-MakeMaker >= 6.68
BuildRequires:  perl(B) >= 1.35
BuildRequires:  perl(File::Spec) => 3.40
BuildRequires:  perl(Math::BigInt) >= 1.998
BuildRequires:  perl-Test-Fatal >= 0.010
BuildRequires:  perl(Test::More) => 0.98
Requires:       perl-Carp >= 1.26
Requires:       perl-Exporter >= 5.68
Requires:       perl-List-AllUtils >= 0.15
Requires:       perl(Math::Int128)
Requires:       perl-Moo >= 2.003006
Requires:       perl(Moo::Role) >= 2.003006
Requires:       perl(Scalar::Util) >= 1.53
Requires:       perl-Socket >= 2.010
Requires:       perl-Sub-Quote >= 2.006006
Requires:       perl(integer) >= 1.00
Requires:       perl-namespace-autoclean >= 0.19
Requires:       perl(overload) >= 1.18
Requires:       perl(strict) >= 1.07
Requires:       perl(warnings) >= 1.13

%description
This module adds support for 128 bit integers, signed and unsigned, to Perl.

In order to compile this module, your compiler must support one of either the
__int128 or int __attribute__ ((__mode__ (TI))) types. Both GCC and Clang have
supported one or the other type for some time, but they may only do so on
64-bit platforms.

%prep
%setup -q -n Math-Int128-%{version}

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

%clean
%{__rm} -rf %{buildroot}

%files
%defattr(-,root,root,-)
%doc Changes MANIFEST INSTALL README.md
%{perl_vendorlib}/*
%{_mandir}/man3/*

%changelog
* Tue Feb 04 2020 Shawn Iverson <shawniverson@efa-project.org> - 0.22-1
- Built for eFa https://efa-project.org
