#!/bin/sh
#-----------------------------------------------------------------------------#
# eFa 4.0.0 initial service-configuration script
#-----------------------------------------------------------------------------#
# Copyright (C) 2013~2017 https://efa-project.org
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

# These services we really don't need.
systemctl disable lvm2-monitor
systemctl disable mdmonitor
systemctl disable smartd
systemctl disable abrtd

# These services we disable for now and enable them after eFa-Init.
# Most of these are not enabled by default but add them here just to
# make sure we don't forget them at eFa-Init.
chkconfig mailscanner off
systemctl disable postfix
systemctl disable httpd
systemctl disable mariadb
#chkconfig saslauthd off
systemctl disable crond
systemctl disable clamd@scan
chkconfig sqlgrey off
#chkconfig mailgraph-init off
chkconfig adcc off
chkconfig mysql off
#chkconfig webmin off
systemctl disable unbound
#chkconfig munin-node off
systemctl disable chronyd
systemctl disable yum-cron
systemctl disable sshd

echo "Configuring services...done"
