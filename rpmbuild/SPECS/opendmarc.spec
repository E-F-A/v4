%global upname OpenDMARC
%global bigname OPENDMARC

%undefine _disable_source_fetch

Summary: A Domain-based Message Authentication, Reporting & Conformance (DMARC) milter and library
Name: opendmarc
Version: 1.4.1.1
Release: 1.eFa.1%{?dist}
License: BSD and Sendmail
URL: http://www.trusteddomain.org/%{name}.html
Source0: https://github.com/trusteddomainproject/OpenDMARC/archive/refs/tags/rel-opendmarc-1-4-1-1.tar.gz

# Patch for ticket 159 and 179
# fixes opendmarc-importstats script up for mysql
Patch01:   opendmarc-1.4.0-ticket159-179.patch

# OpenDMARC 1.4.1 left a dangling reference to this now-removed config option.
# https://github.com/trusteddomainproject/OpenDMARC/issues/163
Patch02: opendmarc-1.4.1-conf_holdquarantinedmessages.patch
#
# improve mysql and support strict mode
# Unfortunately, this patchset no longer applies and there's changes, so it needs rebasing
# by someone who knows the code well.
# Patch03:   %%{name}.ticket193.patch
#

# CVE-2021-34555
Patch04: opendmarc-1.4.1-178.patch

# Required for all versions
Requires: lib%{name}%{?_isa} = %{version}-%{release}
BuildRequires: make
BuildRequires: libspf2-devel, openssl-devel, libtool, pkgconfig, libbsd, libbsd-devel
Requires(pre): shadow-utils

BuildRequires: systemd
BuildRequires: autoconf
BuildRequires: automake
BuildRequires: libtool
%if 0%{?fedora} || 0%{?rhel} >= 8
BuildRequires: mariadb-connector-c-devel
BuildRequires: sendmail-milter-devel
%else
BuildRequires: mysql-devel
BuildRequires: sendmail-devel
%endif

%description
%{upname} (Domain-based Message Authentication, Reporting & Conformance)
provides an open source library that implements the DMARC verification
service plus a milter-based filter application that can plug in to any
milter-aware MTA, including sendmail, Postfix, or any other MTA that supports
the milter protocol.

The DMARC sender authentication system is still a draft standard, working
towards RFC status.

The database schema required for some functions is provided in
%{_datadir}/%{name}/db. The rddmarc tools are provided in
%{_datadir}/%{name}/contrib/rddmarc.

%package -n libopendmarc
Summary: An open source DMARC library

%description -n libopendmarc
This package contains the library files required for running services built
using libopendmarc.

%package -n libopendmarc-devel
Summary: Development files for libopendmarc
Requires: lib%{name}%{?_isa} = %{version}-%{release}

%description -n lib%{name}-devel
This package contains the static libraries, headers, and other support files
required for developing applications against libopendmarc.

%prep
%autosetup -p1 -n OpenDMARC-rel-opendmarc-1-4-1-1
# remove localstatedir from service file
sed -i -e 's|@localstatedir@||' contrib/service/opendmarc.service.in

%build
autoreconf -v -i
%configure --with-sql-backend --with-spf -with-spf2-include=%{_prefix}/include/spf2 --with-spf2-lib=%{_libdir}/libspf2.so
make DESTDIR=%{buildroot} %{?_smp_mflags}

%install
make DESTDIR=%{buildroot} install %{?_smp_mflags}
mkdir -p %{buildroot}%{_sysconfdir}
install -d %{buildroot}%{_sysconfdir}/sysconfig
mkdir -p -m 0755 %{buildroot}%{_sysconfdir}/%{name}

cat > %{buildroot}%{_sysconfdir}/sysconfig/%{name} << 'EOF'
# Set the necessary startup options
OPTIONS="-c %{_sysconfdir}/%{name}.conf -P %{_rundir}/%{name}/%{name}.pid"
EOF

