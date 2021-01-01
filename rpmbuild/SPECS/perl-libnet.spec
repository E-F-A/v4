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
%define real_name libnet
%undefine _disable_source_fetch

Summary:       Collection of Perl modules which provide Internet protocols
Name:          perl-libnet
Version:       3.11
Epoch:         1
Release:       1.eFa%{?dist}
License:       Artistic/GPL
Group:         Applications/CPAN
URL:           http://search.cpan.org/dist/libnet/
Source:        http://search.cpan.org/CPAN/authors/id/S/SH/SHAY/libnet-%{version}.tar.gz
BuildRoot:     %{_tmppath}/%{name}-%{version}-%{release}-root
BuildRequires: perl >= 0:5.00503
BuildRequires: perl(ExtUtils::MakeMaker) >= 6.64
Requires:      perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))

%filter_from_requires /^perl(Mac/d
%filter_setup

%description
perl-libnet is a collection of Perl modules which provides a simple
and consistent programming interface (API) to the client side
of various protocols used in the internet community.

%prep
%setup -n %{real_name}-%{version}

%build
CFLAGS="%{optflags}" %{__perl} Makefile.PL INSTALLDIRS="vendor" PREFIX="%{buildroot}%{_prefix}"
%{__make} %{?_smp_mflags} OPTIMIZE="%{optflags}"

%install
%{__rm} -rf %{buildroot}
%{__make} pure_install

### Clean up buildroot
find %{buildroot} -name .packlist -exec %{__rm} {} \;

# Remove man files conflicts with perl package
%{__rm} -rf %{buildroot}/%{_mandir}/man3

%clean
%{__rm} -rf %{buildroot}

%files
%defattr(-, root, root, 0755)
%doc Artistic Changes Configure LICENCE README
%{perl_vendorlib}/*

%changelog
* Sun Mar 20 2018 Shawn Iverson <shawniverson@gmail.com> - 3.11-1
- Updated for eFa https://efa-project.org

* Sun Jan 15 2017 Shawn Iverson <shawniverson@gmail.com> - 3.10-1
- Updated for eFa https://efa-project.org

* Tue Feb 23 2016 Shawn Iverson <shawniverson@gmail.com> - 3.08-1
- Updated for eFa https://efa-project.org

* Thu Nov 15 2007 Dag Wieers <dag@wieers.com> - 1.22-1
- Updated to release 1.22.

* Sun Aug 05 2007 Dag Wieers <dag@wieers.com> - 1.21-1
- Updated to release 1.21.

* Sat Nov  5 2005 Dries Verachtert <dries@ulyssis.org> - 1.19-1
- Updated to release 1.19.

* Wed Dec 19 2001 root <root@redhat.com>
- Spec file was autogenerated.
