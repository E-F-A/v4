%undefine _disable_source_fetch

%global srcname pyspf
%{?python_provide:%python_provide python3-%{srcname}}

Name:           python-%{srcname}_eFa
Version:        2.0.14
Release:        8.eFa%{?dist}
Summary:        Python module and programs for SPF (Sender Policy Framework)

License:        Python
URL:            http://pypi.python.org/pypi/pyspf
# Also see http://bmsi.com/python/milter.html
Source0:        https://files.pythonhosted.org/packages/source/p/%{srcname}/%{srcname}-%{version}.tar.gz
Patch0:         pyspf-2.0.14-newlines.patch
Patch1:         pyspf-2.0.14-dns-query.patch

BuildArch:      noarch

%description
SPF does email sender validation.  For more information about SPF,
please see http://spf.pobox.com.

This SPF client is intended to be installed on the border MTA, checking
if incoming SMTP clients are permitted to forward mail.  The SPF check
should be done during the MAIL FROM:<...> command.

%package -n python3-%{srcname}
Summary:        %{summary}
BuildRequires:  python3-setuptools
BuildRequires:  python3-devel
# For tests
# BuildRequires:  python2-yaml
# Not yet packaged
# BuildRequires:  python-authres

Requires:       python3-py3dns
%{?python_provide:%python_provide python3-%{srcname}}

%description -n python3-%{srcname}
SPF does email sender validation.  For more information about SPF,
please see http://spf.pobox.com.

This SPF client is intended to be installed on the border MTA, checking
if incoming SMTP clients are permitted to forward mail.  The SPF check
should be done during the MAIL FROM:<...> command.

This package provides Python 3 build of %{srcname}.

%prep
%setup -qn %{srcname}-%{version}
%patch0 -p1 -b .newlines
%patch1 -p1 -b .dns-query

%build
%py3_build

%check
# Tests require unpackaged python-authres

