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

Name:           perl-Moo
Version:        2.003006
Release:        1.eFa%{?dist}
Summary:        Minimalist Object Orientation (with Moose compatibility)
License:        perl_5
Group:          Development/Libraries
URL:            https://metacpan.org/pod/Moo
Source0:        https://cpan.metacpan.org/authors/id/H/HA/HAARG/Moo-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch:      noarch
Requires:       perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))
BuildRequires:  perl-ExtUtils-MakeMaker >= 6.68
BuildRequires:  perl(Test::Fatal) => 0.003
BuildRequires:  perl(Test::More) => 0.98
Requires:       perl(Class::Method::Modifiers) >= 1.10
Requires:       perl-Exporter => 5.68
Requires:       perl-Module-Runtime >= 0.016
Requires:       perl(Role::Tiny) >= 2.001004
Requires:       perl(Scalar::Util) >= 1.27
Requires:       perl(Sub::Defer) >= 2.006006
Requires:       perl(Sub::Quote) >= 2.006006

%description
Moo is an extremely light-weight Object Orientation system. It allows one to
concisely define objects and roles with a convenient syntax that avoids the
details of Perl's object system. Moo contains a subset of Moose and is
optimised for rapid startup.

Moo avoids depending on any XS modules to allow for simple deployments. The
name Moo is based on the idea that it provides almost -- but not quite -- two
thirds of Moose. As such, the Moose::Manual can serve as an effective guide
to Moo aside from the MOP and Types sections.

Unlike Mouse this module does not aim at full compatibility with Moose's
surface syntax, preferring instead to provide full interoperability via the
metaclass inflation capabilities described in "MOO AND MOOSE".

For a full list of the minor differences between Moose and Moo's surface
syntax, see "INCOMPATIBILITIES WITH MOOSE".

%prep
%setup -q -n Moo-%{version}

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
%{perl_vendorlib}/*
%{_mandir}/man3/*

%changelog
* Sat Feb 01 2020 Shawn Iverson <shawniverson@efa-project.org> - 2.003006-1
- Built for eFa https://efa-project.org
