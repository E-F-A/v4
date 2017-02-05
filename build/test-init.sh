#!/bin/bash
#-----------------------------------------------------------------------------#
# eFa 4.0.0 test-init script version 20170128
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
# This script provides quick configuration of a development eFa environment
# for testing purposes.  It is not meant to be secure or to ever be used in 
# production.  It is non-interactive and sets a default working configuration
# for testing purposes.  It should not be bundled with eFa and should be 
# explicitly downloaded for development purposes.
#-----------------------------------------------------------------------------#

# +---------------------------------------------------+
# Variables (Populate for testing)
# +---------------------------------------------------+
debug="0"
PASSWORD="eFaPr0j3ct"
HOSTNAME=''
DOMAINNAME=''
ADMINEMAIL=''
POSTMASTEREMAIL=''
IP4ADDRESS=''
IP4CIDR=''
IP4NETMASK=''
IP4GATEWAY=''
IP6ADDRESS=''
IP6CIDR=''
IP6GATEWAY=''
RECURSE='1'
DNSIP41=''
DNSIP42=''
DNSIP61=''
DNSIP62=''
USERNAME=''
ISUTC='true'
TZONE='Etc/UTC'
KEYBOARD='us'
IANACODE='us'
MAILSERVER=''
ORGNAME=''
# Note: CentOS7 uses predictable network interface names
# in other environments
# will need to add support for this naming scheme.
INTERFACE='eth0'
# +---------------------------------------------------+

