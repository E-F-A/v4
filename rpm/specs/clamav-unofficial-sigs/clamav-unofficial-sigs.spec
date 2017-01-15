Summary:       clamav-unofficial-sigs Maintained and provided by https://eXtremeSHOK.com
Name:          clamav-unofficial-sigs
Version:       5.4.1
Epoch:         1
Release:       1.eFa%{?dist}
License:       Copyright (c) Adrian Jon Kriel admin@extremeshok.com
Group:         Applications/Utilities
URL:           https://github.com/extremeshok/clamav-unofficial-sigs
Source:        %{name}-%{version}.tar.gz
BuildRoot:     %{_tmppath}/%{name}-%{version}-%{release}-root
Requires:      clamav >= 0.99

%description
The clamav-unofficial-sigs script provides a simple way to download, test, and update third-party
signature databases provided by Sanesecurity, FOXHOLE, OITC, Scamnailer, BOFHLAND, CRDF,
Porcupine, Securiteinfo, MalwarePatrol, Yara-Rules Project, etc.
The script will also generate and install cron, logrotate, and man files.

%prep
%setup -q -n %{name}-%{version}

%build
# Nothing to do

%install
%{__rm} -rf %{buildroot}

mkdir -p %{buildroot}/usr/bin
mkdir %{buildroot}/etc
cp clamav-unofficial-sigs.sh %{buildroot}/usr/bin
mkdir %{buildroot}/etc/clamav-unofficial-sigs
cp config/master.conf %{buildroot}/etc/clamav-unofficial-sigs
cp config/os.centos6.conf %{buildroot}/etc/clamav-unofficial-sigs/os.conf
cp config/user.conf %{buildroot}/etc/clamav-unofficial-sigs
mkdir -p %{buildroot}/var/log/clamav-unofficial-sigs

%pre
# Nothing to do

%post
/usr/bin/clamav-unofficial-sigs.sh --install-cron
/usr/bin/clamav-unofficial-sigs.sh --install-logrotate
/usr/bin/clamav-unofficial-sigs.sh --install-man

%clean
%{__rm} -rf %{buildroot}

%files
%defattr(-, root, root)
%doc INSTALL LICENSE README.md 
%attr(0755, root, root) %{_bindir}/clamav-unofficial-sigs.sh
%dir %{_sysconfdir}/clamav-unofficial-sigs/
%config(noreplace) %{_sysconfdir}/clamav-unofficial-sigs/*
%dir %{_var}/log/clamav-unofficial-sigs/

%changelog
* Sun Aug 21 2016 Shawn Iverson <shawniverson@gmail.com> - 5.4.1-1
- Updated for eFa https://efa-project.org

* Sat Jun 11 2016 Shawn Iverson <shawniverson@gmail.com> - 5.3.2-1
- Updated for eFa https://efa-project.org

* Sun May 22 2016 Shawn Iverson <shawniverson@gmail.com> - 5.3.1-1
- Created for eFa https://efa-project.org
