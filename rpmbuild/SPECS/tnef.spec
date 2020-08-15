%undefine _disable_source_fetch

Name:      tnef
Epoch:     1
Version:   1.4.18
Release:   1%{?dist}
Summary:   Extract files from email attachments like WINMAIL.DAT
License:   GPLv2+
# what about: src/ConvertUTF.* ?
# * Unicode, Inc. hereby grants the right to freely use the information
# ... Fedora-legal confirmed this to be the free Unicode license.
# The upstream project has moved to github; 
URL:       https://github.com/verdammelt/tnef
# For git hub release archives:
Source0:   https://github.com/verdammelt/%{name}/archive/%{version}/%{name}-%{version}.tar.gz
BuildRequires: automake autoconf

%description
This application provides a way to unpack Microsoft MS-TNEF MIME attachments.
It operates like tar in order to unpack files of type "application/ms-tnef",
which may have been placed into the MS-TNEF attachment instead of being
attached separately.

Such files may have attachment names similar to WINMAIL.DAT

%prep
# Normal release extraction
%setup -q

%build
autoreconf
%configure
make %{?_smp_mflags}
chmod a-x THANKS

%install
rm -rf %{buildroot}
make install DESTDIR=%{buildroot}

%check
make check DESTDIR=%{buildroot}

%files
%doc AUTHORS ChangeLog COPYING NEWS README.md THANKS
%{_bindir}/%{name}
%{_mandir}/man1/%{name}.1*

%changelog
* Sat Aug 15 2020 Shawn Iverson <shawniverson@efa-project.org> - 1:1.4.18-1
- Stripped down build for eFa <https://www.efa-project.org>

* Tue Nov 26 2019 David Timms <iinet.net.au@dtimms> - 1.4.18-1
- Update to release 1.4.18. Fixes CVE-2019-18849 - bug #1771891
- Add global builddolphin to enable -dolphin subpackage when available.

* Sat Jul 27 2019 Fedora Release Engineering <releng@fedoraproject.org> - 1.4.17-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_31_Mass_Rebuild

* Thu Feb  7 2019 David Timms <iinet.net.au@dtimms> - 1.4.17-1
- Update to release 1.4.17.

* Sun Feb 03 2019 Fedora Release Engineering <releng@fedoraproject.org> - 1.4.15-4
- Rebuilt for https://fedoraproject.org/wiki/Fedora_30_Mass_Rebuild

* Sat Jul 14 2018 Fedora Release Engineering <releng@fedoraproject.org> - 1.4.15-3
- Rebuilt for https://fedoraproject.org/wiki/Fedora_29_Mass_Rebuild

* Fri Feb 09 2018 Fedora Release Engineering <releng@fedoraproject.org> - 1.4.15-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_28_Mass_Rebuild

* Wed Oct 11 2017 Kevin Fenzi <kevin@scrye.com> - 1.4.15-1
- Update to 1.4.15. Fixes CVE-2017-8911 - bug #1451256

* Thu Aug 03 2017 Fedora Release Engineering <releng@fedoraproject.org> - 1.4.14-4
- Rebuilt for https://fedoraproject.org/wiki/Fedora_27_Binutils_Mass_Rebuild

* Thu Jul 27 2017 Fedora Release Engineering <releng@fedoraproject.org> - 1.4.14-3
- Rebuilt for https://fedoraproject.org/wiki/Fedora_27_Mass_Rebuild

* Thu Apr 27 2017 David Timms <iinet.net.au@dtimms> - 1.4.14-2
- Update -dolphin to use the kf5 services directory.
- Remove rpm clean section since it's taken care of automatically.

* Thu Apr  6 2017 David Timms <iinet.net.au@dtimms> - 1.4.14-1
- Update to release 1.4.14.
- Includes security fixes for CVE-2017-6307, CVE-2017-6308,
  CVE-2017-6309, CVE-2017-6310.

* Sat Feb 11 2017 Fedora Release Engineering <releng@fedoraproject.org> - 1.4.12-5
- Rebuilt for https://fedoraproject.org/wiki/Fedora_26_Mass_Rebuild

* Fri Feb 05 2016 Fedora Release Engineering <releng@fedoraproject.org> - 1.4.12-4
- Rebuilt for https://fedoraproject.org/wiki/Fedora_24_Mass_Rebuild

