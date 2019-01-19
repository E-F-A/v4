#!/bin/sh
#-----------------------------------------------------------------------------#
# eFa 4.0.0 initial postscreen-configuration script
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
# Start configuration of Postfix
#-----------------------------------------------------------------------------#
echo "Configuring postscreen..."

echo "TODO: UNFINISHED TESTING SCRIPT DO NOT USE!"

# /etc/postfix/postscreen_dnsbl_reply_map.pcre

echo "- Commenting out 'smtp .. inet n ... smtpd' service in master.cf."
sed -i '/^smtp .*inet.*smtpd$/s/^/#/' /etc/postfix/master.cf

echo "- Uncommenting 'smtp inet ... postscreen' service in master.cf"
sed -i '/^#smtp *.*inet.*postscreen$/s/^#//g' /etc/postfix/master.cf

echo "- Uncommenting 'smtpd pass ... smtpd' service in master.cf."
sed -i '/^#smtpd.*pass.*smtpd$/s/^#//g' /etc/postfix/master.cf

echo "- Uncommenting 'tlsproxy unix ... tlsproxy' service in master.cf"
sed -i '/^#tlsproxy.*unix.*tlsproxy$/s/^#//g' /etc/postfix/master.cf

echo "- Uncommenting 'dnsblog unix ... dnsblog' service in master.cf"
sed -i '/^#dnsblog.*unix.*dnsblog$/s/^#//g' /etc/postfix/master.cf

# Postscreen access cidr file (TODO auto update from eFa servers ?)
touch /etc/postfix/postscreen_access.cidr
postconf -e postscreen_access_list="permit_mynetworks, cidr:/etc/postfix/postscreen_access.cidr"



################################### ######
# Postscreen tests NOTES
########


#------------------------
# Controls
#------------------------
# postscreen_command_filter
# postscreen_discard_ehlo_keyword_address_maps
# postscreen_discard_ehlo_keywords
# dns_ncache_ttl_fix_enable
# postscreen_expansion_filter
# postscreen_reject_foot
# soft_bounce

#------------------------
# Before postscreen
#------------------------
# postscreen_upstream_proxy_protocol
# postscreen_upstream_proxy_timeout

#------------------------
# Permanent tests
#------------------------
postscreen_access_list     = permit_mynetworks, cidr:$config_directory/postscreen_access.cidr
postscreen_blacklist_action   = drop

#------------------------
# Before 220 greeting
#------------------------
# dnsblog_service_name
postscreen_dnsbl_action      = enforce                                          # Or drop?
postscreen_dnsbl_reply_map   = pcre:$config_directory/postscreen_dnsbl_reply_map.pcre  # should we use this with free services (as there are no passwords)?
postscreen_dnsbl_sites       = zen.spamhaus.org*3                               # free for 100k
                             ib.barracudacentral.org*2                          # free to use no warranty
                             bl.spameatingmonkey.net*2                          # free for 100k reqs
                             bl.spamcop.net                                     # free to use no warrany
                             dnsbl.sorbs.net                                    # free for 100k reqs
                             psbl.surriel.com                                   # free to use (rsync to eFa as it is available?)
                             bl.mailspike.net                                   # free for 100k reqs
                             list.dnswl.org=127.[0..255].[0..255].0*-2          # free for 100k reqs
                             list.dnswl.org=127.[0..255].[0..255].1*-3          # free for 100k reqs
                             list.dnswl.org=127.[0..255].[0..255].[2..255]*-4   # free for 100k reqs
                             # swl.spamhaus.org*-4                              # Doesn't exist anymore
postscreen_dnsbl_threshold   = 3
postscreen_greet_action      = enforce
postscreen_greet_banner      = $smtpd_banner
postscreen_greet_wait        = ${stress?2}${stress:6}s
# smtpd_service_name    =
postscreen_dnsbl_whitelist_threshold  = -1
#postscreen_dnsbl_timeout     =

#------------------------
# After 220 greeting
#------------------------
postscreen_bare_newline_action          = enforce                               # causes delay in delivery as first attempt is blocked with a 450 4.3.2 Service currently unavailable
postscreen_bare_newline_enable          = yes                                   # causes delay in delivery as first attempt is blocked with a 450 4.3.2 Service currently unavailable
# postscreen_disable_vrfy_command
# postscreen_forbidden_commands
# postscreen_helo_required
# postscreen_non_smtp_command_action
# postscreen_non_smtp_command_enable
# postscreen_pipelining_action
# postscreen_pipelining_enable

#------------------------
# Cache Controls
#------------------------
# postscreen_cache_cleanup_interval
# postscreen_cache_map
# postscreen_cache_retention_time
# postscreen_bare_newline_ttl
# postscreen_dnsbl_max_ttl
# postscreen_dnsbl_min_ttl
# postscreen_greet_ttl
# postscreen_non_smtp_command_ttl
# postscreen_pipelining_ttl

#------------------------
# Resource Controls
#------------------------
# line_length_limit
# postscreen_client_connection_count_limit
# postscreen_command_count_limit
# postscreen_command_time_limit
# postscreen_post_queue_limit
# postscreen_pre_queue_limit
# postscreen_watchdog_timeout

#------------------------
# STARTTTLS controls
#------------------------
# postscreen_tls_security_level
# tlsproxy_service_name
