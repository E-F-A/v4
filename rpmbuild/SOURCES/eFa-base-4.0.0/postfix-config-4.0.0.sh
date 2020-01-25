#!/bin/sh
#-----------------------------------------------------------------------------#
# eFa 4.0.0 initial postfix-configuration script
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
# Start configuration of Postfix
#-----------------------------------------------------------------------------#
echo "Configuring postfix..."

mkdir /etc/postfix/ssl
postconf -e "inet_protocols = ipv4, ipv6"
postconf -e "inet_interfaces = all"
postconf -e "mynetworks = 127.0.0.0/8 [::1]/128"
postconf -e "header_checks = regexp:/etc/postfix/header_checks"
postconf -e "myorigin = \$mydomain"
postconf -e "mydestination = \$myhostname, localhost.\$mydomain, localhost"
postconf -e "relay_domains = hash:/etc/postfix/transport"
postconf -e "transport_maps = hash:/etc/postfix/transport"
postconf -e "local_recipient_maps = "
postconf -e "smtpd_helo_required = yes"
postconf -e "smtpd_delay_reject = yes"
postconf -e "disable_vrfy_command = yes"
postconf -e "virtual_alias_maps = hash:/etc/postfix/virtual"
postconf -e "alias_maps = hash:/etc/aliases"
postconf -e "alias_database = hash:/etc/aliases"
postconf -e "default_destination_recipient_limit = 1"
# tls config
postconf -e "smtp_use_tls = yes"
postconf -e "smtpd_use_tls = yes"
postconf -e "smtp_tls_CAfile = /etc/postfix/ssl/smtpd.pem"
postconf -e "smtp_tls_session_cache_database = btree:/var/lib/postfix/smtp_tls_session_cache"
postconf -e "smtp_tls_note_starttls_offer = yes"
postconf -e "smtpd_tls_key_file = /etc/postfix/ssl/smtpd.pem"
postconf -e "smtpd_tls_cert_file = /etc/postfix/ssl/smtpd.pem"
postconf -e "smtpd_tls_CAfile = /etc/postfix/ssl/smtpd.pem"
postconf -e "smtpd_tls_loglevel = 1"
postconf -e "smtpd_tls_received_header = yes"
postconf -e "smtpd_tls_session_cache_timeout = 3600s"
postconf -e "tls_random_source = dev:/dev/urandom"
postconf -e "smtpd_tls_session_cache_database = btree:/var/lib/postfix/smtpd_tls_session_cache"
postconf -e "smtpd_tls_security_level = may"
postconf -e "smtpd_tls_mandatory_protocols = !SSLv2,!SSLv3"
postconf -e "smtp_tls_mandatory_protocols = !SSLv2,!SSLv3"
postconf -e "smtpd_tls_protocols = !SSLv2,!SSLv3"
postconf -e "smtp_tls_protocols = !SSLv2,!SSLv3"
postconf -e "tls_preempt_cipherlist = yes"
postconf -e "tls_medium_cipherlist = ECDSA+AESGCM:ECDH+AESGCM:DH+AESGCM:ECDSA+AES:ECDH+AES:DH+AES:ECDH+3DES:DH+3DES:RSA+AESGCM:RSA+AES:RSA+3DES:!aNULL:!MD5:!DSS"
postconf -e "smtpd_tls_ciphers = medium"
# restrictions
postconf -e "smtpd_helo_restrictions =  check_helo_access hash:/etc/postfix/helo_access, reject_invalid_hostname"
postconf -e "smtpd_sender_restrictions = permit_sasl_authenticated, check_sender_access hash:/etc/postfix/sender_access, reject_non_fqdn_sender, reject_unknown_sender_domain"
postconf -e "smtpd_data_restrictions =  reject_unauth_pipelining"
postconf -e "smtpd_client_restrictions = permit_sasl_authenticated, permit_mynetworks, reject_rbl_client zen.spamhaus.org"
postconf -e "smtpd_relay_restrictions = permit_sasl_authenticated, permit_mynetworks, reject_unauth_destination"
postconf -e "smtpd_recipient_restrictions = permit_sasl_authenticated, permit_mynetworks, reject_unauth_destination, reject_non_fqdn_recipient, reject_unknown_recipient_domain, check_recipient_access hash:/etc/postfix/recipient_access, check_policy_service inet:127.0.0.1:2501, reject_unverified_recipient"
postconf -e "unverified_recipient_reject_reason = No user at this address"
postconf -e "unverified_recipient_reject_code = 550"
#postconf -e "masquerade_domains = \$mydomain"
postconf -e "smtpd_milters = inet:localhost:8891, inet:localhost:8893, inet:127.0.0.1:33333"
postconf -e "non_smtpd_milters = inet:localhost:8891, inet:localhost:8893"
# 128 MB limit
postconf -e "message_size_limit = 133169152"
postconf -e "mailbox_size_limit = 133169152"
postconf -e "qmqpd_authorized_clients = 127.0.0.1 [::1]"
postconf -e "enable_long_queue_ids = yes"
# error_notice_recipient
postconf -e "error_notice_recipient = root"
# canonical maps
postconf -e "sender_canonical_maps = hash:/etc/postfix/sender_canonical"
postconf -e "recipient_canonical_maps = hash:/etc/postfix/recipient_canonical"

