#!/usr/bin/env bash
#-----------------------------------------------------------------------------#
# eFa docker container startup script
#-----------------------------------------------------------------------------#
# Copyright (C) 2013~2021 https://efa-project.org
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

set -Eeuo pipefail

#Variables
HOSTNAME=${HOSTNAME:-efa}
DOMAINNAME=${DOMAINNAME:-local}
ADMINEMAIL=${ADMINEMAIL:-admin@local}
USERNAME=${USERNAME:-admin}
efauserpwd=${efauserpwd:-adminpwd}
CLIUSERNAME=${CLIUSERNAME:-admin}
efaclipwd=${efaclipwd:-adminpwd}
TZONE=${TZONE:-UTC}
KEYBOARD=${KEYBOARD:-us}
MAILSERVER=${MAILSERVER:-smtp}
IANACODE=${IANACODE:-au}
ORGNAME=${ORGNAME:-Company}

#echo "Hostname: $HOSTNAME"
#echo "Domain Name: $DOMAINNAME"
#echo "Adminemail: $ADMINEMAIL"
#echo "Username: $USERNAME"
#echo "Passwd: $efauserpwd"
#echo "CliUsername: $CLIUSERNAME"
#echo "CliPasswd: $efaclipwd"
#echo "TZ: $TZONE"
#echo "KB: $KEYBOARD"
#echo "MailServer: $MAILSERVER"
#echo "IANA: $IANACODE"
#echo "ORG: $ORGNAME"

#Colours
red='\E[00;31m'
green='\E[00;32m'
yellow='\E[00;33m'
blue='\E[00;34m'
magenta='\E[00;35'
cyan='\E[00;36m'
clean='\e[00m'

#Our IP address
IPV4ADDRESS=$(hostname -I)


#Resolve /var/dcc contents. Folder is empty if redirected to use a volume
echo -e "$green[eFa]$clean - Configuring 'dcc' contents..."
if [ ! -d /var/dcc ]; then
  mkdir /var/dcc
