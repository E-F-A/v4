#!/bin/sh
#-----------------------------------------------------------------------------#
# eFa 4.0.0 initial sqlgrey-configuration script
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
# Start configuration of sqlgrey
#-----------------------------------------------------------------------------#
echo "Configuring sqlgrey..."

# pre-create the local files so users won't be confused if the file is not there.
touch /etc/sqlgrey/clients_ip_whitelist.local
touch /etc/sqlgrey/clients_fqdn_whitelist.local

# Whitelist localhost
echo "127.0.0.1" >> /etc/sqlgrey/clients_ip_whitelist.local

# Make the changes to the config file...
sed -i '/conf_dir =/ c\conf_dir = /etc/sqlgrey' /etc/sqlgrey/sqlgrey.conf
sed -i '/user =/ c\user = sqlgrey' /etc/sqlgrey/sqlgrey.conf
sed -i '/group =/ c\group = sqlgrey' /etc/sqlgrey/sqlgrey.conf
sed -i '/connect_src_throttle =/ c\connect_src_throttle = 5' /etc/sqlgrey/sqlgrey.conf
sed -i "/awl_age = 32/d" /etc/sqlgrey/sqlgrey.conf
sed -i "/group_domain_level = 10/d" /etc/sqlgrey/sqlgrey.conf
sed -i '/awl_age =/ c\awl_age = 60' /etc/sqlgrey/sqlgrey.conf
sed -i '/group_domain_level =/ c\group_domain_level = 2' /etc/sqlgrey/sqlgrey.conf
sed -i '/db_type =/ c\db_type = mysql' /etc/sqlgrey/sqlgrey.conf
sed -i '/db_name =/ c\db_name = sqlgrey' /etc/sqlgrey/sqlgrey.conf
sed -i '/db_host =/ c\db_host = localhost' /etc/sqlgrey/sqlgrey.conf
sed -i '/db_port =/ c\db_port = default' /etc/sqlgrey/sqlgrey.conf
sed -i '/db_user =/ c\db_user = sqlgrey' /etc/sqlgrey/sqlgrey.conf
sed -i "/db_pass =/ c\db_pass = $password" /etc/sqlgrey/sqlgrey.conf
sed -i '/db_cleandelay =/ c\db_cleandelay = 1800' /etc/sqlgrey/sqlgrey.conf
sed -i '/clean_method =/ c\clean_method = sync' /etc/sqlgrey/sqlgrey.conf
sed -i '/prepend =/ c\prepend = 1' /etc/sqlgrey/sqlgrey.conf
sed -i "/reject_first_attempt\/reject_early_reconnect/d" /etc/sqlgrey/sqlgrey.conf
sed -i '/reject_first_attempt =/ c\reject_first_attempt = immed' /etc/sqlgrey/sqlgrey.conf
sed -i '/reject_early_reconnect =/ c\reject_early_reconnect = immed' /etc/sqlgrey/sqlgrey.conf
sed -i "/reject_code = dunno/d" /etc/sqlgrey/sqlgrey.conf
sed -i '/reject_code =/ c\reject_code = 451' /etc/sqlgrey/sqlgrey.conf
sed -i '/whitelists_host =/ c\whitelists_host = sqlgrey.bouton.name' /etc/sqlgrey/sqlgrey.conf
sed -i '/optmethod =/ c\optmethod = optout' /etc/sqlgrey/sqlgrey.conf

# start and stop sqlgrey (first launch will create all database tables)
# We give it 15 seconds to populate the database and then stop it again.
systemctl start sqlgrey
sleep 15
systemctl stop sqlgrey

echo "Configuring sqlgrey...done"
