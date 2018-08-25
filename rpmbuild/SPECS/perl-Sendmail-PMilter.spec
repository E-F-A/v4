#-----------------------------------------------------------------------------#
# eFa SPEC file definition
#-----------------------------------------------------------------------------#
# Copyright (C) 2013~2018 https://efa-project.org
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

Name:           perl-Sendmail-PMilter
Version:        1.00
Release:        1.eFa%{?dist}
Summary:        Mail Filtering API implementing the Sendmail milter protocol
License:        perl_5
Group:          Development/Libraries
URL:            https://metacpan.org/pod/Sendmail::PMilter
Source0:        https://cpan.metacpan.org/authors/id/A/AV/AVAR/Sendmail-PMilter-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildRequires:  perl(ExtUtils::MakeMaker)
BuildRequires:  perl(Test::More)
Requires:       perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))

%description
Sendmail::PMilter is a mail filtering API implementing the Sendmail milter protocol in pure Perl. This allows Sendmail servers (and perhaps other MTAs implementing milter) to filter and modify mail in transit during the SMTP connection, all in Perl.

It should be noted that PMilter 0.90 and later is NOT compatible with scripts written for PMilter 0.5 and earlier. The API has been reworked significantly, and the enhanced APIs and rule logic provided by PMilter 0.5 and earlier has been factored out for inclusion in a separate package to be called Mail::Milter.

%prep
%setup -q -n Sendmail-PMilter-%{version}

%build
echo "yes\n" | %{__perl} Makefile.PL INSTALLDIRS=vendor
make %{?_smp_mflags}

%install
rm -rf $RPM_BUILD_ROOT

make pure_install PERL_INSTALL_ROOT=$RPM_BUILD_ROOT

find $RPM_BUILD_ROOT -type f -name .packlist -exec rm -f {} \;
find $RPM_BUILD_ROOT -depth -type d -exec rmdir {} 2>/dev/null \;

%{_fixperms} $RPM_BUILD_ROOT/*

%check
make test

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
%doc Changes MANIFEST README
%{perl_vendorlib}/*
%{_mandir}/man3/*

%changelog
* Sat Aug 25 2018 Shawn Iverson <shawniverson@efa-project.org> 1.00-1
- Updated for eFa https://efa-project.org