%install
%py3_install
mv %{buildroot}%{_bindir}/type99.py %{buildroot}%{_bindir}/type99
#mv %{buildroot}%{_bindir}/spfquery.py %{buildroot}%{_bindir}/spfquery
rm -f %{buildroot}%{_bindir}/*.py{o,c}
# Remove shebang from python libraries
sed -i -e '/^#!\//, 1d' %{buildroot}%{python3_sitelib}/*.py

%files -n python3-%{srcname}
%doc CHANGELOG PKG-INFO README.md
%{python3_sitelib}/__pycache__
%{_bindir}/type99
%{_bindir}/spfquery.py
%{python3_sitelib}/spf.py*
%{python3_sitelib}/pyspf-%{version}-py*.egg-info

%changelog
* Sun Jun 16 2024 Shawn Iverson <shawniverson@efa-project.org> - 2.0.14-8.eFa
- Repackaged for eFa to resolve conflict with perl-Mail-SPF-Query

* Tue Nov 10 2020 Bojan Smojver <bojan@rexursive.com> - 2.0.14-8
- Add dns query patch (bug #1891225)

* Tue Nov 10 2020 Bojan Smojver <bojan@rexursive.com> - 2.0.14-7
- Revert conflicts with python3-dns (bug #1891225)

* Sun Oct 25 2020 Bojan Smojver <bojan@rexursive.com> - 2.0.14-6
- Add conflicts with python3-dns (bug #1891225)

* Wed Jul 29 2020 Fedora Release Engineering <releng@fedoraproject.org> - 2.0.14-5
- Rebuilt for https://fedoraproject.org/wiki/Fedora_33_Mass_Rebuild

* Tue May 26 2020 Miro Hrončok <mhroncok@redhat.com> - 2.0.14-4
- Rebuilt for Python 3.9

* Fri Feb 21 2020 Bojan Smojver <bojan@rexursive.com> - 2.0.14-3
- relax and replace LF with space (bug #1573072, pb at bieringer dot de)

* Fri Feb  7 2020 Bojan Smojver <bojan@rexursive.com> - 2.0.14-1
- Update to 2.0.14
- Should fix bug #1770636
- Change the name of the README file

* Thu Jan 30 2020 Fedora Release Engineering <releng@fedoraproject.org> - 2.0.13-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_32_Mass_Rebuild

* Fri Nov 01 2019 Paul Wouters <pwouters@redhat.com> - 2.0.13-2
- Add python-pyspf via provides macro

* Wed Oct 30 2019 Paul Wouters <pwouters@redhat.com> - 2.0.13-1
- Update to 2.0.13

* Thu Oct 03 2019 Miro Hrončok <mhroncok@redhat.com> - 2.0.12-13
- Rebuilt for Python 3.8.0rc1 (#1748018)

* Mon Aug 19 2019 Miro Hrončok <mhroncok@redhat.com> - 2.0.12-12
- Rebuilt for Python 3.8

* Fri Jul 26 2019 Fedora Release Engineering <releng@fedoraproject.org> - 2.0.12-11
- Rebuilt for https://fedoraproject.org/wiki/Fedora_31_Mass_Rebuild

* Sat Feb 02 2019 Fedora Release Engineering <releng@fedoraproject.org> - 2.0.12-10
- Rebuilt for https://fedoraproject.org/wiki/Fedora_30_Mass_Rebuild

* Thu Oct 11 2018 Zbigniew Jędrzejewski-Szmek <zbyszek@in.waw.pl> - 2.0.12-9
- Python2 binary package has been removed
  See https://fedoraproject.org/wiki/Changes/Mass_Python_2_Package_Removal

* Sat Jul 14 2018 Fedora Release Engineering <releng@fedoraproject.org> - 2.0.12-8
- Rebuilt for https://fedoraproject.org/wiki/Fedora_29_Mass_Rebuild

* Tue Jun 19 2018 Miro Hrončok <mhroncok@redhat.com> - 2.0.12-7
- Rebuilt for Python 3.7

* Fri Feb 09 2018 Fedora Release Engineering <releng@fedoraproject.org> - 2.0.12-6
- Rebuilt for https://fedoraproject.org/wiki/Fedora_28_Mass_Rebuild

* Sat Jan 27 2018 Iryna Shcherbina <ishcherb@redhat.com> - 2.0.12-5
- Update Python 2 dependency declarations to new packaging standards
  (See https://fedoraproject.org/wiki/FinalizingFedoraSwitchtoPython3)

* Thu Jul 27 2017 Fedora Release Engineering <releng@fedoraproject.org> - 2.0.12-4
- Rebuilt for https://fedoraproject.org/wiki/Fedora_27_Mass_Rebuild

* Sat Feb 11 2017 Fedora Release Engineering <releng@fedoraproject.org> - 2.0.12-3
- Rebuilt for https://fedoraproject.org/wiki/Fedora_26_Mass_Rebuild

* Mon Dec 19 2016 Miro Hrončok <mhroncok@redhat.com> - 2.0.12-2
- Rebuild for Python 3.6

* Tue Oct 11 2016 Jan Beran <jberan@redhat.com> - 2.0.12-1
- Update to 2.0.12
- Add Python 3 subpackage

* Tue Jul 19 2016 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 2.0.11-5
- https://fedoraproject.org/wiki/Changes/Automatic_Provides_for_Python_RPM_Packages

* Thu Feb 04 2016 Fedora Release Engineering <releng@fedoraproject.org> - 2.0.11-4
- Rebuilt for https://fedoraproject.org/wiki/Fedora_24_Mass_Rebuild

* Fri Nov  6 2015 Bojan Smojver <bojan@rexursive.com> - 2.0.11-3
- Actually resolves: rhbz#1232595 Improper use of python's ipaddress

* Tue Jul 28 2015 Paul Wouters <pwouters@redhat.com> - 2.0.11-2
- Resolves: rhbz#1232595 Improper use of python's ipaddress

* Thu Jun 18 2015 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 2.0.11-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_23_Mass_Rebuild

* Thu Jan 08 2015 Adam Williamson <awilliam@redhat.com> - 2.0.11-1
- new release 2.0.11

* Sat Jun 07 2014 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 2.0.8-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_21_Mass_Rebuild

* Wed Aug 07 2013 Adam Williamson <awilliam@redhat.com> - 2.0.8-1
- update to latest upstream, modernize spec

* Sun Aug 04 2013 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 2.0.5-10
- Rebuilt for https://fedoraproject.org/wiki/Fedora_20_Mass_Rebuild

* Thu Feb 14 2013 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 2.0.5-9
- Rebuilt for https://fedoraproject.org/wiki/Fedora_19_Mass_Rebuild

* Sat Jul 21 2012 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 2.0.5-8
- Rebuilt for https://fedoraproject.org/wiki/Fedora_18_Mass_Rebuild

* Sat Jan 14 2012 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 2.0.5-7
- Rebuilt for https://fedoraproject.org/wiki/Fedora_17_Mass_Rebuild

* Wed Feb 09 2011 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 2.0.5-6
- Rebuilt for https://fedoraproject.org/wiki/Fedora_15_Mass_Rebuild

* Thu Jul 22 2010 David Malcolm <dmalcolm@redhat.com> - 2.0.5-5
- Rebuilt for https://fedoraproject.org/wiki/Features/Python_2.7/MassRebuild

* Sun Jul 26 2009 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 2.0.5-4
- Rebuilt for https://fedoraproject.org/wiki/Fedora_12_Mass_Rebuild

* Thu Feb 26 2009 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 2.0.5-3
- Rebuilt for https://fedoraproject.org/wiki/Fedora_11_Mass_Rebuild

* Sat Nov 29 2008 Ignacio Vazquez-Abrams <ivazqueznet+rpm@gmail.com> - 2.0.5-2
- Rebuild for Python 2.6

* Wed Sep  3 2008 Tom "spot" Callaway <tcallawa@redhat.com> 2.0.5-1
- update to 2.0.5
- fix license tag

* Sat Jun 09 2007 Sean Reifschneider <jafo@tummy.com> 2.0.3-1
- Upgrading to 2.0.3 release.

* Thu Dec 21 2006 Kevin Fenzi <kevin@tummy.com> 1.7-6
- Rebuild for python 2.5

* Thu Aug 31 2006 Sean Reifschneider <jafo@tummy.com> 1.7-5
- Changing SPEC file where it strips out the shebang line.

* Thu Aug 31 2006 Sean Reifschneider <jafo@tummy.com> 1.7-4
- Adding -2 .spec file changelog entry.

* Wed Aug 30 2006 Sean Reifschneider <jafo@tummy.com> 1.7-3
- Changes based on review from Kevin Fenzi.

* Wed Aug 30 2006 Sean Reifschneider <jafo@tummy.com> 1.7-3
- Changes based on review from Kevin Fenzi.

* Tue Aug 29 2006 Sean Reifschneider <jafo@tummy.com> 1.7-1
- Initial RPM spec file.
