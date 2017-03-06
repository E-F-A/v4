#!/bin/sh
#-----------------------------------------------------------------------------#
# eFa 4.0.0 initial postscreen-configuration script
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
# Start configuration of Postfix
#-----------------------------------------------------------------------------#
echo "Configuring postscreen..."

echo "TODO: UNFINISHED TESTING SCRIPT DO NOT USE!"

# /etc/postfix/postscreen_dnsbl_reply_map.pcre

echo "- Commenting out 'smtp .. inet n ... smtpd' service in master.cf."
sed -i '/^smtp .*inet.*smtpd$/s/^/#/' /etc/postfix/master.cf

echo "- Uncommenting 'smtp inet ... postscreen' service in master.cf"
sed -i '/^#smtp *.*inet.*postscreen$/s/^#//g' /etc/postfix/master.cf

echo "- Uncommenting 'smtpd pass ... smtpd' service in master.cf."
sed -i '/^#smtpd.*pass.*smtpd$/s/^#//g' /etc/postfix/master.cf

echo "- Uncommenting 'tlsproxy unix ... tlsproxy' service in master.cf"
sed -i '/^#tlsproxy.*unix.*tlsproxy$/s/^#//g' /etc/postfix/master.cf

echo "- Uncommenting 'dnsblog unix ... dnsblog' service in master.cf"
sed -i '/^#dnsblog.*unix.*dnsblog$/s/^#//g' /etc/postfix/master.cf

# Postscreen access cidr file (TODO auto update from eFa servers ?)
touch /etc/postfix/postscreen_access.cidr
postconf -e postscreen_access_list="permit_mynetworks, cidr:/etc/postfix/postscreen_access.cidr"
