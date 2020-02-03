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

Name:           perl-List-SomeUtils
Version:        0.58
Release:        1.eFa%{?dist}
Summary:        Provide the stuff missing in List::Util
License:        perl_5
Group:          Development/Libraries
URL:            https://metacpan.org/pod/List::SomeUtils
Source0:        https://cpan.metacpan.org/authors/id/D/DR/DROLSKY/List-SomeUtils-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
Requires:       perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))
BuildRequires:  perl-ExtUtils-MakeMaker >= 6.68
BuildRequires:  perl(File::Spec) >= 3.40
BuildRequires:  perl(Scalar::Util) >= 1.53
BuildRequires:  perl-Storable >= 1.53
BuildRequires:  perl(Test::Builder::Module) >= 0.98
BuildRequires:  perl-Test-LeakTrace >= 0.14
BuildRequires:  perl(Test::More) >= 0.98
BuildRequires:  perl(Tie::Array) >= 1.05
BuildRequires:  perl(base) >= 2.18
BuildRequires:  perl(lib) >= 0.63
BuildRequires:  perl(overload) >= 1.18
BuildRequires:  perl-Text-ParseWords >= 3.29
Requires:       perl-Carp >= 1.26
Requires:       perl-Exporter >= 5.68
Requires:       perl(List::Util) >= 1.53
Requires:       perl-Module-Implementation >= 0.06
Requires:       perl(strict) >= 1.07
Requires:       perl(vars) >= 1.02
Requires:       perl(warnings) >= 1.13

%description
List::SomeUtils provides some trivial but commonly needed functionality on
lists which is not going to go into List::Util.

All of the below functions are implementable in only a couple of lines of Perl
code. Using the functions from this module however should give slightly better
performance as everything is implemented in C. The pure-Perl implementation of
these functions only serves as a fallback in case the C portions of this module
couldn't be compiled on this machine.

%prep
%setup -q -n List-SomeUtils-%{version}

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
%doc Changes MANIFEST README.md LICENSE
%{perl_vendorlib}/*
%{_mandir}/man3/*

%changelog
* Sat Feb 01 2020 Shawn Iverson <shawniverson@efa-project.org> -  0.58-1
- Built for eFa https://efa-project.org
