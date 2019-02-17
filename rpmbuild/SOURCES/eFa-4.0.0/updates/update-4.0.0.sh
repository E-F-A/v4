#!/bin/sh
#-----------------------------------------------------------------------------#
# eFa 4.0.0-x cumulative updates script
#-----------------------------------------------------------------------------#
# Copyright (C) 2013~2019 https://efa-project.org
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#-----------------------------------------------------------------------------#
instancetype=$(/sbin/virt-what)

retval=0

function execcmd()
{
eval $cmd && [[ $? -ne 0 ]] && echo "$cmd" && retval=1
}

function randompw()
{
  PASSWD=""
  PASSWD=`openssl rand -base64 32`
}
# +---------------------------------------------------+

# Move symlink for cron-dccd
if [[ -e /etc/cron.monthly/cron-dccd ]]; then
  cmd='rm -f /etc/cron.monthly/cron-dccd'
  execcmd
  cmd='ln -s /var/dcc/libexec/cron-dccd /etc/cron.daily/cron-dccd'
  execcmd
fi

# Tweak mariadb configuration
# Remove limits on mariadb
cmd='mkdir -p /etc/systemd/system/mariadb.service.d'
execcmd
if [[ ! -f /etc/systemd/system/mariadb.service.d/limit.conf ]]; then
  cat > /etc/systemd/system/mariadb.service.d/limit.conf << 'EOF'
[Service]
LimitNOFILE=infinity
LimitMEMLOCK=infinity
EOF
  [[ $? -ne 0 ]] && echo "cat > /etc/systemd/system/mariadb.service.d/limit.conf" && retval=1
else
  cmd='sed -i "/^\[Service\]$/ a\LimitMEMLOCK=infinity" /etc/systemd/system/mariadb.service.d/limit.conf'
  [[ -z $(grep ^LimitMEMLOCK /etc/systemd/system/mariadb.service.d/limit.conf) ]] && execcmd
  cmd='sed -i "/^\[Service\]$/ a\LimitNOFILE=infinity" /etc/systemd/system/mariadb.service.d/limit.conf'
  [[ -z $(grep ^LimitNOFILE /etc/systemd/system/mariadb.service.d/limit.conf) ]] && execcmd
fi

# Performance tweaks
# Remove bad entries from a malformed eFa-Base rpm modification
cmd='sed -i "/^\stmp_table_size/d" /etc/my.cnf.d/mariadb-server.cnf'
execcmd
cmd='sed -i "/^\sthread_cache_size/d" /etc/my.cnf.d/mariadb-server.cnf'
execcmd
cmd='sed -i "/^\ssort_buffer_size/d" /etc/my.cnf.d/mariadb-server.cnf'
execcmd
cmd='sed -i "/^\sskip-host-cache/d" /etc/my.cnf.d/mariadb-server.cnf'
execcmd
cmd='sed -i "/^\sskip-external-locking/d" /etc/my.cnf.d/mariadb-server.cnf'
execcmd
cmd='sed -i "/^\sread_rnd_buffer_size/d" /etc/my.cnf.d/mariadb-server.cnf'
execcmd
cmd='sed -i "/^\sread_buffer_size/d" /etc/my.cnf.d/mariadb-server.cnf'
execcmd
cmd='sed -i "/^\squery_cache_type/d" /etc/my.cnf.d/mariadb-server.cnf'
execcmd
cmd='sed -i "/^\squery_cache_size/d" /etc/my.cnf.d/mariadb-server.cnf'
execcmd
cmd='sed -i "/^\smax_heap_table_size/d" /etc/my.cnf.d/mariadb-server.cnf'
execcmd
cmd='sed -i "/^\smax_allowed_packet/d" /etc/my.cnf.d/mariadb-server.cnf'
execcmd
cmd='sed -i "/^\skey_cache_segments/d" /etc/my.cnf.d/mariadb-server.cnf'
execcmd
cmd='sed -i "/^\sjoin_buffer_size/d" /etc/my.cnf.d/mariadb-server.cnf'
execcmd
cmd='sed -i "/^\sinnodb_log_file_size/d" /etc/my.cnf.d/mariadb-server.cnf'
execcmd
cmd='sed -i "/^\sinnodb_log_buffer_size/d" /etc/my.cnf.d/mariadb-server.cnf'
execcmd
cmd='sed -i "/^\sinnodb_file_per_table/d" /etc/my.cnf.d/mariadb-server.cnf'
execcmd
cmd='sed -i "/^\sinnodb_buffer_pool_size/d" /etc/my.cnf.d/mariadb-server.cnf'
execcmd
cmd='sed -i "/^\sinnodb_buffer_pool_instances/d" /etc/my.cnf.d/mariadb-server.cnf'
execcmd
cmd='sed -i "/^\sinnodb-defragment/d" /etc/my.cnf.d/mariadb-server.cnf'
execcmd

