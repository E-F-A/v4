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

# label new files
[[ $instancetype != "lxc" ]] && chcon -t bin_t /usr/sbin/mysqltuner.pl && [[ $? -ne 0 ]] && exit 1

# Move symlink for cron-dccd
if [[ -e /etc/cron.monthly/cron-dccd ]]; then
  rm -f /etc/cron.monthly/cron-dccd
  [[ $? -ne 0 ]] && exit 1
  ln -s /var/dcc/libexec/cron-dccd /etc/cron.daily/cron-dccd
  [[ $? -ne 0 ]] && exit 1
  [[ $instancetype != "lxc" ]] && chcon -t bin_t /etc/cron.daily/cron-dccd && [[ $? -ne 0 ]] && exit 1
fi

# Tweak mariadb configuration
# Remove limits on mariadb
mkdir -p mkdir /etc/systemd/system/mariadb.service.d
if [[ ! -f /etc/systemd/system/mariadb.service.d/limit.conf ]]; then
  cat > /etc/systemd/system/mariadb.service.d/limit.conf << 'EOF'
[Service]
LimitNOFILE=infinity
LimitMEMLOCK=infinity
EOF
  [[ $? -ne 0 ]] && exit 1
  [[ $instancetype != "lxc" ]] && chcon -t systemd_unit_file_t /etc/systemd/system/mariadb.service.d && [[ $? -ne 0 ]] && exit 1
  [[ $instancetype != "lxc" ]] && chcon -t systemd_unit_file_t /etc/systemd/system/mariadb.service.d/limit.conf && [[ $? -ne 0 ]] && exit 1
else
  [[ -z $(grep ^LimitMEMLOCK /etc/systemd/system/mariadb.service.d/limit.conf) ]] && sed -i "/^\[Service\]$/ a\LimitMEMLOCK=infinity" /etc/systemd/system/mariadb.service.d/limit.conf && [[ $? -ne 0 ]] && exit 1
  [[ -z $(grep ^LimitNOFILE /etc/systemd/system/mariadb.service.d/limit.conf) ]] && sed -i "/^\[Service\]$/ a\LimitNOFILE=infinity" /etc/systemd/system/mariadb.service.d/limit.conf && [[ $? -ne 0 ]] && exit 1
fi

# Performance tweaks
# Remove bad entries from a malformed eFa-Base rpm modification
sed -i "/^\stmp_table_size/d" /etc/my.cnf.d/mariadb-server.cnf && [[ $? -ne 0 ]] && exit 1
sed -i "/^\sthread_cache_size/d" /etc/my.cnf.d/mariadb-server.cnf && [[ $? -ne 0 ]] && exit 1
sed -i "/^\ssort_buffer_size/d" /etc/my.cnf.d/mariadb-server.cnf && [[ $? -ne 0 ]] && exit 1
sed -i "/^\sskip-host-cache/d" /etc/my.cnf.d/mariadb-server.cnf && [[ $? -ne 0 ]] && exit 1
sed -i "/^\sskip-external-locking/d" /etc/my.cnf.d/mariadb-server.cnf && [[ $? -ne 0 ]] && exit 1
sed -i "/^\sread_rnd_buffer_size/d" /etc/my.cnf.d/mariadb-server.cnf && [[ $? -ne 0 ]] && exit 1
sed -i "/^\sread_buffer_size/d" /etc/my.cnf.d/mariadb-server.cnf && [[ $? -ne 0 ]] && exit 1
sed -i "/^\squery_cache_type/d" /etc/my.cnf.d/mariadb-server.cnf && [[ $? -ne 0 ]] && exit 1
sed -i "/^\squery_cache_size/d" /etc/my.cnf.d/mariadb-server.cnf && [[ $? -ne 0 ]] && exit 1
sed -i "/^\smax_heap_table_size/d" /etc/my.cnf.d/mariadb-server.cnf && [[ $? -ne 0 ]] && exit 1
sed -i "/^\smax_allowed_packet/d" /etc/my.cnf.d/mariadb-server.cnf && [[ $? -ne 0 ]] && exit 1
sed -i "/^\skey_cache_segments/d" /etc/my.cnf.d/mariadb-server.cnf && [[ $? -ne 0 ]] && exit 1
sed -i "/^\sjoin_buffer_size/d" /etc/my.cnf.d/mariadb-server.cnf && [[ $? -ne 0 ]] && exit 1
sed -i "/^\sinnodb_log_file_size/d" /etc/my.cnf.d/mariadb-server.cnf && [[ $? -ne 0 ]] && exit 1
sed -i "/^\sinnodb_log_buffer_size/d" /etc/my.cnf.d/mariadb-server.cnf && [[ $? -ne 0 ]] && exit 1
sed -i "/^\sinnodb_file_per_table/d" /etc/my.cnf.d/mariadb-server.cnf && [[ $? -ne 0 ]] && exit 1
sed -i "/^\sinnodb_buffer_pool_size/d" /etc/my.cnf.d/mariadb-server.cnf && [[ $? -ne 0 ]] && exit 1
sed -i "/^\sinnodb_buffer_pool_instances/d" /etc/my.cnf.d/mariadb-server.cnf && [[ $? -ne 0 ]] && exit 1
sed -i "/^\sinnodb-defragment/d" /etc/my.cnf.d/mariadb-server.cnf && [[ $? -ne 0 ]] && exit 1

