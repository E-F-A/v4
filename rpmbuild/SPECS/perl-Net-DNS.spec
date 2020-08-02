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

Name:           perl-Net-DNS
Version:        1.25
Release:        1.eFa%{?dist}
Summary:        DNS server class
License:        mit
Group:          Development/Libraries
URL:            https://metacpan.org/pod/Net::DNS::Nameserver
Source:         https://cpan.metacpan.org/authors/id/N/NL/NLNETLABS/Net-DNS-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch:      noarch
AutoReq:        0
Requires:       perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))
Requires:       perl(Carp)
Requires:       perl(Exporter)
Requires:       perl(IO::File)
Requires:       perl(IO::Select)
Requires:       perl(IO::Socket)
Requires:       perl(MIME::Base64)
Requires:       perl(Net::DNS)
Requires:       perl(Net::DNS::Domain)
Requires:       perl(Net::DNS::DomainName)
Requires:       perl(Net::DNS::Mailbox)
Requires:       perl(Net::DNS::Packet)
Requires:       perl(Net::DNS::Parameters)
Requires:       perl(Net::DNS::RR)
Requires:       perl(Net::DNS::RR::A)
Requires:       perl(Net::DNS::RR::AAAA)
Requires:       perl(Net::DNS::RR::DNSKEY)
Requires:       perl(Net::DNS::RR::DS)
Requires:       perl(Net::DNS::RR::NSEC)
Requires:       perl(Net::DNS::RR::TXT)
Requires:       perl(Net::DNS::Resolver)
Requires:       perl(Net::DNS::Resolver::Base)
Requires:       perl(Net::DNS::Text)
Requires:       perl(Net::DNS::Update)
Requires:       perl(Net::DNS::ZoneFile)
# WTF is this --> perl(OS_CONF)
Requires:       perl(Time::Local)
Requires:       perl(base)
Requires:       perl(constant)
Requires:       perl(integer)
Requires:       perl(overload)
Requires:       perl(strict)
Requires:       perl(warnings)

%description
Net::DNS::Nameserver offers a simple mechanism for instantiation 
of customised DNS server objects intended to provide test responses
to queries emanating from a client resolver.

It is not, nor will it ever be, a general-purpose DNS nameserver implementation.

See "EXAMPLE" for an example.

%prep
%setup -q -n Net-DNS-%{version}

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

%clean
%{__rm} -rf %{buildroot}

%files
%defattr(-,root,root,-)
%doc Changes MANIFEST README
%{perl_vendorlib}/*
%{_mandir}/man3/*

%changelog
* Sun Aug 02 2020 Shawn Iverson <shawniverson@efa-project.org> - 1.25
- Built for eFa https://efa-project.org