* Fri Jun 19 2015 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 1.4.12-3
- Rebuilt for https://fedoraproject.org/wiki/Fedora_23_Mass_Rebuild

* Thu Apr 30 2015 David Timms <iinet.net.au@dtimms> - 1.4.12-3
- replace incorrect source with 1.4.12 release to fix incorrect version.

* Sat Feb 21 2015 David Timms <iinet.net.au@dtimms> - 1.4.12-2
- exclude creating tnef-dolphin subpackage for EPEL-5 which did not ship dolphin.

* Tue Sep 09 2014 David Timms <iinet.net.au@dtimms> - 1.4.12-1
- update to 1.4.12

* Sun Aug 31 2014 David Timms <iinet.net.au@dtimms> - 1.4.11-1.20140826git0b35ad8
- update to 1.4.11 / git tag of 2014-08-26.
- add autoreconf to build process now that upstream no longer creates source tarballs.
- drop upstreamed format-security patch.
- drop document file TODO and update path for README.

* Mon Aug 18 2014 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 1.4.9-6
- Rebuilt for https://fedoraproject.org/wiki/Fedora_21_22_Mass_Rebuild

* Fri Jun 13 2014 Yaakov Selkowitz <yselkowi@redhat.com> - 1.4.9-5
- Fix FTBFS with -Werror=format-security (#1037361, #1107453)

* Sun Jun 08 2014 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 1.4.9-4
- Rebuilt for https://fedoraproject.org/wiki/Fedora_21_Mass_Rebuild

* Sun Aug 04 2013 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 1.4.9-3
- Rebuilt for https://fedoraproject.org/wiki/Fedora_20_Mass_Rebuild

* Fri Feb 15 2013 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 1.4.9-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_19_Mass_Rebuild

* Sun Jul 22 2012 David Timms <iinet.net.au@dtimms> - 1.4.9-1
- update to 1.4.9
- mod kde/dolphin servicemenu to be plain copy rather than desktop-file-validate

* Sat Jul 21 2012 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 1.4.8-6.2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_18_Mass_Rebuild

* Sat Jan 14 2012 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 1.4.8-5.2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_17_Mass_Rebuild

* Sun Aug 14 2011 David Timms <iinet.net.au@dtimms> - 1.4.8-4.2
- mod dolphin subpackage to require kdebase since dolphin not provided in el6

* Tue Jul 19 2011 David Timms <iinet.net.au@dtimms> - 1.4.8-4
- add buildrequires on desktop-file-utils

* Mon Jul 18 2011 David Timms <iinet.net.au@dtimms> - 1.4.8-3
- del main package require on kde-filesystem
- del require on desktop-file-utils to meet packaging guidelines

* Mon Jul 18 2011 David Timms <iinet.net.au@dtimms> - 1.4.8-2
- remove dolphin requires on kde-filesystem
- move update-desktop-database to gui subpackages

* Sun Jul 17 2011 David Timms <iinet.net.au@dtimms> - 1.4.8-1
- update to 1.48
- use % style macros everywhere instead of $ style
- move the desktop icon stuff to subpackage

* Wed Apr  7 2010 David Timms <iinet.net.au@dtimms> - 1.4.7-2
- mod the description and summary to make rpmlint spelling checks happier

* Sat Mar 20 2010 David Timms <iinet.net.au@dtimms> - 1.4.7-1
- update to 1.47, which reverts changes to UTF handling

* Thu Jan  7 2010 David Timms <iinet.net.au@dtimms> - 1.4.6-5
- trial potential fix for ppc32/64 rpm test failure on ppc arch

* Mon Oct  5 2009 David Timms <iinet.net.au@dtimms> - 1.4.6-4
- fix desktop file for nautilus Extract archive menu
- add exclude arch ppc since build tests fail, by using ifarch
- add missing update-desktop-database calls

* Wed Sep 30 2009 David Timms <iinet.net.au@dtimms> - 1.4.6-3
- add missing buildrequires and requires on kde-filesystem
- mod to use desktop-file-install to install the .desktop files.

* Sun Sep 27 2009 David Timms <iinet.net.au@dtimms> - 1.4.6-2
- add tnefextract.desktop ServiceMenu for dolphin
- run make build tests

* Sun Sep 06 2009 David Timms <iinet.net.au@dtimms> - 1.4.6-1
- initial packaging for fedora
- add desktop file for nautilus open, and appropriate extract script
