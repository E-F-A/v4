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

Name:           perl-List-AllUtils
Version:        0.15
Release:        1.eFa%{?dist}
Summary:        Combines List::Util, List::SomeUtils and List::UtilsBy in one bite-sized package
License:        perl_5
Group:          Development/Libraries
URL:            https://metacpan.org/pod/List::AllUtils
Source0:        https://cpan.metacpan.org/authors/id/D/DR/DROLSKY/List-AllUtils-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch:      noarch
Requires:       perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))
BuildRequires:  perl(Test::More) => 0.98
BuildRequires:  perl-ExtUtils-MakeMaker >= 6.68
BuildRequires:  perl(File::Spec) >= 3.40
BuildRequires:  perl(Sub::Util)
BuildRequires:  perl(Test::More) >= 0.98
Requires:       perl-Exporter => 5.68
Requires:       perl(List::SomeUtils)
Requires:       perl(List::Util) >= 1.27
Requires:       perl(List::UtilsBy)

%description
Are you sick of trying to remember whether a particular helper is defined in List::Util, List::SomeUtils or List::UtilsBy? I sure am. Now you don't have to remember. This module will export all of the functions that either of those three modules defines.

Note that all function documentation has been shamelessly copied from List::Util, List::SomeUtils and List::UtilsBy.

%prep
%setup -q -n List-AllUtils-%{version}

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
* Sat Feb 01 2020 Shawn Iverson <shawniverson@efa-project.org> -  0.15-1
- Built for eFa https://efa-project.org
