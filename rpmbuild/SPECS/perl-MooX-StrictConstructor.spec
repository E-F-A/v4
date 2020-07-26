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

Name:           perl-MooX-StrictConstructor
Version:        0.010
Release:        1.eFa%{?dist}
Summary:        Make your Moo-based object constructors blow up on unknown attributes.
License:        perl_5
Group:          Development/Libraries
URL:            https://metacpan.org/pod/MooX::StrictConstructor
Source0:        https://cpan.metacpan.org/authors/id/H/HA/HARTZELL/MooX-StrictConstructor-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch:      noarch
Requires:       perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))
BuildRequires:  perl-ExtUtils-MakeMaker >= 6.68
BuildRequires:  perl(File::Spec) >= 3.40
BuildRequires:  perl-File-Temp >= 0.23.01
BuildRequires:  perl(IO::Handle) >= 1.33
BuildRequires:  perl(IPC::Open3) >= 1.12
BuildRequires:  perl(Test::Fatal) => 0.003
BuildRequires:  perl(Test::More) => 0.98
BuildRequires:  perl(warnings) >= 1.13
Requires:       perl(B) >= 1.35
Requires:       perl-Class-Method-Modifiers >= 2.10
Requires:       perl-Moo >= 2.003006
Requires:       perl(Moo::Role) >= 2.003006
Requires:       perl-constant >= 1.27
Requires:       perl(strict) >= 1.07
Requires:       perl(strictures) >= 1

%description
Simply loading this module makes your constructors "strict". If your
constructor is called with an attribute init argument that your class does not
declare, then it dies. This is a great way to catch small typos.

%prep
%setup -q -n MooX-StrictConstructor-%{version}

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
%doc Changes MANIFEST LICENSE
%{perl_vendorlib}/*
%{_mandir}/man3/*

%changelog
* Sun Feb 02 2020 Shawn Iverson <shawniverson@efa-project.org> - 0.010-1
- Built for eFa https://efa-project.org
