Summary:    Utility for extracting RAR archives
Name:       unrar
Version:    5.4.5
Release:    1.eFa%{?dist}

License:    Proprietary
Group:      Applications/Archiving
URL:        http://www.rarlab.com/download.htm
Source0:    http://www.rarlab.com/rar/unrarsrc-%{version}.tar.gz

%global debug_package %{nil}

%description
Utility for extracting, and viewing RAR archives

%prep
%setup -q -n %{name}


%build
make %{?_smp_mflags}

%install
mkdir -p %{buildroot}%{_bindir}
mkdir -p %{buildroot}%{_defaultdocdir}/%{name}-%{version}

# Install RAR files
install -pm 755 unrar %{buildroot}%{_bindir}/unrar
install -pm 644 acknow.txt %{buildroot}%{_defaultdocdir}/%{name}-%{version}/acknow.txt
install -pm 644 license.txt %{buildroot}%{_defaultdocdir}/%{name}-%{version}/license.txt
install -pm 644 readme.txt %{buildroot}%{_defaultdocdir}/%{name}-%{version}/readme.txt

%files
%{_bindir}/%{name}

%files -n unrar
%{_bindir}/unrar
%{_defaultdocdir}/%{name}-%{version}/*

%changelog
* Sun Jan 15 2017 eFa Project - 5.4.5-1
- Updated build for eFa4 (CentOS 7)

* Wed Jun 17 2015 eFa Project - 5.2.7-1
- initial build for CentOS & eFa Project
