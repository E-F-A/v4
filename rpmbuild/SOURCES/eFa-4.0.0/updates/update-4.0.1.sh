#!/bin/sh
#-----------------------------------------------------------------------------#
# eFa 4.0.1-x cumulative updates script
#-----------------------------------------------------------------------------#
# Copyright (C) 2013~2019 https://efa-project.org
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

# Remove login mismatch requirement for submission
cmd='sed -i "/^\s\s-o smtpd_sender_restrictions=reject_sender_login_mismatch/d" /etc/postfix/master.cf'
execcmd

# Create ruleset for password protected files
if [ ! -f /etc/MailScanner/rules/password.rules ]; then
  echo -e "From:\t127.0.0.1\tyes" > /etc/MailScanner/rules/password.rules
  echo -e "From:\t::1\tyes" >> /etc/MailScanner/rules/password.rules
  echo -e "FromOrTo:\tdefault\tno" >> /etc/MailScanner/rules/password.rules
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

exit $retval
