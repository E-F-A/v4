#!/bin/bash
#-----------------------------------------------------------------------------#
# EFA-func_greylisting
# Version 20150530
# Function to enable/disable greylisting
# Options:
#         --enable
#         --disable
#         --status
#-----------------------------------------------------------------------------#
# Copyright (C) 2012~2015  http://www.efa-project.org
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
action=$1
OUTPUT="ERROR"
#-----------------------------------------------------------------------------#
# Disable Greylisting
#-----------------------------------------------------------------------------#
func_disableGreyListing(){
  if [[ $GreyStatus = "DISABLED" ]]; then
    # Already disabled nothing to do
    OUTPUT="OK"
  else
    postconf -e "smtpd_recipient_restrictions = permit_sasl_authenticated, permit_mynetworks, reject_unauth_destination, reject_non_fqdn_recipient, reject_unknown_recipient_domain, check_recipient_access hash:/etc/postfix/recipient_access"
    postfix reload
    service sqlgrey stop
    chkconfig sqlgrey off

    # Check status
    func_getGreyStatus
    if [[ $GreyStatus = "DISABLED" ]]; then
      # Disabled all OK
      OUTPUT="OK"
    else
      # Not disabled? send error
      OUTPUT="ERROR"
    fi
  fi
}
#-----------------------------------------------------------------------------#

#-----------------------------------------------------------------------------#
# Enable Greylisting
#-----------------------------------------------------------------------------#
func_enableGreyListing(){
  func_getGreyStatus
  if [[ $GreyStatus = "ENABLED" ]]; then
    # Already enabled nothing to do
    OUTPUT="OK"
  else
    postconf -e "smtpd_recipient_restrictions = permit_sasl_authenticated, permit_mynetworks, reject_unauth_destination, reject_non_fqdn_recipient, reject_unknown_recipient_domain, check_recipient_access hash:/etc/postfix/recipient_access, check_policy_service inet:127.0.0.1:2501"
    postfix reload
    service sqlgrey start
    chkconfig sqlgrey on

    # Check status
    func_getGreyStatus
    if [[ $GreyStatus = "ENABLED" ]]; then
      # Enabled all OK
      OUTPUT="OK"
    else
      # Not enabled? send error
      OUTPUT="ERROR"
    fi
  fi
}
#-----------------------------------------------------------------------------#

#-----------------------------------------------------------------------------#
# Greylisting status
#-----------------------------------------------------------------------------#
func_getGreyStatus(){
  if [[ -n $(cat /etc/postfix/main.cf | grep "check_policy_service inet:127.0.0.1:2501") ]]; then
    GreyStatus="ENABLED"
  else
    GreyStatus="DISABLED"
  fi
}
#-----------------------------------------------------------------------------#

#-----------------------------------------------------------------------------#
# Show program usage message
#-----------------------------------------------------------------------------#
function show_usage(){
  echo "Usage: $0 "
  echo ""
  echo "--enable"
  echo "   Enable Greylisting"
  echo ""
  echo "--disable"
  echo "   disable Greylisting"
  echo ""
  echo "--status"
  echo "   Current Greylisting status"
  exit 0
}
#-----------------------------------------------------------------------------#

#-----------------------------------------------------------------------------#
# Main function
#-----------------------------------------------------------------------------#
# Check if arguments ain't empty
if [[ -z $action ]]; then
  show_usage
else
  case $action in
    --enable  ) func_enableGreyListing && echo "$OUTPUT";;
    --disable ) func_disableGreyListing && echo "$OUTPUT";;
    --status  ) func_getGreyStatus && echo $GreyStatus;;
    *) show_usage;;
  esac
fi
#-----------------------------------------------------------------------------#
