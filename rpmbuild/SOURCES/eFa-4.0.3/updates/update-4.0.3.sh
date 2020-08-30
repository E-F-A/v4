#!/bin/sh
#-----------------------------------------------------------------------------#
# eFa 4.0.3-x cumulative updates script
#-----------------------------------------------------------------------------#
# Copyright (C) 2013~2020 https://efa-project.org
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
instancetype=$(/sbin/virt-what)
centosver=$(cat /etc/centos-release | awk -F'[^0-9]*' '{print $2}')

retval=0

function execcmd()
{
eval $cmd && [[ $? -ne 0 ]] && echo "$cmd" && retval=1
}

function randompw()
{
  PASSWD=""
  PASSWD=`openssl rand -base64 32`
}
# +---------------------------------------------------+

# Set milter queue permissions
cmd='chown postfix:postfix /var/spool/MailScanner/milterin'
execcmd
cmd='chown postfix:postfix /var/spool/MailScanner/milterout'
execcmd

# Postfix queue permissions
cmd='chown -R postfix:mtagroup /var/spool/postfix/hold'
execcmd
cmd='chown -R postfix:mtagroup /var/spool/postfix/incoming'
execcmd
cmd='chmod -R 750 /var/spool/postfix/hold'
execcmd
cmd='chmod -R 750 /var/spool/postfix/incoming'
execcmd

# sa-update, if needed
if [[ ! -d /var/lib/spamassassin/3.004004 ]]; then
  cmd='sa-update'
  execcmd
  cmd='sa-compile'
  execcmd
fi

cmd='systemctl enable clamav-unofficial-sigs.service'
execcmd
cmd='systemctl enable clamav-unofficial-sigs.timer'
execcmd

# Update SELinux
if [[ $instancetype != "lxc" ]]; then
    if [[ $centosver -eq 7 ]]; then
        cmd='checkmodule -M -m -o /var/eFa/lib/selinux/eFa.mod /var/eFa/lib/selinux/eFa.te'
        execcmd
        cmd='semodule_package -o /var/eFa/lib/selinux/eFa.pp -m /var/eFa/lib/selinux/eFa.mod -f /var/eFa/lib/selinux/eFa.fc'
        execcmd
        cmd='semodule -i /var/eFa/lib/selinux/eFa.pp'
        execcmd
    else
        cmd='checkmodule -M -m -o /var/eFa/lib/selinux/eFa.mod /var/eFa/lib/selinux/eFa8.te'
        execcmd
        cmd='semodule_package -o /var/eFa/lib/selinux/eFa.pp -m /var/eFa/lib/selinux/eFa.mod -f /var/eFa/lib/selinux/eFa.fc'
        execcmd
        cmd='semodule -i /var/eFa/lib/selinux/eFa.pp'
        execcmd
    fi
fi

cmd='systemctl daemon-reload'
execcmd
cmd='systemctl reload httpd'
execcmd
cmd='systemctl reload php-fpm'
execcmd
cmd='systemctl reload postfix'
execcmd
cmd='systemctl restart clamd@scan'
execcmd
cmd='systemctl restart clamav-unofficial-sigs.timer'
execcmd
cmd='systemctl stop sqlgrey'
execcmd
cmd='systemctl stop msmilter'
execcmd
cmd='systemctl stop mailscanner'
execcmd
cmd='systemctl stop mariadb'
execcmd
cmd='systemctl start mariadb'
execcmd
cmd='systemctl start mailscanner'
execcmd
cmd='systemctl start msmilter'
execcmd
cmd='systemctl start sqlgrey'
execcmd
cmd='systemctl enable postfix_relay'
execcmd
cmd='systemctl start postfix_relay'
execcmd
cmd='systemctl enable milter_relay'
execcmd
cmd='systemctl start milter_relay'
execcmd
cmd='systemctl enable fail2ban'
execcmd
cmd='systemctl start fail2ban'
execcmd

exit $retval
