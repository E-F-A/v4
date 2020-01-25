#!/bin/sh
#-----------------------------------------------------------------------------#
# eFa 4.0.0 initial service-configuration script
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
# Start configuration of services
#-----------------------------------------------------------------------------#

# pre-create the EFA backup directory
mkdir -p /var/eFa/backup
mkdir -p /var/eFa/backup/KAM

# pre-create the EFA lib directory
mkdir -p /var/eFa/lib
mkdir -p /var/eFa/lib/selinux
#mkdir -p /var/eFa/lib/eFa-Configure

# Log directory
mkdir -p /var/log/eFa

# Network backup directory
mkdir -p /etc/sysconfig/network-scripts.bak

# Copy eFa-Configure
# Moved to rpm spec
#cp $srcdir/eFa/eFa-Configure /usr/sbin/eFa-Configure
#chmod 755 /usr/sbin/eFa-Configure
#cp $srcdir/eFa/lib-eFa-Configure/* /var/eFa/lib/eFa-Configure

# Write SSH banner
sed -i "/^#Banner / c\Banner /etc/banner"  /etc/ssh/sshd_config
cat > /etc/banner << 'EOF'
   Welcome to eFa (https://efa-project.org)

 Warning!

 THIS IS A PRIVATE COMPUTER SYSTEM. It is for authorized use only.
 Users (authorized or unauthorized) have no explicit or implicit
 expectation of privacy.

 Any or all uses of this system and all files on this system may
 be intercepted, monitored, recorded, copied, audited, inspected,
 and disclosed to authorized site and law enforcement personnel,
 as well as authorized officials of other agencies, both domestic
 and foreign.  By using this system, the user consents to such
 interception, monitoring, recording, copying, auditing, inspection,
 and disclosure at the discretion of authorized site personnel.

 Unauthorized or improper use of this system may result in
 administrative disciplinary action and civil and criminal penalties.
 By continuing to use this system you indicate your awareness of and
 consent to these terms and conditions of use.   LOG OFF IMMEDIATELY
 if you do not agree to the conditions stated in this warning.
EOF

# Compress logs from logrotate
sed -i "s/#compress/compress/g" /etc/logrotate.conf

# eFa selinux policy
# selinux configuration

# Is this a full vm or physical and not a container?
if [[ "$instancetype" != "lxc" ]]; then

    # Needed for apache to access postfix
    setsebool -P daemons_enable_cluster_mode 1

    # Needed for apache to exec binaries on server side
    setsebool -P httpd_ssi_exec 1

    # Needed for clamd to access system
    setsebool -P antivirus_can_scan_system 1
    setsebool -P clamd_use_jit 1

    # Needed for mailscanner to bind to tcp_socket
    setsebool -P nis_enabled 1

    # Needed for mailscanner to preserve tmpfs
    setsebool -P rsync_full_access 1

    # Needed for httpd to connect to razor
    setsebool -P httpd_can_network_connect 1

    # Allow httpd to write content
    setsebool -P httpd_unified 1

    # Allow httpd to read content
    setsebool -P httpd_read_user_content 1

    # eFa policy module
    checkmodule -M -m -o /var/eFa/lib/selinux/eFa.mod /var/eFa/lib/selinux/eFa.te
    semodule_package -o /var/eFa/lib/selinux/eFa.pp -m /var/eFa/lib/selinux/eFa.mod -f /var/eFa/lib/selinux/eFa.fc
    semodule -i /var/eFa/lib/selinux/eFa.pp
fi

# Set eFa-Init to run at first root login:
# Do not set root default password in rpm phase
sed -i '1i\\/usr\/sbin\/eFa-Init' /root/.bashrc
cp -f /etc/rc.d/rc.local /etc/rc.d/rc.local.bak
cat >> /etc/rc.local << 'EOF' 
IP=$(ip add | grep inet | grep -v inet\ 127. | grep -v inet6\ ::1 | awk '{print $2}' | awk -F'/' '{print $1}')
echo '' > /etc/issue
echo '------------------------------' >> /etc/issue
echo '---  Welcome to eFa-4.0.1  ---' >> /etc/issue
echo '------------------------------' >> /etc/issue
echo '-- https://efa-project.org ---' >> /etc/issue
echo '------------------------------' >> /etc/issue
echo '' >> /etc/issue
echo -e "IP Address(es) for GUI:\n$IP" >> /etc/issue
EOF
chmod +x /etc/rc.d/rc.local
# Set the system as unconfigured
mkdir -p /etc/eFa
echo 'CONFIGURED:NO' > /etc/eFa/eFa-Config

# Configure opendkim for verification only
sed -i "s|^KeyFile\s/etc/opendkim/keys/default.private|#&|" /etc/opendkim.conf

# Configure opendmarc
sed -i "/^# AuthservID / c\AuthservID HOSTNAME" /etc/opendmarc.conf
sed -i "/^# HistoryFile / c\HistoryFile /var/spool/opendmarc/opendmarc.dat" /etc/opendmarc.conf
sed -i "/^# PublicSuffixList / c\PublicSuffixList /etc/opendmarc/public_suffix_list.dat" /etc/opendmarc.conf

ln -s /usr/sbin/eFa-Weekly-DMARC /etc/cron.weekly/eFa-Weekly-DMARC
ln -s /usr/sbin/eFa-Daily-DMARC /etc/cron.daily/eFa-Daily-DMARC

# MariaDB
mkdir -p /etc/systemd/system/mariadb.service.d
echo -e "[Service]\nTimeoutSec=900\n" > /etc/systemd/system/mariadb.service.d/override.conf