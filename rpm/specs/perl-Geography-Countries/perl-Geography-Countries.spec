Name:           perl-Geography-Countries
Version:        2009041301
Release:        1.eFa%{?dist}
Summary:        fast lookup of country codes from IP addresses
License:        MIT
Group:          Development/Libraries
URL:            https://metacpan.org/pod/Geography::Countries
Source0:        https://cpan.metacpan.org/authors/id/A/AB/ABIGAIL/Geography-Countries-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
Requires:       perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))

%description
This module maps country names, and their 2-letter, 3-letter and numerical codes, 
as defined by the ISO-3166 maintenance agency [1], and defined by the UNSD.

%prep
%setup -q -n Geography-Countries-%{version}

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
%doc Changes MANIFEST TODO README
%{perl_vendorlib}/*
%{_mandir}/man3/*

%changelog
* Sun Jan 15 2017 Shawn Iverson <shawniverson@gmail.com> - 2009041301-1
- Built for eFa https://efa-project.org