# Ensure tweaks are in place
cmd='sed -i "/^\[mariadb-10.1\]$/ a\tmp_table_size = 32M" /etc/my.cnf.d/mariadb-server.cnf'
[[ -z $(grep ^tmp_table_size /etc/my.cnf.d/mariadb-server.cnf) ]] && execcmd
cmd='sed -i "/^\[mariadb-10.1\]$/ a\thread_cache_size = 16" /etc/my.cnf.d/mariadb-server.cnf'
[[ -z $(grep ^thread_cache_size /etc/my.cnf.d/mariadb-server.cnf) ]] && execcmd
cmd='sed -i "/^\[mariadb-10.1\]$/ a\sort_buffer_size = 4M" /etc/my.cnf.d/mariadb-server.cnf'
[[ -z $(grep ^sort_buffer_size /etc/my.cnf.d/mariadb-server.cnf) ]] && execcmd
cmd='sed -i "/^\[mariadb-10.1\]$/ a\skip-host-cache" /etc/my.cnf.d/mariadb-server.cnf'
[[ -z $(grep ^skip-host-cache /etc/my.cnf.d/mariadb-server.cnf) ]] && execcmd
cmd='sed -i "/^\[mariadb-10.1\]$/ a\skip-external-locking" /etc/my.cnf.d/mariadb-server.cnf'
[[ -z $(grep ^skip-external-locking /etc/my.cnf.d/mariadb-server.cnf) ]] && execcmd
cmd='sed -i "/^\[mariadb-10.1\]$/ a\read_rnd_buffer_size = 1M" /etc/my.cnf.d/mariadb-server.cnf'
[[ -z $(grep ^read_rnd_buffer_size /etc/my.cnf.d/mariadb-server.cnf) ]] && execcmd
cmd='sed -i "/^\[mariadb-10.1\]$/ a\read_buffer_size = 2M" /etc/my.cnf.d/mariadb-server.cnf'
[[ -z $(grep ^read_buffer_size /etc/my.cnf.d/mariadb-server.cnf) ]] && execcmd
cmd='sed -i "/^\[mariadb-10.1\]$/ a\query_cache_type = OFF" /etc/my.cnf.d/mariadb-server.cnf'
[[ -z $(grep ^query_cache_type /etc/my.cnf.d/mariadb-server.cnf) ]] && execcmd
cmd='sed -i "/^\[mariadb-10.1\]$/ a\query_cache_size = 0M" /etc/my.cnf.d/mariadb-server.cnf'
[[ -z $(grep ^query_cache_size /etc/my.cnf.d/mariadb-server.cnf) ]] && execcmd
cmd='sed -i "/^\[mariadb-10.1\]$/ a\max_heap_table_size = 32M" /etc/my.cnf.d/mariadb-server.cnf'
[[ -z $(grep ^max_heap_table_size /etc/my.cnf.d/mariadb-server.cnf) ]] && execcmd
cmd='sed -i "/^\[mariadb-10.1\]$/ a\max_allowed_packet = 16M" /etc/my.cnf.d/mariadb-server.cnf'
[[ -z $(grep ^max_allowed_packet /etc/my.cnf.d/mariadb-server.cnf) ]] && execcmd
cmd='sed -i "/^\[mariadb-10.1\]$/ a\key_cache_segments = 4" /etc/my.cnf.d/mariadb-server.cnf'
[[ -z $(grep ^key_cache_segments /etc/my.cnf.d/mariadb-server.cnf) ]] && execcmd
cmd='sed -i "/^\[mariadb-10.1\]$/ a\join_buffer_size = 512K" /etc/my.cnf.d/mariadb-server.cnf'
[[ -z $(grep ^join_buffer_size /etc/my.cnf.d/mariadb-server.cnf) ]] && execcmd
cmd='sed -i "/^\[mariadb-10.1\]$/ a\innodb_log_file_size = 125M" /etc/my.cnf.d/mariadb-server.cnf'
[[ -z $(grep ^innodb_log_file_size /etc/my.cnf.d/mariadb-server.cnf) ]] && execcmd
cmd='sed -i "/^\[mariadb-10.1\]$/ a\innodb_log_buffer_size = 32M" /etc/my.cnf.d/mariadb-server.cnf'
[[ -z $(grep ^innodb_log_buffer_size /etc/my.cnf.d/mariadb-server.cnf) ]] && execcmd
cmd='sed -i "/^\[mariadb-10.1\]$/ a\innodb_file_per_table = 1" /etc/my.cnf.d/mariadb-server.cnf'
[[ -z $(grep ^innodb_file_per_table /etc/my.cnf.d/mariadb-server.cnf) ]] && execcmd
cmd='sed -i "/^\[mariadb-10.1\]$/ a\innodb_buffer_pool_size = 1G" /etc/my.cnf.d/mariadb-server.cnf'
[[ -z $(grep ^innodb_buffer_pool_size /etc/my.cnf.d/mariadb-server.cnf) ]] && execcmd
cmd='sed -i "/^\[mariadb-10.1\]$/ a\innodb_buffer_pool_instances = 1" /etc/my.cnf.d/mariadb-server.cnf'
[[ -z $(grep ^innodb_buffer_pool_instances /etc/my.cnf.d/mariadb-server.cnf) ]] && execcmd
cmd='sed -i "/^\[mariadb-10.1\]$/ a\innodb-defragment = 1" /etc/my.cnf.d/mariadb-server.cnf'
[[ -z $(grep ^innodb-defragment /etc/my.cnf.d/mariadb-server.cnf) ]] && execcmd
cmd='sed -i "/^\[mariadb-10.1\]$/ a\bind-address = 127.0.0.1" /etc/my.cnf.d/mariadb-server.cnf'
[[ -z $(grep ^bind-address /etc/my.cnf.d/mariadb-server.cnf) ]] &&  execcmd

