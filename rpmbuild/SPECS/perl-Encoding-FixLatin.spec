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

Name:           perl-Encoding-FixLatin
Version:        1.04
Release:        1.eFa%{?dist}
Summary:        takes mixed encoding input and produces UTF-8 output
License:        perl_5
Group:          Development/Libraries
URL:            https://metacpan.org/pod/Encoding::FixLatin
Source0:        https://cpan.metacpan.org/authors/id/G/GR/GRANTM/Encoding-FixLatin-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
Requires:       perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))

%description
Most encoding conversion tools take input in one encoding and produce output in another encoding. This module takes input which may contain characters in more than one encoding and makes a best effort to convert them all to UTF-8 output.

%prep
%setup -q -n Encoding-FixLatin-%{version}

%build
%{__perl} Makefile.PL INSTALLDIRS=vendor
make %{?_smp_mflags}

%install
rm -rf $RPM_BUILD_ROOT

make pure_install PERL_INSTALL_ROOT=$RPM_BUILD_ROOT

find $RPM_BUILD_ROOT -type f -name .packlist -exec rm -f {} \;
find $RPM_BUILD_ROOT -depth -type d -exec rmdir {} 2>/dev/null \;

%{_fixperms} $RPM_BUILD_ROOT/*

# Remove man conflict with perl package
%{__rm} -rf %{buildroot}/%{_mandir}/man3

%check
make test

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
%doc Changes LICENSE README MANIFEST
%{perl_vendorlib}/*
%{_bindir}/*
%{_mandir}/man1/*

%changelog
* Wed Mar 21 2018 Shawn Iverson <shawniverson@efa-project.org> 1.04-1
- Updated for eFa https://efa-project.org

