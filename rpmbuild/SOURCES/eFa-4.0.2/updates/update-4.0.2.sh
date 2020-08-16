#!/bin/sh
#-----------------------------------------------------------------------------#
# eFa 4.0.2-x cumulative updates script
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

# Create ruleset for password protected files
if [ ! -f /etc/MailScanner/rules/password.rules ]; then
  echo -e "From:\t127.0.0.1\tyes" > /etc/MailScanner/rules/password.rules
  echo -e "From:\t::1\tyes" >> /etc/MailScanner/rules/password.rules
  echo -e "FromOrTo:\tdefault\tno" >> /etc/MailScanner/rules/password.rules
else
  # fixup
  sed -i "/^From:\t::1\tno/ c\From:\t::1\tyes" /etc/MailScanner/rules/password.rules
  if [[ -z $(grep ::1 /etc/MailScanner/rules/password.rules) ]]; then
     sed -i "/^From:\t127.0.0.1\tyes$/ a\From:\t::1\tyes" /etc/MailScanner/rules/password.rules
  fi
  sed -i "/^FromOrTo:\tdefault\tnos/ c\FromOrTo:\tdefault\tno" /etc/MailScanner/rules/password.rules
  sed -i "/^FromOrTo:\tdeffault\tno/ c\FromOrTo:\tdefault\tno" /etc/MailScanner/rules/password.rules
fi

# Fix missing ipv6
if [[ -z $(grep ::1 /etc/MailScanner/rules/content.scanning.rules) ]]; then
     sed -i "/^From:\t127.0.0.1\tno$/ a\From:\t::1\tno" /etc/MailScanner/rules/content.scanning.rules
fi
# Fix missing ipv4
if [[ -z $(grep 127.0.0.1 /etc/MailScanner/filetype.rules) ]]; then
     sed -i "/^From:\t::1/ a\From:\t127.0.0.1\t/etc/MailScanner/filetype.rules.allowall.conf" /etc/MailScanner/filetype.rules
fi

# Add new archive rules variants
if [[ ! -f /etc/MailScanner/archives.filename.rules.allowall.conf ]]; then
  echo -e "allow\t.*\t-\t-" > /etc/MailScanner/archives.filename.rules.allowall.conf
fi
if [[ ! -f /etc/MailScanner/archives.filename.rules ]]; then
  sed -i "/^Archives: Filename Rules =/ c\Archives: Filename Rules = %etc-dir%/archives.filename.rules" /etc/MailScanner/MailScanner.conf
  echo -e "From:\t127.0.0.1\t/etc/MailScanner/archives.filename.rules.allowall.conf" > /etc/MailScanner/archives.filename.rules
  echo -e "From:\t::1\t/etc/MailScanner/archives.filename.rules.allowall.conf" >> /etc/MailScanner/archives.filename.rules
  echo -e "FromOrTo:\tdefault\t/etc/MailScanner/archives.filename.rules.conf" >> /etc/MailScanner/archives.filename.rules
fi
if [[ ! -f /etc/MailScanner/archives.filetype.rules.allowall.conf ]]; then
  echo -e "allow\t\.\*\t-\t-" > /etc/MailScanner/archives.filetype.rules.allowall.conf
fi
if [[ ! -f /etc/MailScanner/archives.filetype.rules ]]; then
  sed -i "/^Archives: Filetype Rules =/ c\Archives: Filetype Rules = %etc-dir%/archives.filetype.rules" /etc/MailScanner/MailScanner.conf
  echo -e "From:\t127.0.0.1\t/etc/MailScanner/archives.filetype.rules.allowall.conf" > /etc/MailScanner/archives.filetype.rules
  echo -e "From:\t::1\t/etc/MailScanner/archives.filetype.rules.allowall.conf" >> /etc/MailScanner/archives.filetype.rules
  echo -e "FromOrTo:\tdefault\t/etc/MailScanner/archives.filetype.rules.conf" >> /etc/MailScanner/archives.filetype.rules
fi

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

if [[ $centosver -eq 7 ]]; then
    # Fix razor reporting
    if [[ ! -L /var/lib/php/fpm/.razor ]]; then
        rm -rf /var/lib/php/fpm/.razor >/dev/null 2>&1
        ln -s /var/spool/postfix/.razor /var/lib/php/fpm/.razor
    fi
