#!/bin/sh
#-----------------------------------------------------------------------------#
# eFa 4.0.0 initial yum-cron configuration script
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
# Start configuration of yum-cron
#-----------------------------------------------------------------------------#
echo "Configuring automatic updates..."

# Enable automatic updates in the config
if [[ $centosver -eq 7 ]]; then
    sed -i "/apply_updates =/ c\apply_updates = yes" /etc/yum/yum-cron.conf

    # Disable alerts from hourly cron and let yum cron handle alerts
    sed -i "s|^exec /usr/sbin/yum-cron /etc/yum/yum-cron-hourly.conf$|exec /usr/sbin/yum-cron /etc/yum/yum-cron-hourly.conf >/dev/null 2>\&1|" /etc/cron.hourly/0yum-hourly.cron
else
    sed -i "/apply_updates =/ c\apply_updates = yes" /etc/dnf/automatic.conf
fi

echo "Configuring automatic updates...done"
