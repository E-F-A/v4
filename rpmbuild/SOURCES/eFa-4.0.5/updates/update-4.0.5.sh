#!/bin/sh
#-----------------------------------------------------------------------------#
# eFa 4.0.5-x cumulative updates script
#-----------------------------------------------------------------------------#
# Copyright (C) 2013~2023 https://efa-project.org
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

# +---------------------------------------------------+

# make eFa able to connect to remote database other than localhost
# localhost becomes the default
if [[ -z $(grep ^EFASQLHOST /etc/eFa/eFa-Config) ]]; then
  echo "EFASQLHOST:localhost" >> /etc/eFa/eFa-Config
fi

if [[ -z $(grep ^MYSQLHOST /etc/eFa/MySQL-Config) ]]; then
  echo "MYSQLHOST:localhost" >> /etc/eFa/MySQL-Config
fi

if [[ -z $(grep ^MAILWATCHSQLHOST /etc/eFa/MailWatch-Config) ]]; then
  echo "MAILWATCHSQLHOST:localhost" >> /etc/eFa/MailWatch-Config
fi

if [[ -z $(grep ^SQLGREYSQLHOST /etc/eFa/SQLGrey-Config) ]]; then
  echo "SQLGREYSQLHOST:localhost" >> /etc/eFa/SQLGrey-Config
fi

if [[ -z $(grep ^SAUSERSQLHOST /etc/eFa/SA-Config) ]]; then
  echo "SAUSERSQLHOST:localhost" >> /etc/eFa/SA-Config
fi

if [[ -z $(grep ^DMARCSQLHOST /etc/eFa/openDMARC-Config) ]]; then
  echo "DMARCSQLHOST:localhost" >> /etc/eFa/openDMARC-Config
fi

# Refresh CustomAction.pm
if [[ -f /var/eFa/backup/CustomAction.pm.old ]]; then
  rm -f /var/eFa/backup/CustomAction.pm.old
fi
if [[ -f /var/eFa/backup/CustomAction.pm ]]; then
  mv /var/eFa/backup/CustomAction.pm /var/eFa/backup/CustomAction.pm.old
fi
mv /usr/share/MailScanner/perl/custom/CustomAction.pm /var/eFa/backup/CustomAction.pm
cp /var/eFa/lib/token/CustomAction.pm /usr/share/MailScanner/perl/custom/CustomAction.pm

# Refresh MailWatchConf.pm
if [[ -f /var/eFa/backup/MailWatchConf.pm.old ]]; then
  rm -f /var/eFa/backup/MailWatchConf.pm.old
fi
if [[ -f /var/eFa/backup/MailWatchConf.pm ]]; then
  mv /var/eFa/backup/MailWatchConf.pm /var/eFa/backup/MailWatchConf.pm.old
fi
mv /usr/share/MailScanner/perl/custom/MailWatchConf.pm /var/eFa/backup/MailWatchConf.pm
cp /var/eFa/lib/token/MailWatchConf.pm /usr/share/MailScanner/perl/custom/MailWatchConf.pm

# Update DB_HOST in conf.php to read from /etc/eFa/MailWatch-Config
if [[ -z $(grep -w MAILWATCHSQLHOST /var/www/html/mailscanner/conf.php) ]]; then
   sed -i "/^define('DB_HOST'/ c\$efa_config = preg_grep('\/^MAILWATCHSQLHOST\/', file('\/etc\/eFa/MailWatch-Config'));\nforeach(\$efa_config as \$num => \$line) {\n  if (\$line) {\n    \$db_host_tmp = chop(preg_replace('\/^MAILWATCHSQLHOST:(.*)\/','\$1', \$line));\n  }\n}\ndefine('DB_HOST', \$db_host_tmp);" /var/www/html/mailscanner/conf.php
fi

exit $retval