# Show version in MailWatch
cmd="sed -i \"/^define('SHOW_SFVERSION',/ c\define('SHOW_SFVERSION', true);\" /var/www/html/mailscanner/conf.php"
execcmd

# Refresh /root/.my.cnf
cmd='echo "[client]" > /root/.my.cnf'
execcmd
cmd='echo "user=root" >> /root/.my.cnf'
execcmd
cmd="echo \"password=$(grep ^MYSQLROOTPWD /etc/eFa/MySQL-Config | sed -e 's/^.*://')\" >> /root/.my.cnf"
execcmd
cmd='chmod 400 /root/.my.cnf'
execcmd

# Cleanup
cmd='rm -rf /var/www/eFaInit'
[[ -d /var/www/eFaInit ]] && execcmd
cmd='rm -f /usr/sbin/eFa-Init'
[[ -f /usr/sbin/eFa-Init ]] && execcmd
cmd='m -f /usr/sbin/eFa-Commit'
[[ -f /usr/sbin/eFa-Commit ]] && execcmd

# Autolearn
cmd='echo "bayes_auto_learn                   1" >> /etc/MailScanner/spamassassin.conf'
[[ -z $(grep ^bayes_auto_learn /etc/MailScanner/spamassassin.conf) ]] && execcmd
cmd='echo "bayes_auto_learn_threshold_nonspam 0.1" >> /etc/MailScanner/spamassassin.conf'
[[ -z $(grep ^bayes_auto_learn_threshold_nonspam /etc/MailScanner/spamassassin.conf) ]] && execcmd
cmd='echo "bayes_auto_learn_threshold_spam    6" >> /etc/MailScanner/spamassassin.conf'
[[ -z $(grep ^bayes_auto_learn_threshold_spam /etc/MailScanner/spamassassin.conf) ]] && execcmd
# Set cron MAILTO
cmd='sed -i "/^MAILTO=root/ c\MAILTO=root" /etc/crontab'
execcmd
cmd='sed -i "/^MAILTO=root/ c\MAILTO=root" /etc/anacrontab'
[[ -f /etc/anacrontab ]] && execcmd