install -d -m 0755 %{buildroot}%{_unitdir}
cat > %{buildroot}%{_unitdir}/%{name}.service << 'EOF'
[Unit]
Description=Domain-based Message Authentication, Reporting & Conformance (DMARC) Milter
Documentation=man:%{name}(8) man:%{name}.conf(5) man:%{name}-import(8) man:%{name}-reports(8) http://www.trusteddomain.org/%{name}/
After=network.target nss-lookup.target syslog.target

[Service]
Type=forking
PIDFile=/var/run/%{name}/%{name}.pid
EnvironmentFile=-/etc/sysconfig/%{name}
ExecStart=/usr/sbin/%{name} $OPTIONS
ExecReload=/bin/kill -USR1 $MAINPID
User=%{name}
Group=%{name}

[Install]
WantedBy=multi-user.target
EOF

# Install and set some basic settings in the default config file
install -m 0644 %{name}/%{name}.conf.sample %{buildroot}%{_sysconfdir}/%{name}.conf

sed -i 's|^# AuthservID name |AuthservID HOSTNAME |' %{buildroot}%{_sysconfdir}/%{name}.conf
sed -i 's|^# HistoryFile /var/run/%{name}.dat|# HistoryFile %{_localstatedir}/spool/%{name}/%{name}.dat|' %{buildroot}%{_sysconfdir}/%{name}.conf
sed -i 's|^# Socket |Socket |' %{buildroot}%{_sysconfdir}/%{name}.conf
sed -i 's|^# SoftwareHeader false|SoftwareHeader true|' %{buildroot}%{_sysconfdir}/%{name}.conf
sed -i 's|^# SPFIgnoreResults false|SPFIgnoreResults true|' %{buildroot}%{_sysconfdir}/%{name}.conf
sed -i 's|^# SPFSelfValidate false|SPFSelfValidate true|' %{buildroot}%{_sysconfdir}/%{name}.conf
sed -i 's|^# Syslog false|Syslog true|' %{buildroot}%{_sysconfdir}/%{name}.conf
sed -i 's|^# UMask 077|UMask 007|' %{buildroot}%{_sysconfdir}/%{name}.conf
sed -i 's|^# UserID %{name}|UserID %{name}:mail|' %{buildroot}%{_sysconfdir}/%{name}.conf
sed -i 's|/usr/local||' %{buildroot}%{_sysconfdir}/%{name}.conf

install -p -d %{buildroot}%{_sysconfdir}/tmpfiles.d
cat > %{buildroot}%{_sysconfdir}/tmpfiles.d/%{name}.conf <<EOF
D %{_rundir}/%{name} 0700 %{name} %{name} -
EOF

rm -rf %{buildroot}%{_prefix}/share/doc/%{name}
rm %{buildroot}%{_libdir}/*.{la,a}

mkdir -p %{buildroot}%{_includedir}/%{name}
install -m 0644 lib%{name}/dmarc.h %{buildroot}%{_includedir}/%{name}/

mkdir -p %{buildroot}%{_localstatedir}/spool/%{name}
mkdir -p %{buildroot}%{_rundir}/%{name}

# install db/ and contrib/ to datadir
mkdir -p %{buildroot}%{_datadir}/%{name}/contrib
cp -R db/ %{buildroot}%{_datadir}/%{name}
sed -i -e 's:/usr/local/bin/python:/usr/bin/python:' contrib/rddmarc/dmarcfail.py
cp -R contrib/rddmarc/ %{buildroot}%{_datadir}/%{name}/contrib
# not much point including the Makefiles
rm -f %{buildroot}%{_datadir}/%{name}/contrib/rddmarc/Makefile*
rm -f %{buildroot}%{_datadir}/%{name}/db/Makefile*

%pre
getent group %{name} >/dev/null || groupadd -r %{name}
getent passwd %{name} >/dev/null || \
	useradd -r -g %{name} -G mail -d %{_rundir}/%{name} -s /sbin/nologin \
	-c "%{upname} Milter" %{name}
exit 0

%post
%systemd_post %{name}.service

%preun
%systemd_preun %{name}.service

%postun
%systemd_postun_with_restart %{name}.service

%ldconfig_scriptlets -n libopendmarc

%files
%license LICENSE LICENSE.Sendmail
%doc README RELEASE_NOTES
%config(noreplace) %{_sysconfdir}/%{name}.conf
%config(noreplace) %{_sysconfdir}/tmpfiles.d/%{name}.conf
%config(noreplace) %{_sysconfdir}/sysconfig/%{name}
%{_datadir}/%{name}
%{_sbindir}/*
%{_mandir}/*/*
%dir %attr(-,%{name},%{name}) %{_localstatedir}/spool/%{name}
%dir %attr(710,%{name},mail) %{_rundir}/%{name}
%dir %attr(-,%{name},%{name}) %{_sysconfdir}/%{name}
%attr(0644,root,root) %{_unitdir}/%{name}.service