else
    if [[ ! -L /var/www/html/.razor ]]; then
        rm -rf /var/www/html/.razor >/dev/null 2>&1
        ln -s /var/spool/postfix/.razor /var/www/html/.razor
    fi
fi

# Enable new OLEVBMacro plugin
sed -i "/^# loadplugin Mail::SpamAssassin::Plugin::OLEVBMacro$/ c\loadplugin Mail::SpamAssassin::Plugin::OLEVBMacro" /etc/mail/spamassassin/v343.pre

cmd='systemctl enable clamav-unofficial-sigs.service'
execcmd
cmd='systemctl enable clamav-unofficial-sigs.timer'
execcmd

# Update txrep table
/usr/bin/mysql sa_bayes -e "ALTER TABLE txrep CHANGE count msgcount INT(11) NOT NULL DEFAULT '0';" >/dev/null 2>&1

# Fix GeoIP Symlink
if [[ -L /usr/share/GeoIP/GeoLiteCountry.dat ]]; then
  rm -f /usr/share/GeoIP/GeoLiteCountry.dat
fi
if [[ ! -L /usr/share/GeoIP/GeoLite2-Country.mmdb ]]; then
  rm -f /usr/share/GeoIP/GeoLite2-Country.mmdb >/dev/null 2>&1
  ln -s /var/www/html/mailscanner/temp/GeoLite2-Country.mmdb /usr/share/GeoIP/GeoLite2-Country.mmdb
fi

# Add configuration parameter for GeoIP2
if [[ -z $(grep uri_country_db_path /etc/MailScanner/spamassassin.conf) ]]; then
  echo '' >> /etc/MailScanner/spamassassin.conf
  echo 'ifplugin Mail::SpamAssassin::Plugin::URILocalBL' >> /etc/MailScanner/spamassassin.conf
  echo '    uri_country_db_path /usr/share/GeoIP/GeoLite2-Country.mmdb' >> /etc/MailScanner/spamassassin.conf
  echo 'endif' >> /etc/MailScanner/spamassassin.conf
fi
if [[ -z $(grep geoip2_default_db_path /etc/MailScanner/spamassassin.conf) ]]; then
  echo 'ifplugin Mail::SpamAssassin::Plugin::RelayCountry' >> /etc/MailScanner/spamassassin.conf
  echo '    geoip2_default_db_path /usr/share/GeoIP/GeoLite2-Country.mmdb' >> /etc/MailScanner/spamassassin.conf
  echo 'endif' >> /etc/MailScanner/spamassassin.conf
fi

# Update MailWatchConf.pm
sed -i "/^my (\$db_pass) = 'mailwatch';$/ c\my (\$fh);\nmy (\$pw_config) = '/etc/eFa/MailWatch-Config';\nopen(\$fh, \"<\", \$pw_config);\nif(\!\$fh) {\n  MailScanner::Log::WarnLog(\"Unable to open %s to retrieve password\", \$pw_config);\n  return;\n}\nmy (\$db_pass) = grep(/^MAILWATCHSQLPWD/,<\$fh>);\n\$db_pass =~ s/MAILWATCHSQLPWD://;\n\$db_pass =~ s/\\\n//;\nclose(\$fh);" /usr/share/MailScanner/perl/custom/MailWatchConf.pm

# Enable RelayCountry Plugin
sed -i "/^# loadplugin Mail::SpamAssassin::Plugin::RelayCountry/ c\loadplugin Mail::SpamAssassin::Plugin::RelayCountry" /etc/mail/spamassassin/init.pre

# Fix dns
if [[ -n $(grep "nameserver=127.0.0.1" /etc/resolv.conf) ]]; then
    echo "nameserver 127.0.0.1" > /etc/resolv.conf
fi

# Ensure symlink is present
ln -s /etc/MailScanner/spamassassin.conf /etc/mail/spamassassin/mailscanner.cf  >/dev/null 2>&1

# Fix 1x1 spacer
sed -i "/^Web Bug Replacement = https:\/\/s3.amazonaws.com\/msv5\/images\/spacer.gif/ c\Web Bug Replacement = http://dl.efa-project.org/static/1x1spacer.gif" /etc/MailScanner/MailScanner.conf

# Update SELinux
if [[ $centosver -eq 7 ]]; then
    if [[ $instancetype != "lxc" ]]; then
    cmd='checkmodule -M -m -o /var/eFa/lib/selinux/eFa.mod /var/eFa/lib/selinux/eFa.te'
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

exit $retval