# Set postfix error_notice_recipient
cmd='postconf -e "error_notice_recipient = root"'
execcmd

# Update SELinux
if [[ $instancetype != "lxc" ]]; then
  cmd='checkmodule -M -m -o /var/eFa/lib/selinux/eFa.mod /var/eFa/lib/selinux/eFa.te'
  execcmd
  cmd='semodule_package -o /var/eFa/lib/selinux/eFa.pp -m /var/eFa/lib/selinux/eFa.mod -f /var/eFa/lib/selinux/eFa.fc'
  execcmd
  cmd='semodule -i /var/eFa/lib/selinux/eFa.pp'
  execcmd
fi

# Update MailWatch after MailWatch rpm update applies
if [[ -z $(grep MailWatch-Config /usr/share/MailScanner/perl/custom/MailWatchConf.pm) ]]; then
  cmd="sed -i \"/^my (\$db_user) =/ c\my (\$db_user) = 'mailwatch';\" /usr/share/MailScanner/perl/custom/MailWatchConf.pm"
  execcmd
  cmd="sed -i \"/^my (\\\$db_pass) =/ c\my (\\\$fh);\nmy (\\\$pw_config) = '/etc/eFa/MailWatch-Config';\nopen(\\\$fh, \\\"<\\\", \\\$pw_config);\nif(\!\\\$fh) {\n  MailScanner::Log::WarnLog(\\\"Unable to open %s to retrieve password\\\", \\\$pw_config);\n  return;\n}\nmy (\\\$db_pass) = grep(/^MAILWATCHSQLPWD/,<\\\$fh>);\n\\\$db_pass =~ s/MAILWATCHSQLPWD://;\n\\\$db_pass =~ s/\\\n//;\nclose(\\\$fh);\" /usr/share/MailScanner/perl/custom/MailWatchConf.pm"
  execcmd
fi

cmd='cd /var/www/html/sgwi && rm -f ./images/mailwatch-logo.png && ln -s ../../mailscanner/images/mailwatch-logo.png ./images/mailwatch-logo.png'
execcmd

# Disable prefork mpm and replace with event mpm
cmd="sed -i 's|^LoadModule mpm_prefork_module modules/mod_mpm_prefork.so|#&|' /etc/httpd/conf.modules.d/00-mpm.conf"
execcmd
cmd="sed -i 's|^#LoadModule mpm_event_module modules/mod_mpm_event.so|LoadModule mpm_event_module modules/mod_mpm_event.so|' /etc/httpd/conf.modules.d/00-mpm.conf"
execcmd

# Add php-fpm to mtagroup
cmd='usermod -G mtagroup php-fpm'
execcmd

# Fix sudoers for php-fpm
cmd="sed -i 's/apache/php-fpm/' /etc/sudoers.d/mailwatch"
execcmd

# Fix bad sed for earlier base package
cmd="sed -i '/^;env\[PATH\] =/ c\env[PATH] = /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin' /etc/php-fpm.d/www.conf"
execcmd

# Fix extraneous session_start in grey.php
cmd='sed -i "/^session_start();$/d" /var/www/html/mailscanner/grey.php'
execcmd

# Add sqlgrey systemd override
cmd='mkdir -p /etc/systemd/system/sqlgrey.service.d'
execcmd
cmd='echo "[Unit]" > /etc/systemd/system/sqlgrey.service.d/override.conf'
execcmd
cmd='echo "After=syslog.target network.target mariadb.service" >> /etc/systemd/system/sqlgrey.service.d/override.conf'
execcmd
cmd='echo "[Service]" >> /etc/systemd/system/sqlgrey.service.d/override.conf'
execcmd
cmd='echo "PIDFile=/var/run/sqlgrey/sqlgrey.pid" >> /etc/systemd/system/sqlgrey.service.d/override.conf'
execcmd

# Add msmilter systemd override
cmd='mkdir -p /etc/systemd/system/msmilter.service.d'
execcmd
cmd='echo "[Unit]" > /etc/systemd/system/msmilter.service.d/override.conf'
execcmd
cmd='echo "After=network-online.target remote-fs.target rsyslog.service mailscanner.service" >> /etc/systemd/system/msmilter.service.d/override.conf'
execcmd