%files -n libopendmarc
%{_libdir}/lib%{name}.so.*

%files -n libopendmarc-devel
%doc lib%{name}/docs/*.html
%{_includedir}/%{name}
%{_libdir}/*.so

%changelog
* Thu Jun 17 2021 Shawn Iverson <shawniverson@efa-project.org> - 1.4.1-1eFa.1
- https://github.com/trusteddomainproject/OpenDMARC/issues/179

* Thu Apr 29 2021 Matt Domsch <mdomsch@fedoraproject.org> - 1.4.1-1
- Update to 1.4.1

* Sat Apr 24 2021 Kevin Fenzi <kevin@scrye.com> - 1.4.0-1
- Update to 1.4.0 and clean up spec.

* Tue Mar 02 2021 Zbigniew Jędrzejewski-Szmek <zbyszek@in.waw.pl> - 1.3.2-6
- Rebuilt for updated systemd-rpm-macros
  See https://pagure.io/fesco/issue/2583.

* Tue Feb  2 2021 Honza Horak <hhorak@redhat.com> - 1.3.2-5
- Use correct name for the mariadb package

* Tue Jan 26 2021 Fedora Release Engineering <releng@fedoraproject.org> - 1.3.2-4
- Rebuilt for https://fedoraproject.org/wiki/Fedora_34_Mass_Rebuild

* Tue Jul 28 2020 Fedora Release Engineering <releng@fedoraproject.org> - 1.3.2-3
- Rebuilt for https://fedoraproject.org/wiki/Fedora_33_Mass_Rebuild

* Wed Jan 29 2020 Fedora Release Engineering <releng@fedoraproject.org> - 1.3.2-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_32_Mass_Rebuild

* Fri Oct 04 2019 Adam Williamson <awilliam@redhat.com> - 1.3.2-1
- Update to 1.3.2 final (belatedly)
- Drop patches merged upstream
- Backport proposed fix for upstream #227 (RHBZ #1673293)
- Backport proposed fix for CVE-2019-16378 (RHBZ #1753082 and #1753081)
- Ship database schema and rddmarc bits (#1415753)

* Thu Jul 25 2019 Fedora Release Engineering <releng@fedoraproject.org> - 1.3.2-0.20
- Rebuilt for https://fedoraproject.org/wiki/Fedora_31_Mass_Rebuild

* Fri Feb 01 2019 Fedora Release Engineering <releng@fedoraproject.org> - 1.3.2-0.19
- Rebuilt for https://fedoraproject.org/wiki/Fedora_30_Mass_Rebuild

* Fri Jul 13 2018 Fedora Release Engineering <releng@fedoraproject.org> - 1.3.2-0.18
- Rebuilt for https://fedoraproject.org/wiki/Fedora_29_Mass_Rebuild

* Fri Feb 09 2018 Igor Gnatenko <ignatenkobrain@fedoraproject.org> - 1.3.2-0.17
- Escape macros in %%changelog

* Thu Feb 08 2018 Fedora Release Engineering <releng@fedoraproject.org> - 1.3.2-0.16
- Rebuilt for https://fedoraproject.org/wiki/Fedora_28_Mass_Rebuild

* Thu Aug 03 2017 Fedora Release Engineering <releng@fedoraproject.org> - 1.3.2-0.15
- Rebuilt for https://fedoraproject.org/wiki/Fedora_27_Binutils_Mass_Rebuild

* Thu Jul 27 2017 Fedora Release Engineering <releng@fedoraproject.org> - 1.3.2-0.14
- Rebuilt for https://fedoraproject.org/wiki/Fedora_27_Mass_Rebuild

* Sat Feb 11 2017 Fedora Release Engineering <releng@fedoraproject.org> - 1.3.2-0.13
- Rebuilt for https://fedoraproject.org/wiki/Fedora_26_Mass_Rebuild

* Mon Dec 19 2016 Adam Williamson <awilliam@redhat.com> - 1.3.2-0.12
- rediff and re-enable patches

* Sun Dec 18 2016 Steve Jenkins <steve@stevejenkins.com> - 1.3.2-0.11
- Updated to 1.3.2.Beta1 upstream source
- Removed patches no longer required due to new source

* Tue Dec 13 2016 Adam Williamson <awilliam@redhat.com> - 1.3.2-0.10
- Adapt several patches for building on EPEL 5 (without autoreconf)

* Tue Dec 13 2016 Steve Jenkins <steve@stevejenkins.com> - 1.3.2-0.9
- Combined fixes for upstream tickets #159 + #179 into a single patch

* Mon Dec 12 2016 Adam Williamson <awilliam@redhat.com> - 1.3.2-0.8
- Add a ton more important fixes from Juri Haberland
- Modernize spec slightly (thanks to EPEL 5 getting a bit more modern)

* Thu Nov 24 2016 Adam Williamson <awilliam@redhat.com> - 1.3.2-0.7
- Add a fix for a crasher (upstream ticket #185) from Juri Haberland

* Thu Aug 04 2016 Steve Jenkins <steve@stevejenkins.com> - 1.3.2-0.6
- Changed sendmail-milter-devel BuildRequires to > F25

* Thu Aug 04 2016 Steve Jenkins <steve@stevejenkins.com> - 1.3.2-0.5
- Updated BuildRequires to sendmail-milter-devel for F25+ (RH Bugzilla #891288)

* Sat Jul 23 2016 Steve Jenkins <steve@stevejenkins.com> - 1.3.2-0.4.beta0
- Revised patch for #1287176 to fix opendmarc-import path

* Thu Jul 21 2016 Steve Jenkins <steve@stevejenkins.com> - 1.3.2-0.3.beta0
- Patched for #1287176 to fix opendmarc-import path

* Wed Jul 20 2016 Steve Jenkins <steve@stevejenkins.com> - 1.3.2-0.2.beta0
- Restored Group: System Environment/Daemons field for EL5 build

* Wed Jul 20 2016 Steve Jenkins <steve@stevejenkins.com> - 1.3.2-0.1.beta0
- Updated to 1.3.2.Beta0 upstream source
- Removed references to previous docs no longer in source
- Added patch by Scott Kitterman to fix typo
- Added BuildRequires: systemd for systemd targets

* Mon Apr 11 2016 Steve Jenkins <steve@stevejenkins.com> - 1.3.1-17
- Updating spec file to more modern conventions (thx, tibbs)

* Mon Apr 11 2016 Steve Jenkins <steve@stevejenkins.com> - 1.3.1-16
- Added patches for SourceForge tickets 115, 131, 138, 139

* Thu Feb 04 2016 Fedora Release Engineering <releng@fedoraproject.org> - 1.3.1-15
- Rebuilt for https://fedoraproject.org/wiki/Fedora_24_Mass_Rebuild

* Wed Jun 17 2015 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 1.3.1-14
- Rebuilt for https://fedoraproject.org/wiki/Fedora_23_Mass_Rebuild

* Wed Apr 29 2015 Steve Jenkins <steve@stevejenkins.com> - 1.3.1-13
- Replaced various commands with rpm macros
- Included support for systemd macros (#1216881)

* Mon Apr 13 2015 Steve Jenkins <steve@stevejenkins.com> - 1.3.1-12
- Added libspf2-devel to BuildRequires
- libspf2 support now provided for all branches

* Thu Apr 09 2015 Steve Jenkins <steve@stevejenkins.com> - 1.3.1-11
- Added --with-libspf2 support for all branches except EL5

* Fri Apr 03 2015 Steve Jenkins <steve@stevejenkins.com> - 1.3.1-10
- policycoreutils now only required for EL5

* Mon Mar 30 2015 Steve Jenkins <steve@stevejenkins.com> - 1.3.1-9
- policycoreutils* now only required for Fedora and EL6+
- Added --with-sql-backend configure support
- Changed a few macros

* Sun Mar 29 2015 Steve Jenkins <steve@stevejenkins.com> - 1.3.1-8
- removed unecessary Requires packages
- moved libbsd back to BuildRequires
- removed unecessary %%defattr
- added support for %%license in place of %%doc
- Changed some %%{name} macro usages

* Sat Mar 28 2015 Steve Jenkins <steve@stevejenkins.com> - 1.3.1-7
- added %%{?_isa} to Requires where necessary
- added sendmail-milter to Requires
- moved libbsd from BuildRequires to Requires
- added policycoreutils and policycoreutils-python to Requires(post)

* Sat Mar 28 2015 Steve Jenkins <steve@stevejenkins.com> - 1.3.1-6
- Removed uneeded _pkgdocdir reference

* Fri Mar 27 2015 Steve Jenkins <steve@stevejenkins.com> - 1.3.1-5
- Combined systemd and SysV spec files using conditionals
- Set AuthservID configuration option to HOSTNAME by default

* Thu Mar 12 2015 Steve Jenkins <steve@stevejenkins.com> 1.3.1-4
- Dropped El5/SysV support due to perl-IO-Compress dependency probs
- Fixed extra space in UserID default setting
- Disabled HistoryFile logging by default
- Set default SoftwareHeader to true
- Set default SPFIgnoreResults to true
- Set default SPFSelfValidate to true

* Fri Mar 06 2015 Steve Jenkins <steve@stevejenkins.com> 1.3.1-3
- Added libbsd and libbsd-devel build requirement to fix libstrl issue

* Thu Mar 05 2015 Steve Jenkins <steve@stevejenkins.com> 1.3.1-2
- Branched spec files into systemd and SysV versions
- Added top comment for EL5 to bypass MD5 build errors
- Added opendmarc.service file for systemd support
- Added sysconfig file support for runtime options

* Sat Feb 28 2015 Matt Domsch <mdomsch@fedoraproject.org> 1.3.1-1
- upgrade to 1.3.1

* Tue Sep 30 2014 Matt Domsch <mdomsch@fedoraproject.org> 1.3.0-3
- add /etc/opendmarc/ config directory

* Sat Sep 27 2014 Matt Domsch <mdomsch@fedoraproject.org> 1.3.0-2
- use --with-spf

* Sat Sep 13 2014 Matt Domsch <mdomsch@fedoraproject.org> 1.3.0-1
- update to version 1.3.0

* Thu Jul 11 2013 Patrick Laimbock <patrick@laimbock.com> 1.1.3-2
- update to version 1.1.3
- updated docs
- remove rpath
- set HistoryFile to /var/spool/opendmarc/opendmarc.dat
- enable logging by default
- set umask to 007
- set UserID to opendmarc:mail

* Mon Jan 28 2013 Steve Jenkins <steve@stevejenkins.com> 1.0.1
- Accepted Fedora SPEC file management from Todd Lyons (thx, Todd!)
- Fixed some default config file issues by using sed
- Removed BETA references
- Fixed URL in Header

* Wed Jan 23 2013 Todd Lyons <tlyons@ivenue.com> 1.0.1-1iv
- New release (behind schedule)

* Wed Oct 10 2012 Todd Lyons <tlyons@ivenue.com> 1.0.0-0.Beta1.1iv
- New release

* Fri Sep 14 2012 Todd Lyons <tlyons@ivenue.com> 0.2.2-1iv
- Update to current release.

* Fri Aug 31 2012 Todd Lyons <tlyons@ivenue.com> 0.2.1-1iv
- New Release

* Tue Aug  7 2012 Todd Lyons <tlyons@ivenue.com> 0.1.8-1iv
- Initial Packaging of opendmarc

