#!/bin/sh
#-----------------------------------------------------------------------------#
# eFa 4.0.0 initial clamav-configuration script
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
# Start configuration of clamav
#-----------------------------------------------------------------------------#
clamav_version=$(rpm -q --queryformat=%{VERSION} clamav-server})

setsebool -P antivirus_can_scan_system 1
useradd -d /etc/clamd.d -M -s /sbin/nologin clamav
sed -i '/^Example/ c\#Example' /etc/freshclam.conf
cp /usr/share/doc/clamav-server-$clamav_version/clamd.conf /etc/clamd.d/clamd.conf
sed -i '/^Example/ c\#Example' /etc/clamd.d/clamd.conf
sed -i '/^User <USER>/ c\User clamav' /etc/clamd.d/clamd.conf
sed -i '/#LocalSocket /var/run/clamd<SERVICE>/clamd.sock/ c\LocalSocket /var/run/clamd<SERVICE>/clamd.sock' /etc/clamd.d/clamd.conf
cat > /usr/lib/systemd/system/clam-freshclam.service << 'EOF'
# Run the freshclam as daemon
[Unit]
Description = freshclam scanner
After = network.target

[Service]
Type = forking
ExecStart = /usr/bin/freshclam -d -c 4
Restart = on-failure
PrivateTmp = true

[Install]
WantedBy=multi-user.target

EOF
cat > /usr/lib/systemd/system/clamd.service << 'EOF'
[Unit]
Description = clamd scanner daemon
After = syslog.target nss-lookup.target network.target

[Service]
Type = simple
ExecStart = /usr/sbin/clamd -c /etc/clamd.d/clamd.conf --nofork=yes
Restart = on-failure
PrivateTmp = true

[Install]
WantedBy=multi-user.target
EOF

cp /usr/share/doc/clamav-server-$clamav_version/clamd.logrotate /etc/logrotate.d/clamd
cat > /etc/sysconfig/clamd << 'EOF'
CLAMD_CONFIGFILE=/etc/clamd.d/<SERVICE>.conf
CLAMD_SOCKET=/var/run/clamd.<SERVICE>/clamd.sock
#CLAMD_OPTIONS=
EOF
chown -R clamav:clamav /etc/clamd.d
mkdir -p /var/log/clamd
chown -R clamav:clamav /var/log/clamd
mkdir -p /var/run/clamd
chown -R clamav:clamav /var/run/clamd