# Set sqlgrey binding and pidfile location
cmd="sed -i '/# inet = 2501/ a\inet = 127.0.0.1:2501' /etc/sqlgrey/sqlgrey.conf"
[[ -z $(grep ^inet /etc/sqlgrey/sqlgrey.conf) ]] && execcmd
cmd="sed -i '/# pidfile =/ a\pidfile = /var/run/sqlgrey/sqlgrey.pid' /etc/sqlgrey/sqlgrey.conf"
[[ -z $(grep ^pidfile /etc/sqlgrey/sqlgrey.conf) ]] && execcmd

# Move sqlgrey pidfile location
cmd='echo "d /run/sqlgrey 0755 sqlgrey sqlgrey" > /usr/lib/tmpfiles.d/sqlgrey.conf'
execcmd
cmd='mkdir -p /var/run/sqlgrey'
execcmd
cmd='chown sqlgrey:sqlgrey /var/run/sqlgrey'
execcmd

# Move interface backups
cmd='mkdir -p /etc/sysconfig/network-scripts.bak'
execcmd
cmd='chcon -t net_conf_t /etc/sysconfig/network-scripts.bak'
[[ $instancetype != "lxc" ]] && execcmd
cmd='semanage fcontext -a -t net_conf_t /etc/sysconfig/network-scripts.bak'
[[ $instancetype != "lxc" ]] && execcmd

