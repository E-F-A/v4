Name:      dcc
Summary:   DCC Distributed Checksum Clearinghouse
Version:   1.3.158
Release:   1.eFa%{?dist}
Epoch:     1
Group:     System Environment/Daemons
URL:       https://www.rhyolite.com/dcc
License:   Copyright (c) 2014 by Rhyolite Software, LLC
Source0:   dcc-%{version}.tar.gz
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
Requires: postfix >= 3.1.3
Requires: spamassassin >= 3.4.1
Requires: MailScanner >= 5.0.4-3

%description
The DCC or Distributed Checksum Clearinghouse is an anti-spam content filter that runs on a variety of operating systems. The idea of the DCC is that if mail recipients could compare the mail they receive, they could recognize unsolicited bulk mail. A DCC server totals reports of "fuzzy" checksums of messages from clients and answers queries about the total counts for checksums of mail messages.

%prep
%setup -q

%build
./configure --disable-dccm --with-installroot=$RPM_BUILD_ROOT --mandir=/usr/share/man --bindir=/usr/bin

make %{?_smp_mflags} 

%install
rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT

make install

%preun

%postun

%post
ln -s /var/dcc/libexec/cron-dccd /usr/bin/cron-dccd
ln -s /var/dcc/libexec/cron-dccd /etc/cron.monthly/cron-dccd
cp /var/dcc/libexec/rcDCC /etc/init.d/adcc
DCC_HOME=$(grep dcc_home /etc/MailScanner/spamassassin.conf)
if [[ -z $DCC_HOME ]]; then
  echo "dcc_home /var/dcc" >> /etc/MailScanner/spamassassin.conf
fi
sed -i '/^dcc_path / c\dcc_path /usr/local/bin/dccproc' /etc/MailScanner/spamassassin.conf
sed -i '/^DCCIFD_ENABLE=/ c\DCCIFD_ENABLE=on' /var/dcc/dcc_conf
sed -i '/^DBCLEAN_LOGDAYS=/ c\DBCLEAN_LOGDAYS=1' /var/dcc/dcc_conf
sed -i '/^DCCIFD_LOGDIR=/ c\DCCIFD_LOGDIR="/var/dcc/log"' /var/dcc/dcc_conf
sed -i "s/#loadplugin Mail::SpamAssassin::Plugin::DCC/loadplugin Mail::SpamAssassin::Plugin::DCC/g" /etc/mail/spamassassin/v310.pre

%clean
rm -rf $RPM_BUILD_ROOT

%files
%doc CHANGES LICENSE RESTRICTIONS
%defattr(-, root, root, -)
%{_bindir}/*
%{_mandir}/man8/*
%attr(-, postfix, postfix) %{_localstatedir}/dcc


%changelog
* Sun Jan 22 2017 Shawn Iverson <shawniverson@gmail.com> - 1.3.158-1
- Initial Build for eFa v4 on CentOS7 <https://efa-project.org>
