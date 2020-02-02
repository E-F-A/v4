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

Name:           perl-Scalar-List-Utils
Version:        1.53
Release:        1.eFa%{?dist}
Summary:        A selection of utility subroutines for subs and CODE references
License:        perl_5
Group:          Development/Libraries
URL:            https://metacpan.org/pod/Sub::Util
Source0:        https://cpan.metacpan.org/authors/id/P/PE/PEVANS/Scalar-List-Utils-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
Requires:       perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))
BuildRequires:  perl-ExtUtils-MakeMaker >= 6.68
Requires:       perl(Test::More) >= 0.98

%description
Sub::Util contains a selection of utility subroutines that are useful for
operating on subs and CODE references.

The rationale for inclusion in this module is that the function performs some
work for which an XS implementation is essential because it cannot be
implemented in Pure Perl, and which is sufficiently-widely used across CPAN
that its popularity warrants inclusion in a core module, which this is.

%prep
%setup -q -n Scalar-List-Utils-%{version}

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
%doc Changes MANIFEST README
%dir %{perl_vendorarch}/List
%dir %{perl_vendorarch}/List/Util
%dir %{perl_vendorarch}/Scalar
%dir %{perl_vendorarch}/Sub
%dir %{perl_vendorarch}/auto/List
%dir %{perl_vendorarch}/auto/List/Util
%{perl_vendorarch}/List/*
%{perl_vendorarch}/List/Util/*
%{perl_vendorarch}/Scalar/*
%{perl_vendorarch}/Sub/*
%{perl_vendorarch}/auto/List/Util/*
%{_mandir}/man3/*

%changelog
* Sat Feb 01 2020 Shawn Iverson <shawniverson@efa-project.org> -  1.53-1
- Built for eFa https://efa-project.org