# Ensure tweaks are in place
[[ -z $(grep ^tmp_table_size /etc/my.cnf.d/mariadb-server.cnf) ]] && sed -i "/^\[mariadb-10.1\]$/ a\tmp_table_size = 32M" /etc/my.cnf.d/mariadb-server.cnf && [[ $? -ne 0 ]] && exit 1
[[ -z $(grep ^thread_cache_size /etc/my.cnf.d/mariadb-server.cnf) ]] && sed -i "/^\[mariadb-10.1\]$/ a\thread_cache_size = 16" /etc/my.cnf.d/mariadb-server.cnf && [[ $? -ne 0 ]] && exit 1
[[ -z $(grep ^sort_buffer_size /etc/my.cnf.d/mariadb-server.cnf) ]] && sed -i "/^\[mariadb-10.1\]$/ a\sort_buffer_size = 4M" /etc/my.cnf.d/mariadb-server.cnf && [[ $? -ne 0 ]] && exit 1
[[ -z $(grep ^skip-host-cache /etc/my.cnf.d/mariadb-server.cnf) ]] && sed -i "/^\[mariadb-10.1\]$/ a\skip-host-cache" /etc/my.cnf.d/mariadb-server.cnf && [[ $? -ne 0 ]] && exit 1
[[ -z $(grep ^skip-external-locking /etc/my.cnf.d/mariadb-server.cnf) ]] && sed -i "/^\[mariadb-10.1\]$/ a\skip-external-locking" /etc/my.cnf.d/mariadb-server.cnf && [[ $? -ne 0 ]] && exit 1
[[ -z $(grep ^read_rnd_buffer_size /etc/my.cnf.d/mariadb-server.cnf) ]] && sed -i "/^\[mariadb-10.1\]$/ a\read_rnd_buffer_size = 1M" /etc/my.cnf.d/mariadb-server.cnf && [[ $? -ne 0 ]] && exit 1
[[ -z $(grep ^read_buffer_size /etc/my.cnf.d/mariadb-server.cnf) ]] && sed -i "/^\[mariadb-10.1\]$/ a\read_buffer_size = 2M" /etc/my.cnf.d/mariadb-server.cnf && [[ $? -ne 0 ]] && exit 1
[[ -z $(grep ^query_cache_type /etc/my.cnf.d/mariadb-server.cnf) ]] && sed -i "/^\[mariadb-10.1\]$/ a\query_cache_type = OFF" /etc/my.cnf.d/mariadb-server.cnf && [[ $? -ne 0 ]] && exit 1
[[ -z $(grep ^query_cache_size /etc/my.cnf.d/mariadb-server.cnf) ]] && sed -i "/^\[mariadb-10.1\]$/ a\query_cache_size = 0M" /etc/my.cnf.d/mariadb-server.cnf && [[ $? -ne 0 ]] && exit 1
[[ -z $(grep ^max_heap_table_size /etc/my.cnf.d/mariadb-server.cnf) ]] && sed -i "/^\[mariadb-10.1\]$/ a\max_heap_table_size = 32M" /etc/my.cnf.d/mariadb-server.cnf && [[ $? -ne 0 ]] && exit 1
[[ -z $(grep ^max_allowed_packet /etc/my.cnf.d/mariadb-server.cnf) ]] && sed -i "/^\[mariadb-10.1\]$/ a\max_allowed_packet = 16M" /etc/my.cnf.d/mariadb-server.cnf && [[ $? -ne 0 ]] && exit 1
[[ -z $(grep ^key_cache_segments /etc/my.cnf.d/mariadb-server.cnf) ]] && sed -i "/^\[mariadb-10.1\]$/ a\key_cache_segments = 4" /etc/my.cnf.d/mariadb-server.cnf && [[ $? -ne 0 ]] && exit 1
[[ -z $(grep ^join_buffer_size /etc/my.cnf.d/mariadb-server.cnf) ]] && sed -i "/^\[mariadb-10.1\]$/ a\join_buffer_size = 512K" /etc/my.cnf.d/mariadb-server.cnf && [[ $? -ne 0 ]] && exit 1
[[ -z $(grep ^innodb_log_file_size /etc/my.cnf.d/mariadb-server.cnf) ]] && sed -i "/^\[mariadb-10.1\]$/ a\innodb_log_file_size = 125M" /etc/my.cnf.d/mariadb-server.cnf && [[ $? -ne 0 ]] && exit 1
[[ -z $(grep ^innodb_log_buffer_size /etc/my.cnf.d/mariadb-server.cnf) ]] && sed -i "/^\[mariadb-10.1\]$/ a\innodb_log_buffer_size = 32M" /etc/my.cnf.d/mariadb-server.cnf && [[ $? -ne 0 ]] && exit 1
[[ -z $(grep ^innodb_file_per_table /etc/my.cnf.d/mariadb-server.cnf) ]] && sed -i "/^\[mariadb-10.1\]$/ a\innodb_file_per_table = 1" /etc/my.cnf.d/mariadb-server.cnf && [[ $? -ne 0 ]] && exit 1
[[ -z $(grep ^innodb_buffer_pool_size /etc/my.cnf.d/mariadb-server.cnf) ]] && sed -i "/^\[mariadb-10.1\]$/ a\innodb_buffer_pool_size = 1G" /etc/my.cnf.d/mariadb-server.cnf && [[ $? -ne 0 ]] && exit 1
[[ -z $(grep ^innodb_buffer_pool_instances /etc/my.cnf.d/mariadb-server.cnf) ]] && sed -i "/^\[mariadb-10.1\]$/ a\innodb_buffer_pool_instances = 1" /etc/my.cnf.d/mariadb-server.cnf && [[ $? -ne 0 ]] && exit 1
[[ -z $(grep ^innodb-defragment /etc/my.cnf.d/mariadb-server.cnf) ]] && sed -i "/^\[mariadb-10.1\]$/ a\innodb-defragment = 1" /etc/my.cnf.d/mariadb-server.cnf && [[ $? -ne 0 ]] && exit 1
[[ -z $(grep ^bind-address /etc/my.cnf.d/mariadb-server.cnf) ]] && sed -i "/^\[mariadb-10.1\]$/ a\bind-address = 127.0.0.1" /etc/my.cnf.d/mariadb-server.cnf && [[ $? -ne 0 ]] && exit 1

