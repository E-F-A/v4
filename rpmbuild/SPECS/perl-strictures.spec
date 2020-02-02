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

Name:           perl-strictures
Version:        2.000006
Release:        1.eFa%{?dist}
Summary:        Turn on strict and make most warnings fatal
License:        perl_5
Group:          Development/Libraries
URL:            https://metacpan.org/pod/strictures
Source0:        https://cpan.metacpan.org/authors/id/H/HA/HAARG/strictures-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
Requires:       perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))
BuildRequires:  perl-ExtUtils-MakeMaker >= 6.68
BuildRequires:  perl(Test::More) => 0.98

%description
I've been writing the equivalent of this module at the top of my code for about
a year now. I figured it was time to make it shorter.

Things like the importer in use Moose don't help me because they turn warnings
on but don't make them fatal -- which from my point of view is useless because
I want an exception to tell me my code isn't warnings-clean.

Any time I see a warning from my code, that indicates a mistake.

Any time my code encounters a mistake, I want a crash -- not spew to STDERR and
then unknown (and probably undesired) subsequent behaviour.

I also want to ensure that obvious coding mistakes, like indirect object syntax
(and not so obvious mistakes that cause things to accidentally compile as such)
get caught, but not at the cost of an XS dependency and not at the cost of
blowing things up on another machine.

Therefore, strictures turns on additional checking, but only when it thinks
it's running in a test file in a VCS checkout -- although if this causes
undesired behaviour this can be overridden by setting the PERL_STRICTURES_EXTRA
environment variable.

If additional useful author side checks come to mind, I'll add them to the
PERL_STRICTURES_EXTRA code path only -- this will result in a minor version
increase (e.g. 1.000000 to 1.001000 (1.1.0) or similar). Any fixes only to the
mechanism of this code will result in a sub-version increase (e.g. 1.000000 to 
1.000001 (1.0.1)).

%prep
%setup -q -n strictures-%{version}

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
%doc Changes MANIFEST README LICENSE
%dir %{perl_vendorlib}/strictures
%{perl_vendorlib}/*
%{perl_vendorlib}/strictures/*
%{_mandir}/man3/*

%changelog
* Sun Feb 02 2020 Shawn Iverson <shawniverson@efa-project.org> - 2.000006-1
- Built for eFa https://efa-project.org
