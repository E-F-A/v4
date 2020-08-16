#!/bin/sh
#-----------------------------------------------------------------------------#
# eFa 4.0.0 initial razor-configuration script
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
# Start configuration of razor
#-----------------------------------------------------------------------------#
echo "Configuring razor..."
mkdir /var/spool/postfix/.razor
ln -s /var/spool/postfix/.razor /var/www/.razor
if [[ $centosver -eq 7 ]]; then
    ln -s /var/spool/postfix/.razor /var/lib/php/fpm/.razor
fi
chown postfix:mtagroup /var/spool/postfix/.razor
chmod -R ug+rwx /var/spool/postfix/.razor

# Use setgid bit
chmod ug+s /var/spool/postfix/.razor

echo "Configuring razor...done"