# Show version in MailWatch
sed -i "/^define('SHOW_SFVERSION',/ c\define('SHOW_SFVERSION', true);" /var/www/html/mailscanner/conf.php
[[ $? -ne 0 ]] && exit 1

if [[ ! -f /root/.my.cnf ]]; then 
  echo "[client]" > /root/.my.cnf
  [ $? -ne 0 ] && exit 1
  echo "user=root" >> /root/.my.cnf
  [ $? -ne 0 ] && exit 1
  echo "password=$(grep ^MYSQLROOTPWD /etc/eFa/MySQL-Config | sed -e 's/^.*://')" >> /root/.my.cnf
  [ $? -ne 0 ] && exit 1
  chmod 400 /root/.my.cnf
  [ $? -ne 0 ] && exit 1
  [[ $instancetype != "lxc" ]] && chcon -t admin_home_t /root/.my.cnf && [[ $? -ne 0 ]] && exit 1
fi

# Cleanup
[[ -d /var/www/eFaInit ]] && rm -rf /var/www/eFaInit && [ $? -ne 0 ] && exit 1
[[ -f /usr/sbin/eFa-Init ]] && rm -f /usr/sbin/eFa-Init && [ $? -ne 0 ] && exit 1
[[ -f /usr/sbin/eFa-Commit ]] && rm -f /usr/sbin/eFa-Commit  && [ $? -ne 0 ] && exit 1

