#!/bin/sh
#-----------------------------------------------------------------------------#
# eFa 4.0.0 initial clamav unofficial-sigs-configuration script
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
# Start configuration of clamav unofficial sigs
#-----------------------------------------------------------------------------#
sed -i '/^#user_configuration_complete="yes"/s/^#//g' /etc/clamav-unofficial-sigs/user.conf
sed -i '/^ExecStart=/ c\ExecStart=/usr/sbin/clamav-unofficial-sigs.sh' /usr/lib/systemd/system/clamav-unofficial-sigs.service
sed -i '/^WantedBy=/ c\WantedBy=clam.scan.service'  /usr/lib/systemd/system/clamav-unofficial-sigs.timer
sed -i '/^clamd_restart_opt=/ c\clamd_restart_opt=systemctl restart clam.scan' /etc/clamav-unofficial-sigs/os.conf
sed -i '/^clamd_reload_opt=/ c\clamd_reload_opt=="clamdscan --config-file=/etc/clamd.d/clamd.conf --reload' /etc/clamav-unofficial-sigs/os.conf

#-----------------------------------------------------------------------------#
# Finalize the installation
#-----------------------------------------------------------------------------#
/usr/bin/clamav-unofficial-sigs.sh --install-logrotate
/usr/bin/clamav-unofficial-sigs.sh --install-man