# +---------------------------------------------------+
# Configure system
# +---------------------------------------------------+
function func_configure-system() {

 # Start mariadb Daemon
  systemctl start mariadb 

  # Network settings
  echo -e "$green[eFa]$clean - Setting new hostname"
  echo "127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4" > /etc/hosts
  echo "::1         localhost localhost.localdomain localhost6 localhost6.localdomain6" >> /etc/hosts
  echo "$IPADDRESS   $HOSTNAME.$DOMAINNAME   $HOSTNAME" >> /etc/hosts
  echo "$HOSTNAME.$DOMAINNAME" > /etc/hostname

  echo -e "$green[eFa]$clean - Setting DNS"
  echo "forward-zone:" > /etc/unbound/conf.d/forwarders.conf
  echo '  name: "."' >> /etc/unbound/conf.d/forwarders.conf
  if [[ "$RECURSE" -eq "1" ]]; then
    echo "  forward-first: yes" >> /etc/unbound/conf.d/forwarders.conf
  else
    echo "  forward-addr: $DNSIP41" >> /etc/unbound/conf.d/forwarders.conf
    echo "  forward-addr: $DNSIP42" >> /etc/unbound/conf.d/forwarders.conf
    echo "  forward-addr: $DNSIP61" >> /etc/unbound/conf.d/forwarders.conf
    echo "  forward-addr: $DNSIP62" >> /etc/unbound/conf.d/forwarders.conf
  fi

  echo -e "$green[eFa]$clean - Setting IP settings"
  sed -i '/^BOOTPROTO=/ c\BOOTPROTO="none"' /etc/sysconfig/network-scripts/ifcfg-$INTERFACE
  sed -i '/^IPV6_AUTOCONF=/ c\IPV6_AUTOCONF="no"' /etc/sysconfig/network-scripts/ifcfg-$INTERFACE
  echo "NETMASK=\"$IP4NETMASK\"" >> /etc/sysconfig/network-scripts/ifcfg-$INTERFACE
  echo "IPADDR=\"$IP4ADDRESS\"" >> /etc/sysconfig/network-scripts/ifcfg-$INTERFACE
  echo "IPV6ADDR=\"$IP6ADDRESS/$IP6CIDR\"" >> /etc/sysconfig/network-scripts/ifcfg-$INTERFACE
  echo "DNS1=\"127.0.0.1\"" >> /etc/sysconfig/network-scripts/ifcfg-$INTERFACE
  echo "DNS2=\"::1\"" >> /etc/sysconfig/network-scripts/ifcfg-$INTERFACE
  echo "GATEWAY=\"$IP4GATEWAY\"" >> /etc/sysconfig/network
  echo "IPV6_DEFAULTGW=\"$IP6GATEWAY\"" >> /etc/sysconfig/network
  systemctl restart network
  systemctl start unbound
  
  echo -e "$green[eFa]$clean - Creating user"
  useradd -m -d /home/$USERNAME -s /bin/bash $USERNAME
  echo "$USERNAME:$PASSWORD" | chpasswd --md5 $USERNAME

  echo -e "$green[eFa]$clean - Generating SSH Host keys"
  rm -f /etc/ssh/ssh_host_rsa_key
  rm -f /etc/ssh/ssh_host_dsa_key
  ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa
  ssh-keygen -f /etc/ssh/ssh_host_dsa_key -N '' -t dsa
  
  echo -e "$green[eFa]$clean - Configure timezone"
  rm -f /etc/localtime
  ln -s /usr/share/zoneinfo/$TZONE /etc/localtime
  echo "ZONE=$TZONE">>/etc/sysconfig/clock
  
  # Write ianacode to freshclam config.
  sed -i "/^#DatabaseMirror / c\DatabaseMirror db.$IANACODE.clamav.net" /etc/freshclam.conf
  
  echo -e "$green[eFa]$clean - Configuring razor"
  su postfix -s /bin/bash -c 'razor-admin -create'
  su postfix -s /bin/bash -c 'razor-admin -register'
  sed -i '/^debuglevel/ c\debuglevel             = 0' /var/spool/postfix/.razor/razor-agent.conf
  chown -R postfix:mtagroup /var/spool/postfix/.razor
  chmod ug+rwx /var/spool/postfix/.razor
  # setgid to lock in mtagroup group for new files
  chmod ug+s /var/spool/postfix/.razor
  chmod ug+rw /var/spool/postfix/.razor/*
  
  echo -e "$green[eFa]$clean - Updating AV and SA rules"

  systemctl start clamd@scan
  freshclam

  /usr/bin/clamav-unofficial-sigs.sh

  sa-update
  sa-compile

  echo -e "$green[eFa]$clean - Allow the current to receive mails"
  echo "" >> /etc/postfix/transport
  echo "###### START eFa ADDED DOMAINS ######" >> /etc/postfix/transport
  echo "$DOMAINNAME  smtp:[$MAILSERVER]" >> /etc/postfix/transport
  rm -f /etc/postfix/transport.db
  postmap /etc/postfix/transport

  echo "root: $ADMINEMAIL" >> /etc/aliases

  echo -e "$green[eFa]$clean - Configuring spamassassin"
  sed -i '/bayes_ignore_header/d' /etc/MailScanner/spamassassin.conf
  echo "bayes_ignore_header X-$ORGNAME-MailScanner-eFa">>/etc/MailScanner/spamassassin.conf
  echo "bayes_ignore_header X-$ORGNAME-MailScanner-eFa-SpamCheck">>/etc/MailScanner/spamassassin.conf
  echo "bayes_ignore_header X-$ORGNAME-MailScanner-eFa-SpamScore">>/etc/MailScanner/spamassassin.conf
  echo "bayes_ignore_header X-$ORGNAME-MailScanner-eFa-Information">>/etc/MailScanner/spamassassin.conf
  sed -i "/^envelope_sender_header / c\envelope_sender_header X-$ORGNAME-MailScanner-eFa-From" /etc/MailScanner/spamassassin.conf

  echo -e "$green[eFa]$clean - Configuring MailScanner"
  sed -i "/^%org-name% =/ c\%org-name% = $ORGNAME" /etc/MailScanner/MailScanner.conf
  sed -i "/^%org-long-name% =/ c\%org-long-name% = $ORGNAME" /etc/MailScanner/MailScanner.conf
  sed -i "/^%web-site% =/ c\%web-site% = https://www.efa-project.org" /etc/MailScanner/MailScanner.conf
  sed -i "/^Use Watermarking =/ c\Use Watermarking = yes" /etc/MailScanner/MailScanner.conf
  sed -i "/^Information Header Value =/ c\Information Header Value = Please contact $ADMINEMAIL for more information" /etc/MailScanner/MailScanner.conf
  sed -i "/^Unscanned Header Value =/ c\Unscanned Header Value = Please contact $ADMINEMAIL for details" /etc/MailScanner/MailScanner.conf
  sed -i "/^Hostname =/ c\Hostname = $HOSTNAME.$DOMAINNAME" /etc/MailScanner/MailScanner.conf

  echo -e "To: *@$DOMAINNAME /etc/MailScanner/reports/en/inline.sig.in.html" > /etc/MailScanner/rules/sig.html.rules
  echo -e "To: default /etc/MailScanner/reports/en/inline.sig.out.html" >> /etc/MailScanner/rules/sig.html.rules
  echo -e "To: *@$DOMAINNAME /etc/MailScanner/reports/en/inline.sig.in.txt" > /etc/MailScanner/rules/sig.text.rules
  echo -e "To: default /etc/MailScanner/reports/en/inline.sig.out.txt" >> /etc/MailScanner/rules/sig.text.rules

  echo -e "$green[eFa]$clean - Configuring MailWatch"
  sed -i "/^define('QUARANTINE_FROM_ADDR',/ c\define('QUARANTINE_FROM_ADDR', '$USERNAME@$DOMAINNAME');" /var/www/html/mailscanner/conf.php
  sed -i "/^define('TIME_ZONE',/ c\define('TIME_ZONE', '$TZONE');" /var/www/html/mailscanner/conf.php

  echo "$USERNAME ALL=(ALL) ALL" >> /etc/sudoers.d/eFa-users
  echo "$USERNAME ALL=(ALL) NOPASSWD: /usr/sbin/eFa-Configure" >> /etc/sudoers.d/eFa-users

  /usr/bin/mysql -u root -p"$PASSWORD" mailscanner -e "INSERT INTO users SET username = '$USERNAME', password = md5('$PASSWORD'), fullname = 'Administrator', type ='A'"
  /usr/bin/mysql -u root -p"$PASSWORD" mailscanner -e "INSERT INTO whitelist SET to_address = 'default', to_domain = '', from_address = '127.0.0.1'"
  /usr/bin/mysql -u root -p"$PASSWORD" mailscanner -e "INSERT INTO whitelist SET to_address = 'default', to_domain = '', from_address = '::1'"

  sed -i "/^;date.timezone =/ c\date.timezone = $TZONE" /etc/php.ini

  SAUSERSQLPWD=$PASSWORD
  /usr/bin/mysql -u root -p"$PASSWORD" -e "UPDATE mysql.user SET Password=PASSWORD('$SAUSERSQLPWD') WHERE User='sa_user';"
  /usr/bin/mysql -u root -p"$PASSWORD" -e "FLUSH PRIVILEGES;"
  sed -i "/bayes_sql_password/ c\bayes_sql_password              $SAUSERSQLPWD" /etc/MailScanner/spamassassin.conf
  sed -i "/user_awl_sql_password/ c\user_awl_sql_password           $SAUSERSQLPWD" /etc/MailScanner/spamassassin.conf
  sed -i "/\usr\/bin\/mysql -usa_user / c\\/usr\/bin\/mysql -usa_user -p$SAUSERSQLPWD < \/etc\/trim-awl.sql" /usr/sbin/trim-awl

  MAILWATCHSQLPWD=$PASSWORD
  /usr/bin/mysql -u root -p"$PASSWORD" -e "UPDATE mysql.user SET Password=PASSWORD('$MAILWATCHSQLPWD') WHERE User='mailwatch';"
  /usr/bin/mysql -u root -p"$PASSWORD" -e "FLUSH PRIVILEGES;"

  SQLGREYSQLPWD=$PASSWORD
  /usr/bin/mysql -u root -p"$PASSWORD" -e "UPDATE mysql.user SET Password=PASSWORD('$SQLGREYSQLPWD') WHERE User='sqlgrey';"
  /usr/bin/mysql -u root -p"$PASSWORD" -e "FLUSH PRIVILEGES;"
  sed -i "/db_pass =/ c\db_pass = $SQLGREYSQLPWD" /etc/sqlgrey/sqlgrey.conf

  EFASQLPWD=$PASSWORD
  /usr/bin/mysql -u root -p"$PASSWORD" -e "UPDATE mysql.user SET Password=PASSWORD('$EFASQLPWD') WHERE User='efa';"
  /usr/bin/mysql -u root -p"$PASSWORD" -e "FLUSH PRIVILEGES;"

  echo $PASSWORD | saslpasswd2 -p -c /etc/sasldb2
  chgrp postfix /etc/sasldb2

  WATERMARK=$PASSWORD
  sed -i "/^Watermark Secret =/ c\Watermark Secret = %org-name%-$WATERMARK" /etc/MailScanner/MailScanner.conf

  echo "HOSTNAME:$HOSTNAME" >> /etc/eFa-Config
  echo "DOMAINNAME:$DOMAINNAME" >> /etc/eFa-Config
  echo "ADMINEMAIL:$ADMINEMAIL" >> /etc/eFa-Config
  echo "INTERFACE:$INTERFACE" >> /etc/eFa-Config
  echo "IP4ADDRESS:$IP4ADDRESS" >> /etc/eFa-Config
  echo "IP4NETMASK:$IP4NETMASK" >> /etc/eFa-Config
  echo "IP4GATEWAY:$IP4GATEWAY" >> /etc/eFa-Config
  if [[ "$RECUSE" -eq 1 ]]; then
    echo "RECURSION:ENABLED" >> /etc/eFa-Config
  else
    echo "RECURSION:DISABLED" >> /etc/eFa-Config
  fi
  echo "DNSIP41:$DNSIP41" >> /etc/eFa-Config
  echo "DNSIP42:$DNSIP42" >> /etc/eFa-Config
  echo "DNSIP61:$DNSIP61" >> /etc/eFa-Config
  echo "DNSIP62:$DNSIP62" >> /etc/eFa-Config
  echo "IANA:$IANACODE" >> /etc/eFa-Config
  echo "MAILSERVER:$MAILSERVER" >> /etc/eFa-Config
  echo "ORGNAME:$ORGNAME" >> /etc/eFa-Config
  echo "SAUSERSQLPWD:$SAUSERSQLPWD" >> /etc/eFa-Config
  echo "MAILWATCHSQLPWD:$MAILWATCHSQLPWD" >> /etc/eFa-Config
  echo "SQLGREYSQLPWD:$SQLGREYSQLPWD" >> /etc/eFa-Config
  echo "EFASQLPWD:$EFASQLPWD" >> /etc/eFa-Config
  echo "MYSQLROOTPWD:$PASSWORD" >> /etc/eFa-Config
  echo "POSTMASTEREMAIL:$POSTMASTEREMAIL" >> /etc/eFa-Config
  
  sed -i "/CONFIGURED:/ c\CONFIGURED:YES" /etc/eFa-Config

  chown root:mtagroup /etc/eFa-Config
  chmod 640 /etc/eFa-Config

  chkconfig mailscanner on
  systemctl enable postfix
  systemctl enable httpd
  systemctl enable mariadb
  #chkconfig saslauthd off
  systemctl enable crond
  systemctl enable clamd@scan
  chkconfig sqlgrey on
  #chkconfig mailgraph-init off
  chkconfig adcc on
  #chkconfig webmin off
  systemctl enable unbound
  #chkconfig munin-node off
  systemctl enable chronyd
  systemctl enable yum-cron
  
  echo -e "$green[eFa]$clean - Done"
}
# +---------------------------------------------------+

# +---------------------------------------------------+
# The header above all menu's
# +---------------------------------------------------+
func_echo-header(){
    clear
    echo -e "--------------------------------------------------------------"
    echo -e "---        Welcome to the eFa Test Configuration           ---"
    echo -e "---                http://www.efa-project.org              ---"
    echo -e "--------------------------------------------------------------"
    echo ""
}
# +---------------------------------------------------+

# +---------------------------------------------------+
# Start
# +---------------------------------------------------+
clear
red='\E[00;31m'
green='\E[00;32m'
yellow='\E[00;33m'
blue='\E[00;34m'
magenta='\E[00;35'
cyan='\E[00;36m'
clean='\e[00m'

func_echo-header
CONFIGURED="`grep CONFIGURED /etc/eFa-Config | sed 's/^.*://'`"
if [ $CONFIGURED == "NO" ]; then
   echo -e "$green[eFa]$clean Configuring system..."
   func_configure-system
else
   echo -e "$red         ERROR: eFa is already configured $clean"
fi