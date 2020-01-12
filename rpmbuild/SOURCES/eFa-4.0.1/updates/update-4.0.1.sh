#!/bin/sh
#-----------------------------------------------------------------------------#
# eFa 4.0.1-x cumulative updates script
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

# add MAXMIND_LICENSE_KEY to conf.php
if [[ -z $(grep MAXMIND_LICENSE_KEY /var/www/html/mailscanner/conf.php) ]]; then
  sed -i "/^define('SESSION_TIMEOUT'/ a\\\n// MaxMind License key\n// A free license key from MaxMind is required to download GeoLite2 data\n// https://blog.maxmind.com/2019/12/18/significant-changes-to-accessing-and-using-geolite2-databases/\n// define('MAXMIND_LICENSE_KEY', 'mylicensekey');" /var/www/html/mailscanner/conf.php
fi

# Ensure MailWatchConf.pm is updated
if [[ -z $(grep MAILWATCHSQLPWD /usr/share/MailScanner/perl/custom/MailWatchConf.pm) ]]; then
  sed -i "/^my (\$db_pass) =/ c\my (\$fh);\nmy (\$pw_config) = '/etc/eFa/MailWatch-Config';\nopen(\$fh, \"<\", \$pw_config);\nif(\!\$fh) {\n  MailScanner::Log::WarnLog(\"Unable to open %s to retrieve password\", \$pw_config);\n  return;\n}\nmy (\$db_pass) = grep(/^MAILWATCHSQLPWD/,<\$fh>);\n\$db_pass =~ s/MAILWATCHSQLPWD://;\n\$db_pass =~ s/\\\n//;\nclose(\$fh);" /usr/share/MailScanner/perl/custom/MailWatchConf.pm
  # Also upgrade the db, just in case
  /usr/bin/mailwatch/tools/upgrade.php --skip-user-confirm /var/www/html/mailscanner/functions.php
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
