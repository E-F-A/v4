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

# Move symlink for cron-dccd
if [[ -e /etc/cron.monthly/cron-dccd ]]; then
  cmd='rm -f /etc/cron.monthly/cron-dccd'
  execcmd
  cmd='ln -s /var/dcc/libexec/cron-dccd /etc/cron.daily/cron-dccd'
  execcmd
fi

# Tweak mariadb configuration
# Remove limits on mariadb
cmd='mkdir -p /etc/systemd/system/mariadb.service.d'
execcmd
if [[ ! -f /etc/systemd/system/mariadb.service.d/limit.conf ]]; then
  cat > /etc/systemd/system/mariadb.service.d/limit.conf << 'EOF'
[Service]
LimitNOFILE=infinity
LimitMEMLOCK=infinity
EOF
  [[ $? -ne 0 ]] && echo "cat > /etc/systemd/system/mariadb.service.d/limit.conf" && retval=1
fi

# Create ruleset for password protected files
if [ ! -f /etc/MailScanner/rules/password.rules ]; then
  echo -e "From:\t127.0.0.1\tyes" > /etc/MailScanner/rules/password.rules
  echo -e "From:\t::1\tyes" >> /etc/MailScanner/rules/password.rules
  echo -e "FromOrTo:\tdefault\tno" >> /etc/MailScanner/rules/password.rules
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

# Always refresh /root/.my.cnf
cmd='echo "[client]" > /root/.my.cnf'
execcmd
cmd='echo "user=root" >> /root/.my.cnf'
execcmd
cmd="echo \"password=$(grep ^MYSQLROOTPWD /etc/eFa/MySQL-Config | sed -e 's/^.*://')\" >> /root/.my.cnf"
execcmd
cmd='chmod 400 /root/.my.cnf'
execcmd

# Cleanup
cmd='rm -rf /var/www/eFaInit'
[[ -d /var/www/eFaInit ]] && execcmd
cmd='rm -f /usr/sbin/eFa-Init'
[[ -f /usr/sbin/eFa-Init ]] && execcmd
cmd='rm -f /usr/sbin/eFa-Commit'
[[ -f /usr/sbin/eFa-Commit ]] && execcmd

if [[ -f /etc/httpd/conf.d/vhost.conf ]]; then
  cmd='rm -f /etc/httpd/conf.d/vhost.conf'
  execcmd
fi

# Is redirect file present?
if [[ -f /etc/httpd/conf.d/redirectssl.conf ]]; then
  # Has it been updated with ServerName?
  if [[ -z $(grep ServerName /etc/httpd/conf.d/redirectssl.conf) ]]; then
    echo '<VirtualHost _default_:80>' > /etc/httpd/conf.d/redirectssl.conf
    echo "  ServerName $HOSTNAME.$DOMAINNAME:80" >> /etc/httpd/conf.d/redirectssl.conf
    echo "  RewriteEngine On" >> /etc/httpd/conf.d/redirectssl.conf
    echo '  RewriteCond %{SERVER_PORT} 80' >> /etc/httpd/conf.d/redirectssl.conf
    echo '  RewriteCond %{REQUEST_URI} !^/\.well\-known/acme\-challenge/' >> /etc/httpd/conf.d/redirectssl.conf
    echo '  RewriteRule ^/?(.*) https://%{SERVER_NAME}/$1 [R,L]' >> /etc/httpd/conf.d/redirectssl.conf
    echo '</VirtualHost>' >> /etc/httpd/conf.d/redirectssl.conf
  fi
else 
  # File needs to exist with at least the following
  echo '<VirtualHost _default_:80>' > /etc/httpd/conf.d/redirectssl.conf
  echo "  ServerName $HOSTNAME.$DOMAINNAME:80" >> /etc/httpd/conf.d/redirectssl.conf
  echo '</VirtualHost>' >> /etc/httpd/conf.d/redirectssl.conf
fi

# Make sure temp is present for mariadb
cmd='mkdir /var/lib/mysql/temp && chown mysql:mysql /var/lib/mysql/temp'
[[ ! -d /var/lib/mysql/temp ]] && execcmd

# Increase TimeoutSec for clamd@scan
if [[ ! -f /etc/systemd/system/clamd@scan.service.d/override.conf ]]; then
    mkdir -p /etc/systemd/system/clamd@scan.service.d
    echo -e "[Service]\nTimeoutSec=900\n" > /etc/systemd/system/clamd@scan.service.d/override.conf
    cmd='chcon -u system_u -r object_r -t systemd_unit_file_t /etc/systemd/system/clamd@scan.service.d'
    [[ $instancetype != "lxc" ]] && execcmd
    cmd='chcon -u system_u -r object_r -t systemd_unit_file_t /etc/systemd/system/clamd@scan.service.d/override.conf'
    [[ $instancetype != "lxc" ]] && execcmd