# Autolearn
[[ -z $(grep ^bayes_auto_learn /etc/MailScanner/spamassassin.conf) ]] && echo 'bayes_auto_learn                   1' >> /etc/MailScanner/spamassassin.conf && [[ $? -ne 0 ]] && exit 1
[[ -z $(grep ^bayes_auto_learn_threshold_nonspam /etc/MailScanner/spamassassin.conf) ]] && echo 'bayes_auto_learn_threshold_nonspam 0.1' >> /etc/MailScanner/spamassassin.conf && [[ $? -ne 0 ]] && exit 1
[[ -z $(grep ^bayes_auto_learn_threshold_spam /etc/MailScanner/spamassassin.conf) ]] && echo 'bayes_auto_learn_threshold_spam    6' >> /etc/MailScanner/spamassassin.conf && [[ $? -ne 0 ]] && exit 1

# Set cron MAILTO
sed -i "/^MAILTO=root/ c\MAILTO=root" /etc/crontab && [[ $? -ne 0 ]] && exit 1
[[ -f /etc/anacrontab ]] && sed -i "/^MAILTO=root/ c\MAILTO=root" /etc/anacrontab && [[ $? -ne 0 ]] && exit 1

# Set postfix error_notice_recipient
postconf -e "error_notice_recipient = root" && [[ $? -ne 0 ]] && exit 1

# Update SELinux
if [[ $instancetype != "lxc" ]]; then
  checkmodule -M -m -o /var/eFa/lib/selinux/eFa.mod /var/eFa/lib/selinux/eFa.te && [[ $? -ne 0 ]] && exit 1
  semodule_package -o /var/eFa/lib/selinux/eFa.pp -m /var/eFa/lib/selinux/eFa.mod -f /var/eFa/lib/selinux/eFa.fc && [[ $? -ne 0 ]] && exit 1
  semodule -i /var/eFa/lib/selinux/eFa.pp && [[ $? -ne 0 ]] && exit 1
fi

# Update MailWatch after MailWatch rpm update applies
sed -i "/^my (\$db_user) =/ c\my (\$db_user) = 'mailwatch';" /usr/share/MailScanner/perl/custom/MailWatchConf.pm && [[ $? -ne 0 ]] && exit 1
sed -i "/^my (\$db_pass) =/ c\my (\$fh);\nmy (\$pw_config) = '/etc/eFa/MailWatch-Config';\nopen(\$fh, \"<\", \$pw_config);\nif(\!\$fh) {\n  MailScanner::Log::WarnLog(\"Unable to open %s to retrieve password\", \$pw_config);\n  return;\n}\nmy (\$db_pass) = grep(/^MAILWATCHSQLPWD/,<\$fh>);\n\$db_pass =~ s/MAILWATCHSQLPWD://;\n\$db_pass =~ s/\\\n//;\nclose(\$fh);" /usr/share/MailScanner/perl/custom/MailWatchConf.pm && [[ $? -ne 0 ]] && exit 1
cp /usr/src/eFa/mailwatch/favicon.ico /var/www/html/favicon.ico && [[ $? -ne 0 ]] && exit 1
/bin/cp -f /var/www/html/favicon.ico /var/www/html/mailscanner/ && [[ $? -ne 0 ]] && exit 1
/bin/cp -f /var/www/html/favicon.ico /var/www/html/mailscanner/images && [[ $? -ne 0 ]] && exit 1
/bin/cp -f /var/www/html/favicon.ico /var/www/html/mailscanner/images/favicon.png && [[ $? -ne 0 ]] && exit 1
mv -f /var/www/html/mailscanner/images/mailwatch-logo.png /var/www/html/mailscanner/images/mailwatch-logo.png.orig && [[ $? -ne 0 ]] && exit 1
cp -f /usr/src/eFa/mailwatch/eFa4logo-79px.png /var/www/html/mailscanner/images/mailwatch-logo.png && [[ $? -ne 0 ]] && exit 1
cp -f /var/www/html/mailscanner/images/mailwatch-logo.png /var/www/html/mailscanner/images/mailwatch-logo.gif && [[ $? -ne 0 ]] && exit 1
sed -i 's/#f7ce4a/#999999/ig' /var/www/html/mailscanner/style.css && [[ $? -ne 0 ]] && exit 1
sed -i "/^    min-width: 960px;/ c\    min-width: 1375px;" /var/www/html/mailscanner/style.css && [[ $? -ne 0 ]] && exit 1
if [[ -z $(grep efa_version /var/www/html/mailscanner/functions.php) ]]; then
  cat >> /var/www/html/mailscanner/functions.php << 'EOF'
