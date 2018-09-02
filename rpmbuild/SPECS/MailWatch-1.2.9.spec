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
Summary:       MailWatch Web Front-End for MailScanner
Name:          MailWatch
Version:       1.2.9
Epoch:         1
Release:       1.eFa%{?dist}
License:       GNU GPL v2
Group:         Applications/Utilities
URL:           https://github.com/mailwatch/MailWatch
Source:        %{name}-%{version}.tar.gz
BuildRoot:     %{_tmppath}/%{name}-%{version}-%{release}-root
Requires:      httpd >= 2.4.6
Requires:      php72u >= 7.2.5-2
Requires:      php72u-gd >= 7.2.5-2
Requires:      php72u-mbstring >= 7.2.5-2
Requires:      mariadb101u-server >= 10.1.32-1
Requires:      php72u-mysqlnd >= 7.2.5-2
Requires:      php72u-ldap >= 7.2.5-2
Requires:      php72u-xml >= 7.2.5-2
Requires:      perl(Encoding::FixLatin) >= 1.04-1

%description
MailWatch for MailScanner is a web-based front-end to MailScanner written in
PHP and MySQL and is available for free under the terms of the GNU Public
License.

It comes with a CustomConfig module for MailScanner which causes MailScanner
to log all message data (excluding body text) to a MySQL database which is then
queried by MailWatch for reporting and statistics.

%prep
%setup -q -n %{name}-%{version}

%build
# Nothing to do

%install
%{__rm} -rf %{buildroot}

# Remove any .gitignore files, if present
find . -name ".gitignore" | xargs rm

# Copy files to proper locations
mkdir -p %{buildroot}%{_datarootdir}/MailScanner/perl/custom
cp MailScanner_perl_scripts/MailWatch.pm %{buildroot}%{_datarootdir}/MailScanner/perl/custom
cp MailScanner_perl_scripts/SQLBlackWhiteList.pm %{buildroot}%{_datarootdir}/MailScanner/perl/custom
cp MailScanner_perl_scripts/SQLSpamSettings.pm %{buildroot}%{_datarootdir}/MailScanner/perl/custom
cp MailScanner_perl_scripts/MailWatchConf.pm %{buildroot}%{_datarootdir}/MailScanner/perl/custom

mkdir -p %{buildroot}/%{_bindir}/mailwatch
cp -a tools %{buildroot}%{_bindir}/mailwatch
rm -f %{buildroot}%{_bindir}/mailwatch/tools/Cron_jobs/INSTALL

mkdir -p %{buildroot}%{_sysconfdir}/cron.daily
echo "#!/bin/bash" > %{buildroot}%{_sysconfdir}/cron.daily/mailwatch
echo "/usr/bin/mailwatch/tools/Cron_jobs/mailwatch_quarantine_report.php >/dev/null 2>&1" >> %{buildroot}%{_sysconfdir}/cron.daily/mailwatch
echo "/usr/bin/mailwatch/tools/Cron_jobs/mailwatch_quarantine_maint.php --clean >/dev/null 2>&1" >> %{buildroot}%{_sysconfdir}/cron.daily/mailwatch
echo "/usr/bin/mailwatch/tools/Cron_jobs/mailwatch_db_clean.php >/dev/null 2>&1" >> %{buildroot}%{_sysconfdir}/cron.daily/mailwatch

mkdir -p %{buildroot}%{_sysconfdir}/cron.monthly
echo "#!/bin/bash" > %{buildroot}%{_sysconfdir}/cron.monthly/mailwatch
echo "UPDATEMAXDELAY=3600" >> %{buildroot}%{_sysconfdir}/cron.monthly/mailwatch
echo 'sleep $[( $RANDOM % $UPDATEMAXDELAY )+1]s' >> %{buildroot}%{_sysconfdir}/cron.monthly/mailwatch
echo "/usr/bin/mailwatch/tools/Cron_jobs/mailwatch_geoip_update.php >/dev/null 2>&1" >> %{buildroot}%{_sysconfdir}/cron.monthly/mailwatch
echo "/usr/bin/mailwatch/tools/Cron_jobs/mailwatch_update_sarules.php >/dev/null 2>&1" >> %{buildroot}%{_sysconfdir}/cron.monthly/mailwatch

mkdir -p  %{buildroot}%{_sysconfdir}/cron.d
echo "#!/bin/bash" > %{buildroot}%{_sysconfdir}/cron.d/msre_reload
echo "*/5 * * * *   root    /usr/bin/mailwatch/tools/MailScanner_rule_editor/msre_reload.sh" >> %{buildroot}%{_sysconfdir}/cron.d/msre_reload

mkdir -p %{buildroot}%{_localstatedir}/www/html
cp -a mailscanner %{buildroot}%{_localstatedir}/www/html/mailscanner
mv %{buildroot}%{_localstatedir}/www/html/mailscanner/conf.php.example %{buildroot}%{_localstatedir}/www/html/mailscanner/conf.php
rm -rf %{buildroot}%{_localstatedir}/www/html/mailscanner/docs

