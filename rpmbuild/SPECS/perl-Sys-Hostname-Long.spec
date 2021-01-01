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

Name:           perl-Sys-Hostname-Long
Version:        1.5
Release:        1.eFa%{?dist}
Summary:        Try every conceivable way to get full hostname
License:        perl_5
Group:          Development/Libraries
URL:            https://metacpan.org/pod/Sys::Hostname::Long
Source0:        https://cpan.metacpan.org/authors/id/S/SC/SCOTT/Sys-Hostname-Long-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch:      noarch
Requires:       perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))

%description
This is the SECOND release of this code. It has an improved set of tests and improved interfaces
but it is still often failing to get a full host name. 
This of course is the reason I wrote the module, it is difficult to get full host names accurately
on each system. On some systems (eg: Linux) it is dependent on the order of the entries in /etc/hosts.

To make it easier to test I have testall.pl to generate an output list of all methods. Thus even if
the logic is incorrect, it may be possible to get the full name.

Attempt via many methods to get the systems full name. 
The Sys::Hostname class is the best and standard way to get the system hostname.
However it is missing the long hostname.

Special thanks to David Sundstrom and Greg Bacon for the original Sys::Hostname

%prep
%setup -q -n Sys-Hostname-Long-%{version}

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
%{perl_vendorlib}/*
%{_mandir}/man3/*.3pm*

%changelog
* Sun Jul 26 2020 Shawn Iverson <shawniverson@gmail.com> - 1.5-1
- Built for eFa https://efa-project.org
