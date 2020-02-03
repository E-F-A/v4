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

Name:           perl-List-SomeUtils-XS
Version:        0.58
Release:        1.eFa%{?dist}
Summary:        XS implementation for List::SomeUtils
License:        artistic_2
Group:          Development/Libraries
URL:            https://metacpan.org/pod/List::SomeUtils::XS
Source0:        https://cpan.metacpan.org/authors/id/D/DR/DROLSKY/List-SomeUtils-XS-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
Requires:       perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))
BuildRequires:  perl-ExtUtils-MakeMaker >= 6.68
BuildRequires:  perl-Carp >= 1.26
BuildRequires:  perl-Exporter >= 5.68
BuildRequires:  perl(File::Spec) >= 3.40
BuildRequires:  perl(Scalar::Util) >= 1.53
BuildRequires:  perl-Storable >= 1.53
BuildRequires:  perl(Test::Builder::Module) >= 0.98
BuildRequires:  perl-Test-LeakTrace >= 0.14
BuildRequires:  perl(Test::More) >= 0.98
BuildRequires:  perl(Test::Warnings)
BuildRequires:  perl(Tie::Array) >= 1.05
BuildRequires:  perl(base) >= 2.18
BuildRequires:  perl(lib) >= 0.63
BuildRequires:  perl(overload) >= 1.18
Requires:       perl(XSLoader) >= 0.01
Requires:       perl(strict) >= 1.07
Requires:       perl(warnings) >= 1.13

%description
There are no user-facing parts here. See List::SomeUtils for API details.

You shouldn't have to install this module directly. When you install
List::SomeUtils, it checks whether your system has a compiler. If it does, then
it adds a dependency on this module so that it gets installed and you have the
faster XS implementation.

This distribution requires List::SomeUtils but to avoid a circular dependency,
that dependency is explicitly left out from the this distribution's metadata.
However, without LSU already installed this module cannot function.

%prep
%setup -q -n List-SomeUtils-XS-%{version}

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
%doc Changes MANIFEST README.md LICENSE INSTALL
%{perl_vendorarch}/*
%{_mandir}/man3/*

%changelog
* Sun Feb 02 2020 Shawn Iverson <shawniverson@efa-project.org> -  0.58-1
- Built for eFa https://efa-project.org