fi
if [ -z "$(ls -A /var/dcc/)" ]; then
  chown postfix:mtagroup /var/dcc
  mv /var/dcc.orig/* /var/dcc/.
fi
if [ -d /var/dcc.orig ]; then
  rm -Rf /var/dcc.orig
fi

#Create mising files and folder if /var/log is redirected to a volume
#Some services recover gracefully, others crash and burn if a file or folder is missing
if [ ! -d /var/log/audit ]; then
  echo -e "$green[eFa]$clean - Creating /var/log/audit..."
  mkdir /var/log/audit
fi

if [ ! -d /var/log/httpd ]; then
  echo -e "$green[eFa]$clean - Creating /var/log/httpd..."
  mkdir /var/log/httpd
fi

if [ ! -d /var/log/php-fpm ]; then
  echo -e "$green[eFa]$clean - Creating /var/log/php-fpm..."
  mkdir /var/log/php-fpm
fi

if [ ! -d /var/spool/MailScanner/milterin ]; then
  echo -e "$green[eFa]$clean - Creating /var/spool/MailScanner/milterin..."
  mkdir /var/spool/MailScanner/milterin
fi

if [ ! -d /var/spool/MailScanner/milterout ]; then
  echo -e "$green[eFa]$clean - Creating /var/spool/MailScanner/milterout..."
  mkdir /var/spool/MailScanner/milterout
fi

if [ ! -f /var/log/clamd.scan ]; then
  echo -e "$green[eFa]$clean - Creating /var/log/clamd.scan..."
  touch /var/log/clamd.scan && chown clamscan:clamscan /var/log/clamd.scan && chmod 644 /var/log/clamd.scan
fi

#First time configuration
if [ ! -f "/firstrun" ]; then
	echo -e "$green[eFa]$clean - Running first start configuration..."
		
	#These 'fixes' could be moved to eFa-Commit to make it more container friendly
	if grep -q 'hostname $HOSTNAME.$DOMAINNAME' "/usr/sbin/eFa-Commit"; then
	  echo "Don't set hostname in a docker container..."
	  grep -iIl 'hostname $HOSTNAME.$DOMAINNAME' /usr/sbin/eFa-Commit | xargs sed -i 's/hostname $HOSTNAME.$DOMAINNAME/echo echo $HOSTNAME.$DOMAINNAME/g'
	fi
		
	if grep -q 'systemctl start firewalld' "/usr/sbin/eFa-Commit"; then
	  echo "Don't enable firewall in a docker container..."
	  grep -iIl 'systemctl start firewalld' /usr/sbin/eFa-Commit | xargs sed -i 's/systemctl start firewalld/echo Not starting firewall/g'
	fi
	if grep -q 'firewall-cmd' "/usr/sbin/eFa-Commit"; then
	  echo "Don't configure firewall in a docker container..."
	  grep -iIl 'firewall-cmd' /usr/sbin/eFa-Commit | xargs sed -i 's/firewall-cmd/echo Not configuring firewall/g'
	fi
	
	if grep -q 'systemctl start sqlgrey' "/usr/sbin/eFa-Commit"; then
 	  echo "Don't use fork for sqlgrey"
	  grep -iIl 'systemctl start sqlgrey' /usr/sbin/eFa-Commit | xargs sed -i 's/systemctl start sqlgrey/sqlgrey \&/g'
	fi
	
	#SQL is not restarting correctly. To be fixed later...
	if grep -q 'systemctl restart mariadb' "/usr/sbin/eFa-Commit"; then
	  echo "Modify SQL Restart..."
	  grep -iIl 'systemctl restart mariadb' /usr/sbin/eFa-Commit | xargs sed -i 's/systemctl restart mariadb/kill -9 `pidof mysqld` \&\& systemctl start mariadb/g'
	fi

	#Don't remove until stable
	if grep -q 'rm -rf' "/usr/sbin/eFa-Commit"; then
 	  echo "Don't remove src files"
	  grep -iIl 'rm -rf' /usr/sbin/eFa-Commit | xargs sed -i 's/rm -rf/echo -rf/g'
	fi
	if grep -q '&& rm ' "/usr/sbin/eFa-Post-Init"; then
 	  echo "Don't remove install files"
	  grep -iIl '&& rm ' /usr/sbin/eFa-Post-Init | xargs sed -i 's/rm/echo/g'
	fi
	
	#Don't self-destruct
	if grep -q 'kill' "/usr/sbin/eFa-Post-Init"; then
 	  echo "Dont kill ourselves"
	  grep -iIl 'kill ' /usr/sbin/eFa-Post-Init | xargs sed -i 's/kill/echo/g'
	fi

	#razor fails to configure if postfix does not have permission to folder
	echo -e "$green[eFa]$clean - Creating / configuring 'postfix' volume..."
	chmod 757 /var/spool/postfix

	#php-fpm fails to start if folder is missing. Move to "eFa-commit" script?
	if  [ ! -d /run/php-fpm ]; then
	  echo "Creating php-fpm folder..."
	  mkdir /run/php-fpm
	fi
	
	echo -e "$green[eFa]$clean - Generating encrypted passwords..."
	efauserpwd=$(htpasswd -nbBC 10 "" "$efauserpwd" | tr -d ':\n')
	efaclipwd=$(python -c "import crypt; print(crypt.crypt('$efaclipwd', crypt.mksalt(crypt.METHOD_SHA512)))")

	if [ -z "$(ls -A /var/lib/mysql)" ]; then
	  echo -e "$green[eFa]$clean - Configuring eFa (mariadb)..."
	  chown mysql:mysql /var/lib/mysql && chmod 755 /var/lib/mysql
	  
	  if [ ! -d /var/log/mariadb ]; then
	    echo -e "$green[eFa]$clean - Creating /var/log/mariadb..."
	    mkdir /var/log/mariadb && chown mysql:mysql /var/log/mariadb && chmod 750 /var/log/mariadb
	  fi

	  /usr/sbin/eFa-Commit --startmariadb --verbose --ianacode=$IANACODE --orgname=$ORGNAME --mailserver=$MAILSERVER --adminemail=$ADMINEMAIL --efauserpwd="$efauserpwd" --username=$USERNAME --cliusername=$CLIUSERNAME --efaclipwd="$efaclipwd" --ipv4address=$IPV4ADDRESS --hostname=$HOSTNAME --domainname=$DOMAINNAME
	  if [[ $? -ne 0 ]]; then
	    echo -e "$red[eFa]$clean - Error initializing system!  Please try again..."
	    exit 1
	  fi
	else
	  echo -e "$green[eFa]$clean - Starting mariadb..."
	  systemctl start mariadb
	  if [[ $? -ne 0 ]]; then
	    echo -e "$red[eFa]$clean - Error initializing system!  Please try again..."
	    exit 1
	  fi
	fi
	
	echo -e "$green[eFa]$clean - Configuring eFa..."
	/usr/sbin/eFa-Commit --genhostkeys --configiana --configcert --configrazor --configsa --configtransport --configmailscanner --configmailwatch --configsasl --configsqlgrey --configdmarc --configmysql --configapache --configyumcron --configroot --configcli --verbose --ianacode=$IANACODE --orgname=$ORGNAME --mailserver=$MAILSERVER --adminemail=$ADMINEMAIL --efauserpwd="$efauserpwd" --username=$USERNAME --cliusername=$CLIUSERNAME --efaclipwd="$efaclipwd" --ipv4address=$IPV4ADDRESS --hostname=$HOSTNAME --domainname=$DOMAINNAME
	if [[ $? -ne 0 ]]; then
	  echo -e "$red[eFa]$clean - Error initializing system!  Please try again..."
	  exit 1
	fi

	echo -e "$green[eFa]$clean - Configuring eFa (finalize)..."
	/usr/sbin/eFa-Commit --finalize --verbose --ianacode=$IANACODE --orgname=$ORGNAME --mailserver=$MAILSERVER --adminemail=$ADMINEMAIL --efauserpwd="$efauserpwd" --username=$USERNAME --cliusername=$CLIUSERNAME --efaclipwd="$efaclipwd" --ipv4address=$IPV4ADDRESS --hostname=$HOSTNAME --domainname=$DOMAINNAME
	if [[ $? -ne 0 ]]; then
	  echo -e "$red[eFa]$clean - Error initializing system!  Please try again..."
	  exit 1
	fi

	#Fix postfix permissions post configuration
	chmod 755 /var/spool/postfix

	#Set to not configured to allow configuration scripts to re-run
	if [ -f "/etc/eFa/eFa-Config" ]; then
	  sed -i "/CONFIGURED:YES/ c\CONFIGURED:NO" /etc/eFa/eFa-Config
	fi
	
	#Run Post-Init script
	echo -e "$green[eFa]$clean - Running eFA-Post-Init..."
	if [[ -f /reboot.system ]]; then
	  rm -f /reboot.system
	fi
	/bin/bash /usr/sbin/eFa-Post-Init
		
	touch /firstrun
fi

#Re-configure IP address
echo -e "$green[eFa]$clean - Configuring IPv4..."
/usr/sbin/eFa-Commit --confighost --verbose --ipv4address=$IPV4ADDRESS --hostname=$HOSTNAME --domainname=$DOMAINNAME
if [[ $? -ne 0 ]]; then
  echo -e "$red[eFa]$clean - Error initializing system!  Please try again..."
  exit 1
fi

#Start Services. Half of these don't need restarting as their configuration did not change
#Which need restaring and which need starting if not running?
if (( ! $(ps -ef | grep -v grep | grep mysqld | wc -l) > 0 )); then
  echo -e "$green[eFa]$clean - Start 'mariadb'..."
  systemctl start mariadb
fi

if (( ! $(ps -ef | grep -v grep | grep sshd | wc -l) > 0 )); then
  echo -e "$green[eFa]$clean - Start 'sshd'..."
  systemctl start sshd
fi

echo -e "$green[eFa]$clean - Start / re-start 'php-fpm'..."
systemctl restart php-fpm
echo -e "$green[eFa]$clean - Start / re-start 'httpd'..."
systemctl restart httpd
echo -e "$green[eFa]$clean - Start / re-start 'mailscanner'..."
systemctl restart mailscanner
echo -e "$green[eFa]$clean - Start / re-start 'postfix'..."
systemctl restart postfix
echo -e "$green[eFa]$clean - Start / re-start 'postfix_relay'..."
systemctl restart postfix_relay
echo -e "$green[eFa]$clean - Start / re-start 'milter_relay'..."
systemctl restart milter_relay
#systemctl restart clamd@scan #No need to restart, Post-Init already re-loaded after updating signatures
#Best if PR could be included: https://github.com/extremeshok/clamav-unofficial-sigs/issues/294
echo -e "$green[eFa]$clean - Start / re-start 'clamav sigs'..."
systemctl restart clamav-unofficial-sigs
echo -e "$green[eFa]$clean - Start / re-start 'yum-cron'..."
systemctl restart yum-cron
echo -e "$green[eFa]$clean - Start / re-start 'opendkim'..."
systemctl restart opendkim
echo -e "$green[eFa]$clean - Finished starting services"
#Not working. Missing certs. Where are they set?
#echo "Start / re-start 'unbound'..."
#systemctl restart unbound &
#echo "Start / re-start 'dovecot'..."
#systemctl restart dovecot &

echo ""
echo "My IP Address: $IPV4ADDRESS"
echo ""
echo "++++++++++++++++++++++++++++++++++++++++++++++++"
echo "+ Your E-F-A v4 container is now ready to use! +"
echo "++++++++++++++++++++++++++++++++++++++++++++++++"
echo ""

tail -f /var/log/maillog
