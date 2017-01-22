#!/bin/sh
#-----------------------------------------------------------------------------#
# eFa 4.0.0 initial prepare script
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
# Change the root password
echo "- Changing the root password"
echo "root:$password" | chpasswd --md5 root

echo "Adding Firewall rules"
firewall-cmd --permanent --add-service=smtp
firewall-cmd --permanent --add-service=ssh
firewall-cmd --permanent --add-port 80/tcp
firewall-cmd --permanent --add-port 443/tcp
firewall-cmd --permanent --add-port 587/tcp
firewall-cmd --reload
