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
%undefine _disable_source_fetch

Name:           perl-Net-DNS-Resolver-Programmable
Version:        0.009
Release:        1.eFa%{?dist}
Summary:        programmable DNS resolver class for offline emulation of DNS
License:        perl_5
Group:          Development/Libraries
URL:            https://metacpan.org/pod/Net::DNS::Resolver::Programmable
Source:         https://cpan.metacpan.org/authors/id/B/BI/BIGPRESH/Net-DNS-Resolver-Programmable-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch:      noarch
Requires:       perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))

%description
Net::DNS::Resolver::Programmable is a Net::DNS::Resolver descendant class that allows 
a virtual DNS to be emulated instead of querying the real DNS. A set of static DNS
records may be supplied, or arbitrary code may be specified as a means for retrieving DNS
records, or even generating them on the fly.

%prep
%setup -q -n Net-DNS-Resolver-Programmable-%{version}

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
%doc CHANGES MANIFEST INSTALL README LICENSE TODO
%{perl_vendorlib}/*
%{_mandir}/man3/*

%changelog
* Sun Jul 26 2020 Shawn Iverson <shawniverson@efa-project.org> - 0.009-1
- Built for eFa https://efa-project.org
