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
  [[ $instancetype != "lxc" ]] && chcon -t admin_home_t /root/.my.cnf && [[ $? -ne 0 ]] && exit 1
fi

# Cleanup
[[ -d /var/www/eFaInit ]] && rm -rf /var/www/eFaInit && [ $? -ne 0 ] && exit 1
[[ -f /usr/sbin/eFa-Init ]] && rm -f /usr/sbin/eFa-Init && [ $? -ne 0 ] && exit 1
[[ -f /usr/sbin/eFa-Commit ]] && rm -f /usr/sbin/eFa-Commit  && [ $? -ne 0 ] && exit 1

systemctl daemon-reload
[ $? -ne 0 ] && exit 1
systemctl restart mariadb
[ $? -ne 0 ] && exit 1

exit 0