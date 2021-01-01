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

%undefine _disable_source_fetch

#-----------------------------------------------------------------------------#
# Required packages for building this RPM
#-----------------------------------------------------------------------------#
# yum -y install
#-----------------------------------------------------------------------------#
Name:           perl-Sys-SigAction
Version:        0.23
Release:        1.eFa%{?dist}
Summary:        Perl extension for Consistent Signal Handling
License:        perl_5
Group:          Development/Libraries
URL:            https://metacpan.org/pod/Sys::SigAction
Source:         https://cpan.metacpan.org/authors/id/L/LB/LBAXTER/Sys-SigAction-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch:      noarch
Requires:       perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))

%description
This module implements set_sig_handler(), which sets up a signal handler and (optionally)
returns an object which causes the signal handler to be reset to the previous value,
when it goes out of scope.

Also implemented is timeout_call() which takes a timeout value, a code reference and
optional arguments, and executes the code reference wrapped with an alarm timeout.
timeout_call accepts seconds in floating point format, so you can time out call with
a resolution of 0.000001 seconds. If Time::HiRes is not loadable or Time::HiRes::ualarm()
does not work, then the factional part of the time value passed to timeout_call() will be
raise to the next higher integer with POSIX::ceil(). This means that the shortest a timeout 
can be in 1 second.

Finally, two convenience routines are defined which allow one to get the signal name from
the number -- sig_name(), and get the signal number from the name -- sig_number().

%prep
%setup -q -n Sys-SigAction-%{version}

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

%{_fixperms} %{buildroot}/*

%check
%{__make} test

%clean
%{__rm} -rf %{buildroot}

%files
%defattr(-,root,root,-)
%doc Changes README MANIFEST
%{perl_vendorlib}/*
%{_mandir}/man3/*

%changelog
* Sun Aug 02 2020 Shawn Iverson <shawniverson@efa-project.org> - 0.23
- Build for eFa https://efa-project.org