mv -f /etc/sysconfig/network-scripts/*bak /etc/sysconfig/network-scripts.bak >/dev/null 2>&1

# Build canonical maps
cmd='postconf -e "sender_canonical_maps = hash:/etc/postfix/sender_canonical"'
execcmd
cmd='postconf -e "recipient_canonical_maps = hash:/etc/postfix/recipient_canonical"'
execcmd
HOSTNAME=$(grep ^HOSTNAME /etc/eFa/eFa-Config | sed s/^.*://)
DOMAINNAME=$(grep ^DOMAINNAME /etc/eFa/eFa-Config | sed s/^.*://)
ADMINEMAIL=$(grep ^ADMINEMAIL /etc/eFa/eFa-Config | sed s/^.*://)
cmd="echo \"root@$DOMAINNAME $ADMINEMAIL\" > /etc/postfix/recipient_canonical" 
[[ ! -f /etc/postfix/recipient_canonical ]] && execcmd
cmd='postmap -r /etc/postfix/recipient_canonical'
execcmd
cmd="echo \"root@$DOMAINNAME root@$HOSTNAME.$DOMAINNAME\" > /etc/postfix/sender_canonical"
[[ ! -f /etc/postfix/sender_canonical ]] && execcmd
cmd='postmap -r /etc/postfix/sender_canonical'
execcmd

# Fix Socket entries and Logfile entries
cmd='sed -i "/^LocalSocket/ c\#LocalSocket" /etc/clamd.d/scan.conf'
execcmd
cmd='sed -i "/^LogFile/ c\#LogFile" /etc/clamd.d/scan.conf'
execcmd
cmd='sed -i "/# Path to a local socket file the daemon will listen on./{N;N;s|$|\nLocalSocket /var/run/clamd.socket/clamd.sock|}" /etc/clamd.d/scan.conf'
execcmd
cmd='sed -i "/# Uncomment this option to enable logging./{N;N;N;N;s|$|\nLogFile /var/log/clamd.scan|}" /etc/clamd.d/scan.conf'
execcmd

# Relocate clam socket
cmd='mkdir -p /var/run/clamd.socket'
execcmd
cmd='chown -R clamscan:mtagroup /var/run/clamd.socket'
execcmd
cmd='chmod 0750 /var/run/clamd.socket'
execcmd
cmd='echo "d /var/run/clamd.socket 0750 clamscan mtagroup -" > /etc/tmpfiles.d/clamd.socket.conf'
execcmd
cmd='sed -i "/^Clamd Socket =/ c\Clamd Socket = /var/run/clamd.socket/clamd.sock" /etc/MailScanner/MailScanner.conf'
execcmd
cmd='chcon -u system_u -r object_r -t antivirus_var_run_t /var/run/clamd.socket'
[[ $instancetype != "lxc" ]] && execcmd
cmd='semanage fcontext -a -t antivirus_var_run_t /var/run/clamd.socket'
[[ $instancetype != "lxc" ]] && execcmd

# Fix postfix mailbox size
cmd='postconf -e "mailbox_size_limit = 133169152"'
execcmd

# Supress messages from yum cron via crond
cmd='sed -i "s|^exec /usr/sbin/yum-cron /etc/yum/yum-cron-hourly.conf$|exec /usr/sbin/yum-cron /etc/yum/yum-cron-hourly.conf >/dev/null 2>\&1|" /etc/cron.hourly/0yum-hourly.cron'
execcmd

# Fix entry in postfix master.cf
cmd='sed -i "/^\s\s-o smtpd_sasl_security_options=noanaonymous/ c\ \ -o smtpd_sasl_security_options=noanonymous" /etc/postfix/master.cf'
execcmd

# Fix outbound relaying
if [[ -z $(grep ^smtpd_client_restrictions /etc/postfix/main.cf | grep permit_mynetworks) ]]; then
  cmd='sed -i "s/^smtpd_client_restrictions = \(.*\)$/smtpd_client_restrictions = permit_mynetworks, \1/" /etc/postfix/main.cf'
  execcmd
fi

if [[ -z $(grep ^smtpd_recipient_restrictions /etc/postfix/main.cf | grep permit_mynetworks) ]]; then
  cmd='sed -i "s/^smtpd_recipient_restrictions = \(.*\)$/smtpd_recipient_restrictions = permit_mynetworks, \1/" /etc/postfix/main.cf'
  execcmd
fi

# Fix httpd update issue
cmd='sed -i "s|#LoadModule autoindex_module modules/mod_autoindex.so|LoadModule autoindex_module modules/mod_autoindex.so|" /etc/httpd/conf.modules.d/00-base.conf'
execcmd

# Set php-fpm group for MSRE
cmd='chgrp -R php-fpm /etc/MailScanner/rules'
execcmd

# Clean up root user in mysql
cmd='/usr/bin/mysql -e "DELETE FROM mysql.user WHERE User=\"root\" AND Host NOT IN (\"localhost\");"'
execcmd

# Add config item for IPV6DNS
if [[ -z $(grep ^IPV6DNS /etc/eFa/eFa-Config) ]]; then
  [[ -z $(grep 'do-ip6: no' /etc/unbound/unbound.conf) ]] && echo 'IPV6DNS:yes' >> /etc/eFa/eFa-Config || echo 'IPV6DNS:no' >> /etc/eFa/eFa-Config
fi

# Add fqdns to apache
cmd='sed -i "/^#ServerName\s/ c\ServerName $HOSTNAME.$DOMAINNAME:80" /etc/httpd/conf/httpd.conf'
execcmd
cmd='sed -i "/^#ServerName\s/ c\ServerName $HOSTNAME.$DOMAINNAME:443" /etc/httpd/conf.d/ssl.conf'
execcmd

if [[ ! -f /etc/httpd/conf.d/vhost.conf ]]; then
  echo "<VirtualHost _default_:80>" > /etc/httpd/conf.d/vhost.conf
  echo "ServerName $HOSTNAME.$DOMAINNAME:80" >> /etc/httpd/conf.d/vhost.conf
  echo "</VirtualHost>" >> /etc/httpd/conf.d/vhost.conf
fi

# Add entry to header_checks
if [[ -z $(grep '^Received: from localhost' /etc/postfix/header_checks) ]]; then
  cmd='echo "/^Received:\ from\ localhost\ \(localhost\ \[127.0.0.1\]\)/ IGNORE" >> /etc/postfix/header_checks'
  execcmd
fi

# Patch mailscanner daily crons
if [[ -z $(grep skipmonitor /etc/cron.daily/mailscanner) ]]; then
  cat > /etc/cron.daily/mailscanner << 'EOF'
cat > /etc/cron.daily/mailscanner << 'EOF'
#!/bin/sh
#

touch /var/eFa/skipmonitor

# daily actions
/usr/sbin/ms-cron DAILY >/dev/null 2>&1

# maintenance
/usr/sbin/ms-cron MAINT >/dev/null 2>&1

exit 0

EOF
  [[ $? -ne 0 ]] && echo "cat > /etc/cron.daily/mailscanner" && retval=1
fi

# Create .spamassassin directory for php-fpm
cmd='mkdir -p /var/lib/php/fpm/.spamassassin'
execcmd
cmd='chown postfix:mtagroup /var/lib/php/fpm/.spamassassin'
execcmd

# Remove KAM.cf and eFa-SA-Update
if [[ -f /etc/mail/spamassassin/KAM.cf ]]; then
  cmd='rm -f /etc/mail/spamassassin/KAM.cf'
  execcmd
fi

# Make sure txrep table has last_hit column, ignore failure
/usr/bin/mysql -e "ALTER TABLE sa_bayes.txrep ADD last_hit timestamp NOT NULL default CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP; ALTER TABLE sa_bayes.txrep ADD KEY last_hit (last_hit);" >/dev/null 2>&1

# Suppress permission denied errrors during tmpwatch execution
cmd='sed -i "/^\/usr\/sbin\/tmpwatch / c\/usr/sbin/tmpwatch -u 48 /var/spool/MailScanner/incoming/SpamAssassin-Temp >dev/null 2>\&1" /etc/cron.daily/eFa-SAClean'
execcmd

# Configure opendkim for verification only
cmd='sed -i "s|^KeyFile\s/etc/opendkim/keys/default.private|#&|" /etc/opendkim.conf'
execcmd

# Configure opendmarc
cmd='sed -i "/^# AuthservID / c\AuthservID HOSTNAME" /etc/opendmarc.conf'
execcmd
cmd='sed -i "/^# HistoryFile / c\HistoryFile /var/spool/opendmarc/opendmarc.dat" /etc/opendmarc.conf'
execcmd
cmd='sed -i "/^# PublicSuffixList / c\PublicSuffixList /etc/opendmarc/public_suffix_list.dat" /etc/opendmarc.conf'
execcmd

if [[ ! -f /etc/eFa/openDMARC-Config ]]; then
  # Set up DB
  cmd='/usr/bin/mysql < /usr/src/eFa/mariadb/schema.mysql'
  execcmd
  randompw
  DMARCSQLPWD=$PASSWD
  /usr/bin/mysql -e "UPDATE mysql.user SET Password=PASSWORD('$DMARCSQLPWD') WHERE User='opendmarc'; FLUSH PRIVILEGES;"
  [ $? -ne 0 ] && exit 1
  echo "DMARCSQLPWD:$DMARCSQLPWD" > /etc/eFa/openDMARC-Config
  [ $? -ne 0 ] && exit 1
  DMARCSQLPWD=
  PASSWD=
fi

if [ ! -f /etc/opendmarc/public_suffix_list.dat ]; then
  cmd='curl -s https://publicsuffix.org/list/public_suffix_list.dat > /etc/opendmarc/public_suffix_list.dat'
  execcmd
fi

if [[ -z $(grep ^unverified_recipient_reject_reason /etc/postfix/main.cf) ]]; then
  cmd='postconf -e "unverified_recipient_reject_reason = No user at this address"'
  execcmd
fi
if [[ -z $(grep ^unverified_recipient_reject_code /etc/postfix/main.cf) ]]; then
  cmd='postconf -e "unverified_recipient_reject_code = 550"'
  execcmd
fi

# Lock down openDMARC-Config
cmd='chown root:mtagroup /etc/eFa/openDMARC-Config'
execcmd
cmd='chmod 640 /etc/eFa/openDMARC-Config'
execcmd
cmd='chcon -u system_u -r object_r -t opendmarcsql_etc_t /etc/eFa/openDMARC-Config'
[[ $instancetype != "lxc" ]] && execcmd
cmd='semanage fcontext -a -t opendmarcsql_etc_t /etc/eFa/openDMARC-Config'
[[ $instancetype != "lxc" ]] && execcmd

cmd='systemctl daemon-reload'
execcmd
cmd='systemctl restart httpd'
execcmd
cmd='systemctl restart php-fpm'
execcmd
cmd='systemctl restart sqlgrey'
execcmd
cmd='systemctl restart postfix'
execcmd
cmd='systemctl restart clamd@scan'
execcmd
cmd='systemctl restart mailscanner'
execcmd
cmd='systemctl enable postfix_relay'
execcmd
cmd='systemctl start postfix_relay'
execcmd
cmd='systemctl enable milter_relay'
execcmd
cmd='systemctl start milter_relay'
execcmd
cmd='systemctl restart mariadb'
execcmd

exit $retval