/**
 * eFa Version
 */
function efa_version()
{
  return file_get_contents( '/etc/eFa-Version', NULL, NULL, 0, 15 );
}
EOF
  [[ $? -ne 0 ]] && exit 1
  sed -i "/^    echo mailwatch_version/a \    echo ' running on ' . efa_version();" /var/www/html/mailscanner/functions.php && [[ $? -ne 0 ]] && exit 1
fi

if [[ -z $(grep SHOW_GREYLIST /var/www/html/mailscanner/functions.php) ]]; then
  sed -i "/^        \$nav\['docs.php'\] =/{N;s/$/\n        \/\/Begin eFa\n        if \(\$_SESSION\['user_type'\] == 'A' \&\& SHOW_GREYLIST == true\) \{\n            \$nav\['grey.php'\] = \"greylist\";\n        \}\n        \/\/End eFa/}" /var/www/html/mailscanner/functions.php && [[ $? -ne 0 ]] && exit 1
fi

cd /var/www/html/sgwi && rm -f ./images/mailwatch-logo.png && ln -s ../../mailscanner/images/mailwatch-logo.png ./images/mailwatch-logo.png && [[ $? -ne 0 ]] && exit 1

# Disable prefork mpm and replace with event mpm
sed -i 's|^LoadModule mpm_prefork_module modules/mod_mpm_prefork.so|#&|' /etc/httpd/conf.modules.d/00-mpm.conf && [[ $? -ne 0 ]] && exit 1
sed -i 's|^#LoadModule mpm_event_module modules/mod_mpm_event.so|LoadModule mpm_event_module modules/mod_mpm_event.so|' /etc/httpd/conf.modules.d/00-mpm.conf && [[ $? -ne 0 ]] && exit 1

# Add php-fpm to mtagroup
usermod -G mtagroup php-fpm
[[ $? -ne 0 ]] && exit 1

# Fix sudoers for php-fpm
sed -i 's/apache/php-fpm/' /etc/sudoers.d/mailwatch
[[ $? -ne 0 ]] && exit 1

# Fix bad sed for earlier base package
sed -i '/^;env\[PATH\] =/ c\env[PATH] = /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin' /etc/php-fpm.d/www.conf
[[ $? -ne 0 ]] && exit 1

# Fix extraneous session_start in grey.php
sed -i "/^session_start();$/d" /var/www/html/mailscanner/grey.php
[[ $? -ne 0 ]] && exit 1

# Add sqlgrey systemd override
mkdir -p /etc/systemd/system/sqlgrey.service.d
[[ $? -ne 0 ]] && exit 1
[[ $instancetype != "lxc" ]] && chcon -t systemd_unit_file_t /etc/systemd/system/sqlgrey.service.d && [[ $? -ne 0 ]] && exit 1
echo "[Unit]" > /etc/systemd/system/sqlgrey.service.d/override.conf
echo "After=syslog.target network.target mariadb.service" >> /etc/systemd/system/sqlgrey.service.d/override.conf
echo "[Service]" >> /etc/systemd/system/sqlgrey.service.d/override.conf
echo "PIDFile=/var/run/sqlgrey/sqlgrey.pid" >> /etc/systemd/system/sqlgrey.service.d/override.conf
[[ $? -ne 0 ]] && exit 1
[[ $instancetype != "lxc" ]] && chcon -t systemd_unit_file_t /etc/systemd/system/sqlgrey.service.d/override.conf && [[ $? -ne 0 ]] && exit 1

