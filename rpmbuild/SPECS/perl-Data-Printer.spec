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

Name:           perl-Data-Printer
Version:        0.40
Release:        1.eFa%{?dist}
Summary:        colored pretty-print of Perl data structures and objects
License:        perl_5
Group:          Development/Libraries
URL:            https://metacpan.org/pod/Data::Printer
Source0:        https://cpan.metacpan.org/authors/id/G/GA/GARU/Data-Printer-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch:      noarch
Requires:       perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))
BuildRequires:  perl-ExtUtils-MakeMaker >= 6.68
Requires:       perl-Carp >= 1.26
Requires:       perl(Clone::PP)
Requires:       perl(Fcntl) >= 1.11
Requires:       perl(File::HomeDir)
Requires:       perl(File::Spec) >= 3.40
Requires:       perl-File-Temp >= 0.23.01
Requires:       perl-Package-Stash >= 0.34
Requires:       perl(Scalar::Util) >= 1.53
Requires:       perl(Sort::Naturally)
Requires:       perl(Term::ANSIColor) >= 3.01
Requires:       perl(Test::More) >= 0.98
Requires:       perl(version) >= 0.9907

%description
Want to see what's inside a variable in a complete, colored and human-friendly way?

%prep
%setup -q -n Data-Printer-%{version}

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
%doc Changes MANIFEST README.md
%{perl_vendorlib}/*
%{_mandir}/man3/*

%changelog
* Sun Feb 02 2020 Shawn Iverson <shawniverson@efa-project.org> - 0.40-1
- Built for eFa https://efa-project.org