#other configuration files
newaliases
touch /etc/postfix/transport
touch /etc/postfix/virtual
touch /etc/postfix/helo_access
touch /etc/postfix/sender_access
touch /etc/postfix/recipient_access
touch /etc/postfix/sasl_passwd
touch /etc/postfix/sender_canonical
touch /etc/postfix/recipient_canonical
postmap /etc/postfix/transport
postmap /etc/postfix/virtual
postmap /etc/postfix/helo_access
postmap /etc/postfix/sender_access
postmap /etc/postfix/recipient_access
postmap /etc/postfix/sasl_passwd
postmap /etc/postfix/sender_canonical
postmap /etc/postfix/recipient_canonical

chmod 0600 /etc/postfix/sasl_passwd

echo "pwcheck_method: auxprop">/usr/lib64/sasl2/smtpd.conf
echo "auxprop_plugin: sasldb">>/usr/lib64/sasl2/smtpd.conf
echo "mech_list: PLAIN LOGIN CRAM-MD5 DIGEST-MD5">>/usr/lib64/sasl2/smtpd.conf

# Dovecot
mkdir -p /var/spool/postfix/private
sed -i "/^  unix_listener auth-userdb {/ c\  unix_listener /var/spool/postfix/private/auth {\n    mode = 0660\n    user = postfix\n    group = postfix" /etc/dovecot/conf.d/10-master.conf
sed -i "/^auth_mechanisms = plain/ c\auth_mechanisms = plain login" /etc/dovecot/conf.d/10-auth.conf

# Submission config
sed -i '/^#submission inet n/ c\submission inet n       -       n       -       -       smtpd\n  -o smtpd_tls_security_level=encrypt\n  -o smtpd_sasl_auth_enable=yes\n  -o smtpd_sasl_type=dovecot\n  -o smtpd_sasl_path=private/auth\n  -o smtpd_sasl_security_options=noanonymous\n  -o smtpd_sasl_local_domain=$myhostname\n  -o smtpd_client_restrictions=permit_sasl_authenticated,reject\n  -o smtpd_sender_login_maps=hash:/etc/postfix/virtual\n  -o smtpd_recipient_restrictions=reject_non_fqdn_recipient,reject_unknown_recipient_domain,permit_sasl_authenticated,reject' /etc/postfix/master.cf

# Enable QMQP delivery
sed -i "/^#628 / c\qmqp      unix  n       -       n       -       -       qmqpd" /etc/postfix/master.cf

echo "Configuring postfix...done"