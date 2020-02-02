#!/bin/sh
#-----------------------------------------------------------------------------#
# eFa 4.0.0 initial mailwatch-configuration script
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
# Start configuration of mailwatch
#-----------------------------------------------------------------------------#
echo "Configuring MailWatch..."

# Set php parameters needed
sed -i '/^short_open_tag =/ c\short_open_tag = On' /etc/php.ini

# Set up connection for MailWatch
sed -i "/^my (\$db_user) =/ c\my (\$db_user) = 'mailwatch';" /usr/share/MailScanner/perl/custom/MailWatchConf.pm
sed -i "/^my (\$db_pass) =/ c\my (\$fh);\nmy (\$pw_config) = '/etc/eFa/MailWatch-Config';\nopen(\$fh, \"<\", \$pw_config);\nif(\!\$fh) {\n  MailScanner::Log::WarnLog(\"Unable to open %s to retrieve password\", \$pw_config);\n  return;\n}\nmy (\$db_pass) = grep(/^MAILWATCHSQLPWD/,<\$fh>);\n\$db_pass =~ s/MAILWATCHSQLPWD://;\n\$db_pass =~ s/\\\n//;\nclose(\$fh);" /usr/share/MailScanner/perl/custom/MailWatchConf.pm

sed -i "/^define('DB_PASS',/ c\$efa_config = preg_grep('/^MAILWATCHSQLPWD/', file('/etc/eFa/MailWatch-Config'));\nforeach(\$efa_config as \$num => \$line) {\n  if (\$line) {\n    \$db_pass_tmp = chop(preg_replace('/^MAILWATCHSQLPWD:(.*)/','\$1', \$line));\n  }\n}\ndefine('DB_PASS', \$db_pass_tmp);" /var/www/html/mailscanner/conf.php
sed -i "/^define('DB_USER',/ c\define('DB_USER', 'mailwatch');" /var/www/html/mailscanner/conf.php
sed -i "/^define('TIME_ZONE',/ c\define('TIME_ZONE', 'Etc/UTC');" /var/www/html/mailscanner/conf.php
sed -i "/^define('QUARANTINE_USE_FLAG',/ c\define('QUARANTINE_USE_FLAG', true);" /var/www/html/mailscanner/conf.php
sed -i "/^define('QUARANTINE_REPORT_FROM_NAME',/ c\define('QUARANTINE_REPORT_FROM_NAME', 'eFa - Email Filter Appliance');" /var/www/html/mailscanner/conf.php
# Set to false to allow attachment release
sed -i "/^define('QUARANTINE_USE_SENDMAIL',/ c\define('QUARANTINE_USE_SENDMAIL', false);" /var/www/html/mailscanner/conf.php

sed -i "/^define('AUDIT',/ c\define('AUDIT', true);" /var/www/html/mailscanner/conf.php
sed -i "/^define('MS_LOG',/ c\define('MS_LOG', '/var/log/maillog');" /var/www/html/mailscanner/conf.php
sed -i "/^define('MAIL_LOG',/ c\define('MAIL_LOG', '/var/log/maillog');" /var/www/html/mailscanner/conf.php
sed -i "/^define('SA_DIR',/ c\define('SA_DIR', '/usr/bin/');" /var/www/html/mailscanner/conf.php
sed -i "/^define('SA_RULES_DIR',/ c\define('SA_RULES_DIR', '/etc/mail/spamassassin');" /var/www/html/mailscanner/conf.php
sed -i "/^define('SHOW_SFVERSION',/ c\define('SHOW_SFVERSION', true);" /var/www/html/mailscanner/conf.php
sed -i "/^define('SHOW_DOC',/ c\define('SHOW_DOC', false);" /var/www/html/mailscanner/conf.php
sed -i "/^define('HIDE_UNKNOWN',/ c\define('HIDE_UNKNOWN', true);" /var/www/html/mailscanner/conf.php
sed -i "/^define('SA_PREFS', MS_CONFIG_DIR . 'spam.assassin.prefs.conf');/ c\define('SA_PREFS', MS_CONFIG_DIR . 'spamassassin.conf');" /var/www/html/mailscanner/conf.php
sed -i "/^define('MAILWATCH_HOME',/ c\define('MAILWATCH_HOME', '/var/www/html/mailscanner');" /var/www/html/mailscanner/conf.php
sed -i "/^define('SHOW_SFVERSION',/ c\define('SHOW_SFVERSION', true);" /var/www/html/mailscanner/conf.php

usermod apache -G mtagroup
usermod php-fpm -G mtagroup

# MailWatch requires access to /var/spool/postfix/hold & incoming dir's
chown -R postfix:mtagroup /var/spool/postfix/hold
chown -R postfix:mtagroup /var/spool/postfix/incoming
chmod -R 750 /var/spool/postfix/hold
chmod -R 750 /var/spool/postfix/incoming

# EFA MSRE Support
sed -i "/^define('MSRE'/ c\define('MSRE', true);" /var/www/html/mailscanner/conf.php
chgrp -R php-fpm /etc/MailScanner/rules
chmod g+rwxs /etc/MailScanner/rules
chmod g+rw /etc/MailScanner/rules/*.rules

# Ensure temp and images are set 
chgrp -R php-fpm /www/html/mailscanner/images
chgrp -R php-fpm /www/html/mailscanner/temp

echo "Configuring MailWatch...done"