# Add msmilter systemd override
mkdir -p /etc/systemd/system/msmilter.service.d
[[ $? -ne 0 ]] && exit 1
[[ $instancetype != "lxc" ]] && chcon -t systemd_unit_file_t /etc/systemd/system/msmilter.service.d && [[ $? -ne 0 ]] && exit 1
echo "[Unit]" > /etc/systemd/system/msmilter.service.d/override.conf
echo "After=network-online.target remote-fs.target rsyslog.service mailscanner.service" >> /etc/systemd/system/msmilter.service.d/override.conf
[[ $? -ne 0 ]] && exit 1
[[ $instancetype != "lxc" ]] && chcon -t systemd_unit_file_t /etc/systemd/system/msmilter.service.d/override.conf && [[ $? -ne 0 ]] && exit 1

# Set sqlgrey binding and pidfile location
[[ -z $(grep ^inet /etc/sqlgrey/sqlgrey.conf) ]] && sed -i '/# inet = 2501/ a\inet = 127.0.0.1:2501' /etc/sqlgrey/sqlgrey.conf
[[ $? -ne 0 ]] && exit 1
[[ -z $(grep ^pidfile /etc/sqlgrey/sqlgrey.conf) ]] && sed -i '/# pidfile =/ a\pidfile = /var/run/sqlgrey/sqlgrey.pid' /etc/sqlgrey/sqlgrey.conf
[[ $? -ne 0 ]] && exit 1

# Move sqlgrey pidfile location
echo "d /run/sqlgrey 0755 sqlgrey sqlgrey" > /usr/lib/tmpfiles.d/sqlgrey.conf
[[ $? -ne 0 ]] && exit 1
[[ $instancetype != "lxc" ]] && chcon -t lib_t /usr/lib/tmpfiles.d/sqlgrey.conf && [[ $? -ne 0 ]] && exit 1
mkdir -p /var/run/sqlgrey
[[ $? -ne 0 ]] && exit 1
[[ $instancetype != "lxc" ]] && chcon -t var_run_t /var/run/sqlgrey && [[ $? -ne 0 ]] && exit 1
chown sqlgrey:sqlgrey /var/run/sqlgrey
[[ $? -ne 0 ]] && exit 1

# Move interface backups
mkdir -p /etc/sysconfig/network-scripts.bak
[[ $? -ne 0 ]] && exit 1
[[ $instancetype != "lxc" ]] && chcon -t net_conf_t /etc/sysconfig/network-scripts.bak && [[ $? -ne 0 ]] && exit 1
mv -f /etc/sysconfig/network-scripts/*bak /etc/sysconfig/network-scripts.bak >/dev/null 2>&1

# Build canonical maps
postconf -e "sender_canonical_maps = hash:/etc/postfix/sender_canonical"
postconf -e "recipient_canonical_maps = hash:/etc/postfix/recipient_canonical"
HOSTNAME=$(grep ^HOSTNAME /etc/eFa/eFa-Config | sed s/^.*://)
DOMAINNAME=$(grep ^DOMAINNAME /etc/eFa/eFa-Config | sed s/^.*://)
ADMINEMAIL=$(grep ^ADMINEMAIL /etc/eFa/eFa-Config | sed s/^.*://)
[[ ! -f /etc/postfix/recipient_canonical ]] && echo "root@$DOMAINNAME $ADMINEMAIL" > /etc/postfix/recipient_canonical
postmap /etc/postfix/recipient_canonical
[[ ! -f /etc/postfix/sender_canonical ]] && echo "root@$DOMAINNAME root@$HOSTNAME.$DOMAINNAME" > /etc/postfix/sender_canonical
postmap /etc/postfix/sender_canonical

systemctl daemon-reload
[ $? -ne 0 ] && exit 1
systemctl restart mariadb
[ $? -ne 0 ] && exit 1
systemctl restart httpd
[[ $? -ne 0 ]] && exit 1
systemctl restart php-fpm
[[ $? -ne 0 ]] && exit 1
systemctl restart sqlgrey
[[ $? -ne 0 ]] && exit 1
systemctl restart postfix
[[ $? -ne 0 ]] && exit 1

exit 0
