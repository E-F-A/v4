#!/bin/sh
#-----------------------------------------------------------------------------#
# eFa 4.0.0 initial clamav-configuration script
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
# Start configuration of clamav
#-----------------------------------------------------------------------------#
echo "Configuring clamav..."

usermod -G mtagroup,virusgroup,clamupdate clamscan

sed -i '/^Example/ c\#Example' /etc/freshclam.conf
sed -i '/REMOVE ME/d' /etc/sysconfig/freshclam
sed -i '/^Example/ c\#Example' /etc/clamd.d/scan.conf
sed -i '/#LocalSocket\s/ c\LocalSocket /var/run/clamd.socket/clamd.sock' /etc/clamd.d/scan.conf
sed -i '/#LogFile\s/ c\LogFile /var/log/clamd.scan' /etc/clamd.d/scan.conf

touch /var/log/clamd.scan
chown clamscan:clamscan /var/log/clamd.scan
if [[ "$instancetype" != "lxc" ]]; then
  chcon -u system_u -r object_r -t antivirus_log_t /var/log/clamd.scan
  semanage fcontext -a -t antivirus_log_t /var/log/clamd.scan
fi
mkdir -p /var/run/clamd.socket
chown -R clamscan:mtagroup /var/run/clamd.socket
echo "d /run/clamd.socket 0750 clamscan mtagroup -" > /etc/tmpfiles.d/clamd.socket.conf
chcon -u system_u -r object_r -t antivirus_var_t /run/clamd.socket
semanage fcontext -a -t antivirus_var_t /run/clamd.socket

freshclam

echo "Configuring clamav...done"

