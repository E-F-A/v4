Summary:       SQLgrey is a postfix grey-listing policy service.
Name:          sqlgrey
Version:       1.8.0
Epoch:         1
Release:       1.eFa%{?dist}
License:       GPL
Vendor:        Lionel Bouton <lionel-dev@bouton.name>
Url:           http://sqlgrey.sourceforge.net
Group:         System Utils
Source:        %{name}-%{version}.tar.gz
BuildRoot:     %{_tmppath}/%{name}-%{version}-%{release}-root
Requires:      postfix >= 3.1.3
Requires:      mariadb-server >= 5.5.52 

%description
SQLgrey is a Postfix grey-listing policy service with auto-white-listing
written in Perl with SQL database as storage backend.
Greylisting stops 50 to 90 % junk mails (spam and virus) before they
reach your Postfix server (saves BW, user time and CPU time).

%prep
%setup -q -n %{name}-%{version}

%build
make

%install
make rh-install ROOTDIR=$RPM_BUILD_ROOT

%pre
getent group sqlgrey > /dev/null || /usr/sbin/groupadd sqlgrey
getent passwd sqlgrey > /dev/null || /usr/sbin/useradd -g sqlgrey \
     -d /var/sqlgrey -s /bin/true sqlgrey 

%postun
if [ $1 = 0 ]; then
   if [ `getent passwd sqlgrey | wc -l` = 1 ]; then
      /usr/sbin/userdel sqlgrey
   fi
   if [ `getent group sqlgrey | wc -l` = 1 ]; then
      /usr/sbin/groupdel sqlgrey
   fi
fi

%clean
%{__rm} -rf %{buildroot}

%files
%defattr(-,root,root)
/etc/init.d/sqlgrey
/usr/sbin/sqlgrey
/usr/sbin/update_sqlgrey_config
/usr/bin/sqlgrey-logstats.pl
/usr/share/man/man1/sqlgrey.1*
%doc README* HOWTO Changelog FAQ TODO
%defattr(644,root,root)
%config(noreplace) /etc/sqlgrey/sqlgrey.conf
/etc/sqlgrey/clients_ip_whitelist
/etc/sqlgrey/clients_fqdn_whitelist
/etc/sqlgrey/discrimination.regexp
/etc/sqlgrey/dyn_fqdn.regexp
/etc/sqlgrey/smtp_server.regexp
/etc/sqlgrey/README

%changelog
* Sun Jan 15 2017 Shawn Iverson <shawniverson@gmail.com> - 1.8.0-1
- Updated for eFa https://efa-project.org

* Mon Feb 13 2012 Martin Matuska <martin@matuska.org>
 - 1.8.0 release
 - Allow to specify complete DSN in configuration file
 - Support listening on UNIX sockets
 - Support pidfile command line argument

* Mon Aug 17 2009 Michal Ludvig <mludvig@logix.net.nz>
 - 1.7.7 release getting ready
 - Reworked "smart" IPv6 address handling.
 - Added IPv6 address support for clients_ip_whitelist(.local) file

* Sun Aug 05 2007 Lionel Bouton <lionel-dev@bouton.name>
 - 1.7.6 release
 - numerous bugfixes, update to last current release version

* Wed Nov 16 2005 Lionel Bouton <lionel-dev@bouton.name>
 - 1.7.3 release
 - fixes for a crash with '*' in email adresses

* Tue Oct 25 2005 Lionel Bouton <lionel-dev@bouton.name>
 - 1.7.2 release
 - fixes for several errors in logging
 - clean_method ported from 1.6.x

* Thu Sep 15 2005 Lionel Bouton <lionel-dev@bouton.name>
 - 1.7.1 release
 - fix for race condition in multiple instances configurations
 - fix for weekly stats

* Tue Jun 21 2005 Lionel Bouton <lionel-dev@bouton.name>
 - 1.7.0 release
 - now continue if the DB isn't available at startup time
 - based on 1.6.0 with Michel Bouissou's work:
  . better connect cleanup when creating AWL entries
  . source IP throttling

