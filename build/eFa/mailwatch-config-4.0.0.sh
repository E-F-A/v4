#!/bin/sh
#-----------------------------------------------------------------------------#
# eFa 4.0.0 initial mailwatch-configuration script
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
# Start configuration of mailwatch
#-----------------------------------------------------------------------------#

# Set php parameters needed
sed -i '/^short_open_tag =/ c\short_open_tag = On' /etc/php.ini

# Set up connection for MailWatch
sed -i "/^my (\$db_user) =/ c\my (\$db_user) = 'mailwatch';" /usr/share/MailScanner/perl/custom/MailWatch.pm
sed -i "/^my (\$db_pass) =/ c\my (\$fh);\nmy (\$pw_config) = '/etc/EFA-Config';\nopen(\$fh, \"<\", \$pw_config);\nif(\!\$fh) {\n  MailScanner::Log::WarnLog(\"Unable to open %s to retrieve password\", \$pw_config);\n  return;\n}\nmy (\$db_pass) = grep(/^MAILWATCHSQLPWD/,<\$fh>);\n\$db_pass =~ s/MAILWATCHSQLPWD://;\n\$db_pass =~ s/\\\n//;\nclose(\$fh);" /usr/share/MailScanner/perl/custom/MailWatch.pm

# Set up SQLBlackWhiteList
sed -i "/^    my (\$db_user) =/ c\    my (\$db_user) = 'mailwatch';" /usr/share/MailScanner/perl/custom/SQLBlackWhiteList.pm
sed -i "/^    my (\$db_pass) =/ c\    my (\$fh);\nmy (\$pw_config) = '/etc/EFA-Config';\n    open(\$fh, \"<\", \$pw_config);\n    if(\!\$fh) {\n      MailScanner::Log::WarnLog(\"Unable to open %s to retrieve password\", \$pw_config);\n      return;\n    }\n    my (\$db_pass) = grep(/^MAILWATCHSQLPWD/,<\$fh>);\n    \$db_pass =~ s/MAILWATCHSQLPWD://;\n    \$db_pass =~ s/\\\n//;\n    close(\$fh);" /usr/share/MailScanner/perl/custom/SQLBlackWhiteList.pm

# Set up SQLSpamSettings
sed -i "/^my (\$db_user) =/ c\my (\$db_user) = 'mailwatch';" /usr/share/MailScanner/perl/custom/SQLSpamSettings.pm
sed -i "/^my (\$db_pass) =/ c\my (\$fh);\nmy (\$pw_config) = '/etc/EFA-Config';\nopen(\$fh, \"<\", \$pw_config);\nif(\!\$fh) {\n  MailScanner::Log::WarnLog(\"Unable to open %s to retrieve password\", \$pw_config);\n  return;\n}\nmy (\$db_pass) = grep(/^MAILWATCHSQLPWD/,<\$fh>);\n\$db_pass =~ s/MAILWATCHSQLPWD://;\n\$db_pass =~ s/\\\n//;\nclose(\$fh);" /usr/share/MailScanner/perl/custom/SQLSpamSettings.pm

sed -i "/^define('DB_PASS',/ c\$efa_config = preg_grep('/^MAILWATCHSQLPWD/', file('/etc/EFA-Config'));\nforeach(\$efa_config as \$num => \$line) {\n  if (\$line) {\n    \$db_pass_tmp = chop(preg_replace('/^MAILWATCHSQLPWD:(.*)/','\$1', \$line));\n  }\n}\ndefine('DB_PASS', \$db_pass_tmp);" /var/www/html/mailscanner/conf.php
sed -i "/^define('DB_USER',/ c\define('DB_USER', 'mailwatch');" /var/www/html/mailscanner/conf.php
sed -i "/^define('TIME_ZONE',/ c\define('TIME_ZONE', 'Etc/UTC');" /var/www/html/mailscanner/conf.php
sed -i "/^define('QUARANTINE_USE_FLAG',/ c\define('QUARANTINE_USE_FLAG', true);" /var/www/html/mailscanner/conf.php
sed -i "/^define('QUARANTINE_REPORT_FROM_NAME',/ c\define('QUARANTINE_REPORT_FROM_NAME', 'EFA - Email Filter Appliance');" /var/www/html/mailscanner/conf.php
sed -i "/^define('QUARANTINE_USE_SENDMAIL',/ c\define('QUARANTINE_USE_SENDMAIL', true);" /var/www/html/mailscanner/conf.php
sed -i "/^define('AUDIT',/ c\define('AUDIT', true);" /var/www/html/mailscanner/conf.php
sed -i "/^define('MS_LOG',/ c\define('MS_LOG', '/var/log/maillog');" /var/www/html/mailscanner/conf.php
sed -i "/^define('MAIL_LOG',/ c\define('MAIL_LOG', '/var/log/maillog');" /var/www/html/mailscanner/conf.php
sed -i "/^define('SA_DIR',/ c\define('SA_DIR', '/usr/bin/');" /var/www/html/mailscanner/conf.php
sed -i "/^define('SA_RULES_DIR',/ c\define('SA_RULES_DIR', '/etc/mail/spamassassin');" /var/www/html/mailscanner/conf.php
sed -i "/^define('SHOW_SFVERSION',/ c\define('SHOW_SFVERSION', false);" /var/www/html/mailscanner/conf.php
sed -i "/^define('SHOW_DOC',/ c\define('SHOW_DOC', false);" /var/www/html/mailscanner/conf.php
sed -i "/^define('HIDE_UNKNOWN',/ c\define('HIDE_UNKNOWN', true);" /var/www/html/mailscanner/conf.php
sed -i "/^define('SA_PREFS', MS_CONFIG_DIR . 'spam.assassin.prefs.conf');/ c\define('SA_PREFS', MS_CONFIG_DIR . 'spamassassin.conf');" /var/www/html/mailscanner/conf.php