mkdir -p %{buildroot}%{_sysconfdir}/cron.hourly
cat > %{buildroot}%{_sysconfdir}/cron.hourly/mailwatch_relay.sh << 'EOF'
#!/bin/bash

/usr/bin/php /usr/bin/mailwatch/tools/Postfix_relay/mailwatch_postfix_relay.php --refresh
/usr/bin/php /usr/bin/mailwatch/tools/Postfix_relay/mailwatch_mailscanner_relay.php --refresh
EOF

%pre
# Nothing to do

%post
# Nothing to do

%clean
%{__rm} -rf %{buildroot}

%files
%defattr(-, root, root)
%doc CHANGELOG.md CONTRIBUTING.md LICENSE.md README.md
%attr(0755, root, root) %{_bindir}/mailwatch/tools/Cron_jobs/*
%attr(0755, root, root) %{_sysconfdir}/cron.d/msre_reload
%attr(0755, root, root) %{_sysconfdir}/cron.daily/mailwatch
%attr(0755, root, root) %{_sysconfdir}/cron.monthly/mailwatch
%attr(0755, root, root) %{_sysconfdir}/cron.hourly/mailwatch_relay.sh
%{_datarootdir}/MailScanner/perl/custom/*
%{_bindir}/mailwatch/tools/MailScanner_rule_editor/msre_reload.crontab
%{_bindir}/mailwatch/tools/MailScanner_rule_editor/INSTALL
%attr(0755, root, root) %{_bindir}/mailwatch/tools/MailScanner_rule_editor/msre_reload.sh
%{_bindir}/mailwatch/tools/Postfix_relay/*
%{_bindir}/mailwatch/tools/Sendmail-Exim_queue/*
%{_bindir}/mailwatch/tools/Sendmail_relay/*
%{_bindir}/mailwatch/tools/LDAP/*
%{_bindir}/mailwatch/tools/sudo/*
%{_bindir}/mailwatch/tools/MailScanner_config/*
%config(noreplace) %{_localstatedir}/www/html/mailscanner/conf.php
%attr(0775, root, apache) %{_localstatedir}/www/html/mailscanner/images
%attr(0775, root, apache) %{_localstatedir}/www/html/mailscanner/temp
%{_localstatedir}/www/html/mailscanner/.htaccess
%{_localstatedir}/www/html/mailscanner/auto-release.php
%{_localstatedir}/www/html/mailscanner/bayes_info.php
%{_localstatedir}/www/html/mailscanner/checklogin.php
%{_localstatedir}/www/html/mailscanner/clamav.awk
%{_localstatedir}/www/html/mailscanner/clamav_status.php
%{_localstatedir}/www/html/mailscanner/database.php
%{_localstatedir}/www/html/mailscanner/detail.php
%{_localstatedir}/www/html/mailscanner/docs.php
%{_localstatedir}/www/html/mailscanner/do_message_ops.php
%{_localstatedir}/www/html/mailscanner/favicon.ico
%{_localstatedir}/www/html/mailscanner/filter.inc.php
%{_localstatedir}/www/html/mailscanner/f-prot.awk
%{_localstatedir}/www/html/mailscanner/f-prot_status.php
%{_localstatedir}/www/html/mailscanner/f-secure.awk
%{_localstatedir}/www/html/mailscanner/f-secure_status.php
%{_localstatedir}/www/html/mailscanner/functions.php
%{_localstatedir}/www/html/mailscanner/geoip_update.php
%{_localstatedir}/www/html/mailscanner/graphgenerator.inc.php
%{_localstatedir}/www/html/mailscanner/index.php
%{_localstatedir}/www/html/mailscanner/js
%{_localstatedir}/www/html/mailscanner/languages
%{_localstatedir}/www/html/mailscanner/lib
%{_localstatedir}/www/html/mailscanner/lists.php
%{_localstatedir}/www/html/mailscanner/login.function.php
%{_localstatedir}/www/html/mailscanner/login.php
%{_localstatedir}/www/html/mailscanner/logout.php
%{_localstatedir}/www/html/mailscanner/mailq.php
%{_localstatedir}/www/html/mailscanner/mcafee.awk
%{_localstatedir}/www/html/mailscanner/mcafee_status.php
%{_localstatedir}/www/html/mailscanner/mcp_rules_update.php
%{_localstatedir}/www/html/mailscanner/msconfig.php
%{_localstatedir}/www/html/mailscanner/msmail.inc.php
%{_localstatedir}/www/html/mailscanner/msmailq.php
%{_localstatedir}/www/html/mailscanner/ms_lint.php
%{_localstatedir}/www/html/mailscanner/msre_edit.php
%{_localstatedir}/www/html/mailscanner/msre_table_functions.php
%{_localstatedir}/www/html/mailscanner/msre_index.php
%{_localstatedir}/www/html/mailscanner/msrule.php
%{_localstatedir}/www/html/mailscanner/mtalogprocessor.inc.php
%{_localstatedir}/www/html/mailscanner/mysql_status.php
%{_localstatedir}/www/html/mailscanner/other.php
%{_localstatedir}/www/html/mailscanner/password_reset.php
%{_localstatedir}/www/html/mailscanner/postfix.inc.php
%{_localstatedir}/www/html/mailscanner/postfixmailq.php
%{_localstatedir}/www/html/mailscanner/quarantine_action.php
%{_localstatedir}/www/html/mailscanner/quarantine.php
%{_localstatedir}/www/html/mailscanner/quarantine_report.inc.php
%{_localstatedir}/www/html/mailscanner/rep_audit_log.php
%{_localstatedir}/www/html/mailscanner/rep_mcp_rule_hits.php
%{_localstatedir}/www/html/mailscanner/rep_mcp_score_dist.php
%{_localstatedir}/www/html/mailscanner/rep_message_listing.php
%{_localstatedir}/www/html/mailscanner/rep_message_ops.php
%{_localstatedir}/www/html/mailscanner/reports.php
%{_localstatedir}/www/html/mailscanner/rep_previous_day.php
%{_localstatedir}/www/html/mailscanner/rep_sa_rule_hits.php
%{_localstatedir}/www/html/mailscanner/rep_sa_score_dist.php
%{_localstatedir}/www/html/mailscanner/rep_top_mail_relays.php
%{_localstatedir}/www/html/mailscanner/rep_top_recipient_domains_by_quantity.php
%{_localstatedir}/www/html/mailscanner/rep_top_recipient_domains_by_volume.php
%{_localstatedir}/www/html/mailscanner/rep_top_recipients_by_quantity.php
%{_localstatedir}/www/html/mailscanner/rep_top_recipients_by_volume.php
%{_localstatedir}/www/html/mailscanner/rep_top_sender_domains_by_quantity.php
%{_localstatedir}/www/html/mailscanner/rep_top_sender_domains_by_volume.php
%{_localstatedir}/www/html/mailscanner/rep_top_senders_by_quantity.php
%{_localstatedir}/www/html/mailscanner/rep_top_senders_by_volume.php
%{_localstatedir}/www/html/mailscanner/rep_top_viruses.php
%{_localstatedir}/www/html/mailscanner/rep_total_mail_by_date.php
%{_localstatedir}/www/html/mailscanner/rep_viruses.php
%{_localstatedir}/www/html/mailscanner/robots.txt
%{_localstatedir}/www/html/mailscanner/rpcserver.php
%{_localstatedir}/www/html/mailscanner/sa_lint.php
%{_localstatedir}/www/html/mailscanner/sa_rules_update.php
%{_localstatedir}/www/html/mailscanner/sf_version.php
%{_localstatedir}/www/html/mailscanner/sophos.awk
%{_localstatedir}/www/html/mailscanner/sophos_status.php
%{_localstatedir}/www/html/mailscanner/status.php
%{_localstatedir}/www/html/mailscanner/style.css
%{_localstatedir}/www/html/mailscanner/syslog_parser.inc.php
%{_localstatedir}/www/html/mailscanner/user_manager.php
%{_localstatedir}/www/html/mailscanner/viewmail.php
%{_localstatedir}/www/html/mailscanner/viewpart.php

%changelog
* Sun Jul 8 2018 Shawn Iverson <shawniverson@efa-project.org> - 1.2.9-1
- Update to MailWatch 1.2.9 and fix case

* Sat May 26 2018 Shawn Iverson <shawniverson@efa-project.org> - 1.2.7-7
- Updated to use IUS repository for dependencies

* Sat Jan 27 2018 Shawn Iverson <shawniverson@efa-project.org> - 1.2.7-6
- Repackage to include mailwatch_update_sarules.php and forked ps fix

* Mon Jan 15 2018 Shawn Iverson <shawniverson@efa-project.org> - 1.2.7-5
- Add php-xml as a requirement

* Mon Jan 15 2018 Shawn Iverson <shawniverson@efa-project.org> - 1.2.7-4
- Update version requirements

* Sun Jan 14 2018 Shawn Iverson <shawniverson@efa-project.org> - 1.2.7-3
- Fix paths for postfix relay scripts

* Sun Jan 14 2018 Shawn Iverson <shawniverson@efa-project.org> - 1.2.7-2
- Fix msre_reload.sh and include msre_reload crontab

* Sat Jan 13 2018 Shawn Iverson <shawniverson@efa-project.org> - 1.2.7-1
- MailWatch Update

* Sun Mar 19 2017 Shawn Iverson <shawniverson@gmail.com> - 1.2.0-4
- Mailwatch Update

* Sun Feb 12 2017 Shawn Iverson <shawniverson@gmail.com> - 1.2.0-3
- Correct permissions on images

* Sun Feb 12 2017 Shawn Iverson <shawniverson@gmail.com> - 1.2.0-2
- Correct permissions on temp

* Sat Jan 21 2017 Shawn Iverson <shawniverson@gmail.com> - 1.2.0-1
- Initial Build for eFa https://efa-project.org