* Thu Jun 16 2005 Lionel Bouton <lionel-dev@bouton.name>
 - 1.6.0 release
 - fix for alternate conf_dir
 - fix for timestamp handling in log parser
 - log parser cleanup
 - added README.PERF and documentation cleanup

* Tue Jun 07 2005 Lionel Bouton <lionel-dev@bouton.name>
 - 1.5.9 release
 - fix for MySQL's mishandling of timestamps
 - better log parser

* Thu Jun 02 2005 Lionel Bouton <lionel-dev@bouton.name>
 - 1.5.8 release
 - fix for Makefile: rpmbuild didn't work

* Wed Jun 01 2005 Lionel Bouton <lionel-dev@bouton.name>
 - 1.5.7 release
 - fix for a memory leak
 - config directory now user-configurable
 - preliminary log analyser

* Mon May 02 2005 Lionel Bouton <lionel-dev@bouton.name>
 - 1.5.6 release
 - fix for MySQL disconnection crash
 - IPv6 support
 - Optin/optout support

* Tue Apr 25 2005 Lionel Bouton <lionel-dev@bouton.name>
 - 1.5.5 release
 - small fix for SRS (again!)
 - small fix for deverp code
 - log types

* Tue Mar 15 2005 Lionel Bouton <lionel-dev@bouton.name>
 - 1.5.4 release
 - fix for regexp compilation (regexp in fqdn_whitelists didn't work)
  
* Sat Mar 05 2005 Lionel Bouton <lionel-dev@bouton.name>
 - 1.5.3 release
 - the cleanup is now done in a separate process to avoid stalling the service

* Thu Mar 03 2005 Lionel Bouton <lionel-dev@bouton.name>
 - 1.5.2 release
 - optimize SQL queries by avoiding some now() function calls

* Wed Mar 02 2005 Lionel Bouton <lionel-dev@bouton.name>
 - 1.5.1 release
 - replaced smart algorithm with Michel Bouissou's one

* Wed Feb 23 2005 Lionel Bouton <lionel-dev@bouton.name>
 - 1.5.0 release
 - drop support for obsolete command-line parameters
 - migrate databases to a new layout :
  . first_seen added to the AWLs
  . optimize AWL Primary Keys
  . add indexes

* Mon Feb 21 2005 Lionel Bouton <lionel-dev@bouton.name>
 - 1.4.8 release
 - AWL performance bugfix
 - bad handling of database init errors fixed
   
* Fri Feb 18 2005 Lionel Bouton <lionel-dev@bouton.name>
 - 1.4.7 release
 - MAIL FROM: <> bugfix
  
* Fri Feb 18 2005 Lionel Bouton <lionel-dev@bouton.name>
 - 1.4.6 release
 - update_sqlgrey_whitelists fix
 - removed superfluous regexp in deVERP code

* Thu Feb 17 2005 Lionel Bouton <lionel-dev@bouton.name>
 - 1.4.5 release
 - update_sqlgrey_whitelists temporary directory fixes from Michel Bouissou
 - return code configurable patch from Michel Bouissou
 - VERP and SRS tuning, with input from Michel Bouissou
 - VERP and SRS normalisation is used only in the AWLs

* Mon Feb 14 2005 Lionel Bouton <lionel-dev@bouton.name>
 - 1.4.4 release
 - Autowhitelists understand SRS
 - more VERP support for autowhitelists
 - SQLgrey can warn by mail when the database is unavailable
 - update_sqlgrey_whitelists doesn't rely on mktemp's '-t' parameter anymore.

* Sun Feb 06 2005 Lionel Bouton <lionel-dev@bouton.name>
 - 1.4.3 release
 - log to stdout when not in daemon mode
 - added update_sqlgrey_whitelists script
   whitelists can now be fetched from repositories
      
* Thu Jan 13 2005 Lionel Bouton <lionel-dev@bouton.name>
 - 1.4.2 release
 - Better cleanup logging from Rene Joergensen
 - Fix for Syslog.pm error messages at init time
 - Fix doc packaging in RPM

* Tue Jan 11 2005 Lionel Bouton <lionel-dev@bouton.name>
 - 1.4.1 release
 - fix for invalid group id messages from Øystein Viggen
 - allow reloading whitelists with SIGUSR1
 - db_maintdelay user-configurable
 - don't log pid anymore

* Fri Dec 10 2004 Lionel Bouton <lionel-dev@bouton.name>
 - 1.4.0 release
 - windows for SQL injection fix (reported by Øystein Viggen)
 - spec file tuning inspired by Derek Battams

* Tue Nov 30 2004 Lionel Bouton <lionel-dev@bouton.name>
 - 1.3.6 release
 - whitelist for FQDN as well as IP
 - 3 different greylisting algorithms
   (RFE from Derek Battams)

* Mon Nov 22 2004 Lionel Bouton <lionel-dev@bouton.name>
 - 1.3.4 release
 - ip whitelisting

* Mon Nov 22 2004 Lionel Bouton <lionel-dev@bouton.name>
 - 1.3.3 release
 - preliminary whitelist support

* Wed Nov 17 2004 Lionel Bouton <lionel-dev@bouton.name>
 - 1.3.2 release
 - RPM packaging fixed
 - DB connection pbs don't crash SQLgrey anymore

* Thu Nov 11 2004 Lionel Bouton <lionel-dev@bouton.name>
 - 1.3.0 release
 - Database schema slightly changed,
 - Automatic database schema upgrade framework

* Sun Nov 07 2004 Lionel Bouton <lionel-dev@bouton.name>
 - 1.2.0 release
 - SQL code injection protection
 - better DBI error reporting
 - better VERP support
 - small log related typo fix
 - code cleanups

* Mon Oct 11 2004 Lionel Bouton <lionel-dev@bouton.name>
 - 1.1.2 release
 - pidfile handling code bugfix

* Mon Sep 27 2004 Lionel Bouton <lionel-dev@bouton.name>
 - 1.1.1 release
 - MySQL-related SQL syntax bugfix

* Tue Sep 21 2004 Lionel Bouton <lionel-dev@bouton.name>
 - 1.1.0 release
 - SQLite support (RFE from Klaus Alexander Seistrup)

* Tue Sep 14 2004 Lionel Bouton <lionel-dev@bouton.name>
 - 1.0.1 release
 - man page cleanup

* Tue Sep 07 2004 Lionel Bouton <lionel-dev@bouton.name>
 - pushed default max-age from 12 to 24 hours

* Sat Aug 07 2004 Lionel Bouton <lionel-dev@bouton.name>
 - bug fix for space trimming values from database

* Tue Aug 03 2004 Lionel Bouton <lionel-dev@bouton.name>
 - trim spaces before logging possible spams
 - v1.0 added license reference at the top
   at savannah request

* Fri Jul 30 2004 Lionel Bouton <lionel-dev@bouton.name>
 - Bugfix: couldn't match on undefined sender
 - debug code added

* Fri Jul 30 2004 Lionel Bouton <lionel-dev@bouton.name>
 - Removed NetAddr::IP dependency at savannah request

* Sat Jul 17 2004 Lionel Bouton <lionel-dev@bouton.name>
 - Default max-age pushed to 12 hours instead of 5
   (witnessed more than 6 hours for a mailing-list subscription
   system)

* Fri Jul 02 2004 Lionel Bouton <lionel-dev@bouton.name>
 - Documentation

* Thu Jul 01 2004 Lionel Bouton <lionel-dev@bouton.name>
 - PostgreSQL support added

* Tue Jun 29 2004 Lionel Bouton <lionel-dev@bouton.name>
 - various cleanups and bug hunting

* Mon Jun 28 2004 Lionel Bouton <lionel-dev@bouton.name>
 - 2-level AWL support

* Sun Jun 27 2004 Lionel Bouton <lionel-dev@bouton.name>
 - Initial Version, replaced BDB by mysql in postgrey