# Set up a redirect in web root to MailWatch
cat > /var/www/html/index.html << 'EOF'
<!DOCTYPE html>
<html>
    <head>
    <title>MailWatch</title>"
    <meta http-equiv=\"refresh\" content=\"0; url=/mailscanner/\" />
    </head>"
    <body>
         <a href=\"/mailscanner/\">Click Here for MailWatch</a>
    </body>
</html>
EOF

# Grabbing an favicon to complete the look
cp $srcdir/mailwatch/favicon.ico /var/www/html/favicon.ico
/bin/cp -f favicon.ico /var/www/html/mailscanner/
/bin/cp -f favicon.ico /var/www/html/mailscanner/images
/bin/cp -f favicon.ico /var/www/html/mailscanner/images/favicon.png

# EFA Branding
cp $srcdir/mailwatch/EFAlogo-47px.gif /var/www/html/mailscanner/images/EFAlogo-47px.gif
cp $srcdir/mailwatch/EFAlogo-79px.png /var/www/html/mailscanner/images/EFAlogo-79px.png
mv mailwatch-logo.png mailwatch-logo.png.orig
mv mailscannerlogo.gif mailscannerlogo.gif.orig
ln -s EFAlogo-79px.png mailwatch-logo.png
ln -s EFAlogo-47px.gif mailscannerlogo.gif
ln -s EFAlogo-79px.png mailwatch-logo.gif

sed -i 's/#f7ce4a/#999999/g' /var/www/html/mailscanner/login.php

# Change the yellow to match website colors..
sed -i 's/#F7CE4A/#999999/g' /var/www/html/mailscanner/style.css

# Add Mailgraph link and remove dnsreport link
# TODO

# Add munin to mailwatch
# sed -i "/^    echo '<li><a href=\"geoip_update.php\">/a\    /*Begin EFA*/\n    echo '<li><a href=\"mailgraph.php\">View Mailgraph Statistics</a>';\n    \$hostname = gethostname\(\);\n    echo '<li><a href=\"https://' \. \$hostname \. ':10000\">Webmin</a>';\n    \$efa_config = preg_grep('/^MUNINPWD/', file('/etc/EFA-Config'));\n    foreach(\$efa_config as \$num => \$line) {\n      if (\$line) {\n        \$munin_pass = chop(preg_replace('/^MUNINPWD:(.*)/','\$1', \$line));\n      }\n    }\n    echo '<li><a href=\"https://munin:' . \$munin_pass . '@'  . \$hostname . '/munin\">View Munin Statistics</a>';\n    /*End EFA*/" other.php

cat >> /var/www/html/mailscanner/functions.php << 'EOF'
/**
 * EFA Version
 */
function efa_version()
{
  return file_get_contents( '/etc/EFA-Version', NULL, NULL, 0, 15 );
}
EOF

sed -i "/^    echo mailwatch_version/a \    echo ' running on ' . efa_version();" /var/www/html/mailscanner/functions.php

usermod apache -G mtagroup

# Place the learn scripts
# Release script removed in eFa v4 (unless we can figure out a new method)
# Contains no logic to limit recipient(s) to internal recipients only
# Superceded for now with autorelease code in MailWatch

cp $srcdir/mailwatch/learn-msg.cgi /var/www/cgi-bin/learn-msg.cgi
chmod 755 /var/www/cgi-bin/learn-msg.cgi
cp $srcdir/mailwatch/learned.html /var/www/html/learned.html
cp $srcdir/mailwatch/notlearned.html /var/www/html/notlearned.html
cp $srcdir/mailwatch/denylearned.html /var/www/html/denylearned.html

# MailWatch requires access to /var/spool/postfix/hold & incoming dir's
chown -R postfix:mtagroup /var/spool/postfix/hold
chown -R postfix:mtagroup /var/spool/postfix/incoming
chmod -R 750 /var/spool/postfix/hold
chmod -R 750 /var/spool/postfix/incoming

# Allow apache to sudo and run the MailScanner lint test
sed -i '/Defaults    requiretty/ c\#Defaults    requiretty' /etc/sudoers
echo "apache ALL=NOPASSWD: /usr/sbin/MailScanner --lint" > /etc/sudoers.d/EFA-Services

# EFA MSRE Support
sed -i "/^define('MSRE'/ c\define('MSRE', true);" /var/www/html/mailscanner/conf.php
chgrp -R apache /etc/MailScanner/rules
chmod g+rwxs /etc/MailScanner/rules
chmod g+rw /etc/MailScanner/rules/*.rules
ln -s /usr/bin/mailwatch/tools/Cron_jobs/msre_reload.crond /etc/cron.d/msre_reload.crond
ln -s /usr/bin/mailwatch/tools/MailScanner_rule_editor/msre_reload.sh /usr/local/bin/msre_reload.sh
chmod ugo+x /usr/bin/mailwatch/tools/MailScanner_rule_editor/msre_reload.sh

cp $srcdir/mailwatch/geoip_update_cmd.php /usr/sbin/geoip_update_cmd.php

