#
# MailWatch for MailScanner
#

package MailScanner::CustomConfig;

use warnings;
use strict;

# Change the values below to match the MailWatch database settings as set in conf.php
my ($db_name) = 'mailscanner';
my ($db_user) = 'mailwatch';
my ($fh);
my ($db_config) = '/etc/eFa/MailWatch-Config';
open($fh, "<", $db_config);
if(!$fh) {
  MailScanner::Log::WarnLog("Unable to open %s to retrieve db settings", $db_config);
  return;
}
my ($db_pass) = grep(/^MAILWATCHSQLPWD/,<$fh>);
$db_pass =~ s/MAILWATCHSQLPWD://;
$db_pass =~ s/\n//;
seek $fh, 0, 0;
my ($db_host) = grep(/^MAILWATCHSQLHOST/,<$fh>);
$db_host =~ s/MAILWATCHSQLHOST://;
$db_host =~ s/\n//;
close($fh);

# Change the value below for SQLSpamSettings.pm (default = 15)
my ($ss_refresh_time) = 15;       # Time in minutes before lists are refreshed

# Change the value below for SQLBlackWhiteList.pm (default = 15)
my ($bwl_refresh_time) = 15;      # Time in minutes before lists are refreshed


###############################
# don't touch below this line #
###############################

sub mailwatch_get_db_name { return $db_name };
sub mailwatch_get_db_host { return $db_host };
sub mailwatch_get_db_user { return $db_user };
sub mailwatch_get_db_password { return $db_pass };
sub mailwatch_get_BWL_refresh_time { return $bwl_refresh_time };
sub mailwatch_get_SS_refresh_time { return $ss_refresh_time };

1;
