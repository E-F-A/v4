#!/bin/sh
#-----------------------------------------------------------------------------#
# eFa 4.0.0 initial dcc-configuration script
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
# Start configuration of dcc
#-----------------------------------------------------------------------------#
echo "Configuring dcc..."

ln -s /var/dcc/libexec/cron-dccd /usr/bin/cron-dccd
ln -s /var/dcc/libexec/cron-dccd /etc/cron.monthly/cron-dccd
cat >> /etc/MailScanner/spamassassin.conf << 'EOF'

#Begin eFa mods for dcc

ifplugin Mail::SpamAssassin::Plugin::DCC
  dcc_home /var/dcc
  dcc_path /usr/bin/dccproc
endif 

#End eFa mods for dcc

EOF

sed -i '/^DCCIFD_ENABLE=/ c\DCCIFD_ENABLE=on' /var/dcc/dcc_conf
sed -i '/^DBCLEAN_LOGDAYS=/ c\DBCLEAN_LOGDAYS=1' /var/dcc/dcc_conf
sed -i '/^DCCIFD_LOGDIR=/ c\DCCIFD_LOGDIR="/var/dcc/log"' /var/dcc/dcc_conf
chown postfix:mtagroup /var/dcc

cp /var/dcc/libexec/rcDCC /etc/init.d/adcc
sed -i "s/#loadplugin Mail::SpamAssassin::Plugin::DCC/loadplugin Mail::SpamAssassin::Plugin::DCC/g" /etc/mail/spamassassin/v310.pre

/usr/local/bin/cdcc "add dcc1.dcc-servers.net"
/usr/local/bin/cdcc "add dcc2.dcc-servers.net"
/usr/local/bin/cdcc "add dcc3.dcc-servers.net"
/usr/local/bin/cdcc "add dcc4.dcc-servers.net"
/usr/local/bin/cdcc "add dcc5.dcc-servers.net"
echo '/^DCCPOOL:/ c\DCCPOOL:default' >> /etc/eFa-Config

echo "Configuring dcc...done"

