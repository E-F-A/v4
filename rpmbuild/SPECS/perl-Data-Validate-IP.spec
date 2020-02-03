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

Name:           perl-Data-Validate-IP
Version:        0.27
Release:        1.eFa%{?dist}
Summary:        IPv4 and IPv6 validation methods
License:        perl_5
Group:          Development/Libraries
URL:            https://metacpan.org/pod/Data::Validate::IP
Source0:        https://cpan.metacpan.org/authors/id/D/DR/DROLSKY/Data-Validate-IP-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
Requires:       perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))
BuildRequires:  perl-ExtUtils-MakeMaker >= 6.68
BuildRequires:  perl(File::Spec) >= 3.40
BuildRequires:  perl(Test::More) >= 0.98
BuildRequires:  perl(Test::Requires) >= 0.06
BuildRequires:  perl(lib) >= 0.63
Requires:       perl-Exporter >= 5.68
Requires:       perl-NetAddr-IP >= 4.069
Requires:       perl(Scalar::Util) >= 1.53
Requires:       perl(base) >= 2.18
Requires:       perl(strict) >= 1.07
Requires:       perl(warnings) >= 1.13

%description
This module provides a number IP address validation subs that both validate and
untaint their input. This includes both basic validation (is_ipv4() and
is_ipv6()) and special cases like checking whether an address belongs to a
specific network or whether an address is public or private (reserved).

%prep
%setup -q -n Data-Validate-IP-%{version}

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
%doc Changes MANIFEST README.md INSTALL LICENSE
%{perl_vendorlib}/*
%{_mandir}/man3/*

%changelog
* Sun Feb 02 2020 Shawn Iverson <shawniverson@efa-project.org> - 0.27-1
- Built for eFa https://efa-project.org
