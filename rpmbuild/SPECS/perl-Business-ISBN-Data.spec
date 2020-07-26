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

Name:           perl-Business-ISBN-Data
Version:        20191107
Release:        1.eFa%{?dist}
Summary:        data pack for Business::ISBN
License:        artistic_2
Group:          Development/Libraries
URL:            https://metacpan.org/pod/Business::ISBN::Data
Source:         https://cpan.metacpan.org/authors/id/B/BD/BDFOY/Business-ISBN-Data-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch:      noarch

%description
You don't need to load this module yourself in most cases. Business::ISBN will load it when it loads.

These data are generated from the RangeMessage.xml file provided by the ISBN Agency.
You can retrieve this yourself at https://www.isbn-international.org/range_file_generation.
This file is included as part of the distribution and should be installed at
~lib/Business/ISBN/Data/RangeMessage.xml.

If you want to use a different RangeMessage.xml file, you can set the ISBN_RANGE_MESSAGE environment
variable to the alternate location before you load Business::ISBN. This way, you can use the latest
(or even earlier) data without having to install something new or wait for an update to this module.

If the default RangeMessage.xml or your alternate one is not available, the module falls back to data
included in Data.pm. However, that data is likely to be older data. If it does not find that file, it
looks for RangeMessage.xml in the current directory.

The data are in %Business::ISBN::country_data (although the "country" part is historical).
If you want to see where the data are from, check $Business::ISBN::country_data{_source}.

%prep
%setup -q -n Business-ISBN-Data-%{version}

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
%doc Changes LICENSE MANIFEST README.pod
%{perl_vendorlib}/*
%{_mandir}/man3/*

%changelog
* Sun Jul 26 2020 Shawn Iverson <shawniverson@efa-project.org> - 3.005-1
- Built for eFa https://efa-project.org
