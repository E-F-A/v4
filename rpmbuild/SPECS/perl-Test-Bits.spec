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

Name:           perl-Test-Bits
Version:        0.02
Release:        1.eFa%{?dist}
Summary:        Provides a bits_is() subroutine for testing binary data
License:        artistic_2
Group:          Development/Libraries
URL:            https://metacpan.org/pod/Test::Bits
Source0:        https://cpan.metacpan.org/authors/id/D/DR/DROLSKY/Test-Bits-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch:      noarch
Requires:       perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))
BuildRequires:  perl-ExtUtils-MakeMaker >= 6.68
BuildRequires:  perl(File::Find) >= 1.20
BuildRequires:  perl-File-Temp >= 0.23.01
BuildRequires:  perl-Test-Fatal >= 0.010
BuildRequires:  perl(Test::More) >= 0.98
BuildRequires:  perl(Test::Tester) >= 0.109
Requires:       perl-List-AllUtils >= 0.15
Requires:       perl(Scalar::Util) >= 1.27
Requires:       perl(Test::Builder::Module) >= 0.98
Requires:       perl-parent >= 0.225
Requires:       perl(strict) >= 1.07
Requires:       perl(warnings) >= 1.13

%description
his module provides a single subroutine, bits_is(), for testing binary data.

This module is quite similar to Test::BinaryData and Test::HexString in concept.
The difference is that this module shows failure diagnostics in a different way,
and has a slightly different calling style. Depending on the nature of the data
you're working with, this module may be easier to work with.

In particular, when you're doing a lot of bit twiddling, this module's
diagnostic output may make it easier to diagnose failures. A typical failure
diagnostic will look like this:

The two pieces of binary data are not the same length (got 2, expected 3).
Binary data begins differing at byte 1.
  Got:    01111000
  Expect: 01111001

Note that the bytes are numbered starting from 0 in the diagnostic output.

%prep
%setup -q -n Test-Bits-%{version}

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
%doc Changes MANIFEST README LICENSE INSTALL
%{perl_vendorlib}/*
%{_mandir}/man3/*

%changelog
* Sun Feb 02 2020 Shawn Iverson <shawniverson@efa-project.org> - 0.02-1
- Built for eFa https://efa-project.org