fi

# Increase TimeoutSec for mariadb
if [[ ! -f /etc/systemd/system/mariadb.service.d/override.conf ]]; then
    mkdir -p /etc/systemd/system/mariadb.service.d
    echo -e "[Service]\nTimeoutSec=900\n" > /etc/systemd/system/mariadb.service.d/override.conf
    cmd='chcon -u system_u -r object_r -t systemd_unit_file_t /etc/systemd/system/mariadb.service.d'
    [[ $instancetype != "lxc" ]] && execcmd
    cmd='chcon -u system_u -r object_r -t systemd_unit_file_t /etc/systemd/system/mariadb.service.d/override.conf'
    [[ $instancetype != "lxc" ]] && execcmd
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

# Ensure symlink is present
ln -s /etc/MailScanner/spamassassin.conf /etc/mail/spamassassin/mailscanner.cf  >/dev/null 2>&1

# Fix 1x1 spacer
sed -i "/^Web Bug Replacement = https:\/\/s3.amazonaws.com\/msv5\/images\/spacer.gif/ c\Web Bug Replacement = http://dl.efa-project.org/static/1x1spacer.gif" /etc/MailScanner/MailScanner.conf

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

# Fix >dev/null to >/dev/null in eFa-SAClean
if [[ -n $(grep '>dev/null' /etc/cron.daily/eFa-SAClean) ]]; then
    cat > /etc/cron.daily/eFa-SAClean << 'EOF'
#!/bin/sh
# MailScanner_incoming SA Cleanup
/usr/sbin/tmpwatch -u 48 /var/spool/MailScanner/incoming/SpamAssassin-Temp >/dev/null 2>&1
EOF
    chmod ugo+x /etc/cron.daily/eFa-SAClean
fi

# Fix apache failure after recent update (Allow use of LanguagePriority)
sed -i "/^#LoadModule negotiation_module modules\/mod_negotiation.so/ c\LoadModule negotiation_module modules/mod_negotiation.so" /etc/httpd/conf.modules.d/00-base.conf 

# Razor fixes
if [[ -z $(grep razorhome /var/spool/postfix/.razor/razor-agent.conf) ]]; then
    echo 'razorhome              = /var/spool/postfix/.razor' >> /var/spool/postfix/.razor/razor-agent.conf
    if [[ $centosver -eq 7 ]]; then
        samplepath="$(rpm -q spamassassin | sed -e 's/eFa\.el7\.x86_64//' | sed -e 's/-1\.//')"
    else
        samplepath='spamassassin'
    fi
    su -c "/bin/cat /usr/share/doc/$samplepath/sample-spam.txt | razor-report -d" -s /bin/bash postfix
    touch /var/spool/postfix/.razor/razor-agent.log
    chmod 640 /var/spool/postfix/.razor/{identity-*,razor-agent.conf}
    chmod 664 /var/spool/postfix/.razor/razor-agent.log
    chmod 644 /var/spool/postfix/.razor/server*
    chmod ug+s /var/spool/postfix/.razor
fi

if [[ -z $(grep razor_config /etc/MailScanner/spamassassin.conf) ]]; then
    echo '' >> /etc/MailScanner/spamassassin.conf
    echo 'ifplugin Mail::SpamAssassin::Plugin::Razor2' >> /etc/MailScanner/spamassassin.conf
    echo 'razor_config  /var/spool/postfix/.razor/razor-agent.conf' >> /etc/MailScanner/spamassassin.conf
    echo 'endif' >> /etc/MailScanner/spamassassin.conf
fi

# Enable maintenance mode if not enabled
MAINT=0
if [[ -f /etc/cron.d/eFa-Monitor.cron ]]; then
    rm -f /etc/cron.d/eFa-Monitor.cron
    MAINT=1
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
cmd='systemctl enable clamav-freshclam'
execcmd
cmd='systemctl start clamav-freshclam'
execcmd

# Disable maintenance mode if disabled during script
if [[ $MAINT -eq 1 ]]; then
    echo "* * * * * root /usr/sbin/eFa-Monitor-cron >/dev/null 2>&1" > /etc/cron.d/eFa-Monitor.cron
fi

exit $retval
