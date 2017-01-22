#!/bin/sh
#-----------------------------------------------------------------------------#
# eFa 4.0.0 initial pyzor-configuration script
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
# Start configuration of pyzor
#-----------------------------------------------------------------------------#
# Fix deprecation warning message
sed -i '/^#!\/usr\/bin\/python/ c\#!\/usr\/bin\/python -Wignore::DeprecationWarning' /usr/bin/pyzor

mkdir /var/spool/postfix/.pyzor
ln -s /var/spool/postfix/.pyzor /var/www/.pyzor
chown -R postfix:mtagroup /var/spool/postfix/.pyzor
chmod -R ug+rwx /var/spool/postfix/.pyzor

# and finally initialize the servers file with an discover.
su postfix -s /bin/bash -c 'pyzor discover'