#!/bin/sh
#-----------------------------------------------------------------------------#
# eFa 4.0.0 initial service-configuration script
#-----------------------------------------------------------------------------#
# Copyright (C) 2013~2018 https://efa-project.org
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

#-----------------------------------------------------------------------------#
# Source the settings file
#-----------------------------------------------------------------------------#
source /usr/src/eFa/eFa-settings.inc
#-----------------------------------------------------------------------------#

#-----------------------------------------------------------------------------#
# Start configuration of services
#-----------------------------------------------------------------------------#
echo "Configuring services..."

# Enable these for eFaInit
systemctl enable httpd
systemctl enable php-fpm

# These services we disable for now and enable them after eFa-Init.
# Most of these are not enabled by default but add them here just to
# make sure we don't forget them at eFa-Init.
systemctl disable mailscanner
systemctl disable msmilter
systemctl disable postfix
systemctl disable mariadb
#chkconfig saslauthd off
systemctl disable crond
systemctl disable clamd@scan
systemctl disable sqlgrey
#chkconfig mailgraph-init off
chkconfig adcc off
#chkconfig webmin off
systemctl disable unbound
#chkconfig munin-node off
systemctl disable chronyd
systemctl disable yum-cron
systemctl disable sshd

systemctl disable hypervkvpd >/dev/null 2>&1
systemctl disable hypervvssd >/dev/null 2>&1

# Disable selinux for eFaInit phase
sed -i "/^SELINUX=/ c\SELINUX=permissive" /etc/selinux/config

echo "Configuring services...done"
