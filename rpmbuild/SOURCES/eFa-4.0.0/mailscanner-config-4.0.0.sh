#!/bin/sh
#-----------------------------------------------------------------------------#
# eFa 4.0.0 initial mailscanner-configuration script
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
# Start configuration of MailScanner
#-----------------------------------------------------------------------------#
echo "Configuring MailScanner..."

chown postfix:mtagroup /var/spool/MailScanner/quarantine
chown postfix:mtagroup /var/spool/MailScanner/milterin
chown postfix:mtagroup /var/spool/MailScanner/milterout
mkdir /var/spool/MailScanner/spamassassin
chown postfix:mtagroup /var/spool/MailScanner/spamassassin
mkdir /var/spool/mqueue
chown postfix:mtagroup /var/spool/mqueue
touch /var/lock/subsys/MailScanner.off
touch /etc/MailScanner/rules/spam.blacklist.rules

# Configure MailScanner
sed -i '/^Max Children =/ c\Max Children = 2' /etc/MailScanner/MailScanner.conf
sed -i '/^Run As User =/ c\Run As User = postfix' /etc/MailScanner/MailScanner.conf
sed -i '/^Run As Group =/ c\Run As Group = postfix' /etc/MailScanner/MailScanner.conf
sed -i '/^Incoming Queue Dir =/ c\Incoming Queue Dir = \/var\/spool\/MailScanner\/milterin' /etc/MailScanner/MailScanner.conf
sed -i '/^Outgoing Queue Dir =/ c\Outgoing Queue Dir = \/var\/spool\/MailScanner\/milterout' /etc/MailScanner/MailScanner.conf
sed -i '/^MTA =/ c\MTA = msmail' /etc/MailScanner/MailScanner.conf
sed -i '/^Incoming Work Group =/ c\Incoming Work Group = mtagroup' /etc/MailScanner/MailScanner.conf
sed -i '/^Incoming Work Permissions =/ c\Incoming Work Permissions = 0660' /etc/MailScanner/MailScanner.conf
sed -i '/^Quarantine User =/ c\Quarantine User = postfix' /etc/MailScanner/MailScanner.conf
sed -i '/^Quarantine Group =/ c\Quarantine Group = mtagroup' /etc/MailScanner/MailScanner.conf
sed -i '/^Quarantine Permissions =/ c\Quarantine Permissions = 0660' /etc/MailScanner/MailScanner.conf
sed -i '/^Deliver Unparsable TNEF =/ c\Deliver Unparsable TNEF = yes' /etc/MailScanner/MailScanner.conf
sed -i '/^Maximum Archive Depth =/ c\Maximum Archive Depth = 0' /etc/MailScanner/MailScanner.conf
sed -i '/^Virus Scanners =/ c\Virus Scanners = clamd' /etc/MailScanner/MailScanner.conf
sed -i '/^Non-Forging Viruses =/ c\Non-Forging Viruses = Joke\/ OF97\/ WM97\/ W97M\/ eicar Zip-Password' /etc/MailScanner/MailScanner.conf
sed -i '/^Web Bug Replacement =/ c\Web Bug Replacement = http:\/\/dl.efa-project.org\/static\/1x1spacer.gif' /etc/MailScanner/MailScanner.conf
sed -i '/^Quarantine Whole Message =/ c\Quarantine Whole Message = yes' /etc/MailScanner/MailScanner.conf
# Set to yes to allow blocked file release
sed -i '/^Quarantine Infections =/ c\Quarantine Infections = yes' /etc/MailScanner/MailScanner.conf
sed -i '/^Keep Spam And MCP Archive Clean =/ c\Keep Spam And MCP Archive Clean = yes' /etc/MailScanner/MailScanner.conf
sed -i 's/X-%org-name%-MailScanner/X-%org-name%-MailScanner-eFa/g' /etc/MailScanner/MailScanner.conf
sed -i '/^Remove These Headers =/ c\Remove These Headers = X-Mozilla-Status: X-Mozilla-Status2: Disposition-Notification-To: Return-Receipt-To:' /etc/MailScanner/MailScanner.conf
sed -i '/^Disarmed Modify Subject =/ c\Disarmed Modify Subject = no' /etc/MailScanner/MailScanner.conf
sed -i '/^Send Notices =/ c\Send Notices = no' /etc/MailScanner/MailScanner.conf
sed -i '/^Notice Signature =/ c\Notice Signature = -- \\nEFA\\nEmail Filter Appliance\\nwww.efa-project.org' /etc/MailScanner/MailScanner.conf
sed -i '/^Notices From =/ c\Notices From = eFa' /etc/MailScanner/MailScanner.conf
sed -i '/^Inline HTML Signature =/ c\Inline HTML Signature = %rules-dir%\/sig.html.rules' /etc/MailScanner/MailScanner.conf
sed -i '/^Inline Text Signature =/ c\Inline Text Signature = %rules-dir%\/sig.text.rules' /etc/MailScanner/MailScanner.conf
sed -i '/^Is Definitely Not Spam =/ c\Is Definitely Not Spam = &SQLWhitelist' /etc/MailScanner/MailScanner.conf
sed -i '/^Is Definitely Spam =/ c\Is Definitely Spam = &SQLBlacklist' /etc/MailScanner/MailScanner.conf
sed -i '/^Definite Spam Is High Scoring =/ c\Definite Spam Is High Scoring = yes' /etc/MailScanner/MailScanner.conf
sed -i '/^Treat Invalid Watermarks With No Sender as Spam =/ c\Treat Invalid Watermarks With No Sender as Spam = 2' /etc/MailScanner/MailScanner.conf
sed -i '/^Max SpamAssassin Size =/ c\Max SpamAssassin Size = 100k continue 150k' /etc/MailScanner/MailScanner.conf
sed -i '/^Required SpamAssassin Score =/ c\Required SpamAssassin Score = 4' /etc/MailScanner/MailScanner.conf
sed -i '/^Spam Actions =/ c\Spam Actions = store' /etc/MailScanner/MailScanner.conf
sed -i '/^High Scoring Spam Actions =/ c\High Scoring Spam Actions = store' /etc/MailScanner/MailScanner.conf
sed -i '/^Non Spam Actions =/ c\Non Spam Actions = store deliver header "X-Spam-Status:No" custom(nonspam)' /etc/MailScanner/MailScanner.conf
sed -i '/^Log Spam =/ c\Log Spam = yes' /etc/MailScanner/MailScanner.conf
sed -i '/^Log Silent Viruses =/ c\Log Silent Viruses = yes' /etc/MailScanner/MailScanner.conf
sed -i '/^Log Dangerous HTML Tags =/ c\Log Dangerous HTML Tags = yes' /etc/MailScanner/MailScanner.conf
sed -i '/^SpamAssassin Local State Dir =/ c\SpamAssassin Local State Dir = /var/lib/spamassassin' /etc/MailScanner/MailScanner.conf
sed -i '/^SpamAssassin User State Dir =/ c\SpamAssassin User State Dir = /var/spool/MailScanner/spamassassin' /etc/MailScanner/MailScanner.conf
sed -i '/^Detailed Spam Report =/ c\Detailed Spam Report = yes' /etc/MailScanner/MailScanner.conf
sed -i '/^Include Scores In SpamAssassin Report =/ c\Include Scores In SpamAssassin Report = yes' /etc/MailScanner/MailScanner.conf
sed -i '/^Always Looked Up Last =/ c\Always Looked Up Last = &MailWatchLogging' /etc/MailScanner/MailScanner.conf
sed -i '/^Clamd Socket =/ c\Clamd Socket = /var/run/clamd.scan/clamd.sock' /etc/MailScanner/MailScanner.conf
sed -i '/^Log SpamAssassin Rule Actions =/ c\Log SpamAssassin Rule Actions = no' /etc/MailScanner/MailScanner.conf
sed -i "/^Sign Clean Messages =/ c\# eFa Note: CustomAction.pm will Sign Clean Messages instead using the custom(nonspam) action.\nSign Clean Messages = No" /etc/MailScanner/MailScanner.conf
sed -i "/^Deliver Cleaned Messages =/ c\Deliver Cleaned Messages = No" /etc/MailScanner/MailScanner.conf
sed -i "/^Maximum Processing Attempts =/ c\Maximum Processing Attempts = 2" /etc/MailScanner/MailScanner.conf
sed -i "/^High SpamAssassin Score =/ c\High SpamAssassin Score = 7" /etc/MailScanner/MailScanner.conf
sed -i "/^Place New Headers At Top Of Message =/ c\Place New Headers At Top Of Message = yes" /etc/MailScanner/MailScanner.conf
sed -i "/^Maximum Archive Depth =/ c\Maximum Archive Depth = 3" /etc/MailScanner/MailScanner.conf
sed -i "/^Max Spam Check Size =/ c\Max Spam Check Size = 2048k" /etc/MailScanner/MailScanner.conf
sed -i "/^Dont Sign HTML If Headers Exist =/ c\Dont Sign HTML If Headers Exist = In-Reply-To: References:" /etc/MailScanner/MailScanner.conf
sed -i "/^Notify Senders =/ c\Notify Senders = no" /etc/MailScanner/MailScanner.conf
sed -i '/^envelope_sender_header / c\envelope_sender_header X-yoursite-MailScanner-eFa-From' /etc/MailScanner/spamassassin.conf

touch /etc/MailScanner/rules/sig.html.rules
touch /etc/MailScanner/rules/sig.text.rules
touch /etc/MailScanner/phishing.safe.sites.conf
rm -rf /var/spool/MailScanner/incoming
mkdir /var/spool/MailScanner/incoming
echo "none /var/spool/MailScanner/incoming tmpfs noatime 0 0">>/etc/fstab
mount -a

# Replace reports with eFa versions
rm -rf /usr/share/MailScanner/reports
cp -ra $srcdir/mailscanner/reports /usr/share/MailScanner/reports

# Add CustomAction.pm for token handling
# Remove as a copy will throw a mailscanner --lint error
rm -f /usr/share/MailScanner/perl/custom/CustomAction.pm
cp $srcdir/mailscanner/CustomAction.pm /usr/share/MailScanner/perl/custom/CustomAction.pm

# Add eFa-Tokens-Cron
cp $srcdir/mailscanner/eFa-Tokens-Cron /etc/cron.daily/eFa-Tokens-Cron
chmod 700 /etc/cron.daily/eFa-Tokens-Cron

sed -i "/^run_mailscanner/ c\run_mailscanner=1" /etc/MailScanner/defaults
sed -i "/^ramdisk_sync/ c\ramdisk_sync=1" /etc/MailScanner/defaults

sed -i "/^Filename Rules =/ c\Filename Rules = %etc-dir%/filename.rules" /etc/MailScanner/MailScanner.conf
sed -i "/^Filetype Rules =/ c\Filetype Rules = %etc-dir%/filetype.rules" /etc/MailScanner/MailScanner.conf
sed -i "/^Dangerous Content Scanning =/ c\Dangerous Content Scanning = %rules-dir%/content.scanning.rules" /etc/MailScanner/MailScanner.conf

echo -e "From:\t127.0.0.1\t/etc/MailScanner/filename.rules.allowall.conf" > /etc/MailScanner/filename.rules
echo -e "FromOrTo:\tdefault\t/etc/MailScanner/filename.rules.conf" >> /etc/MailScanner/filename.rules

echo -e "From:\t127.0.0.1\t/etc/MailScanner/filetype.rules.allowall.conf" > /etc/MailScanner/filetype.rules
echo -e "FromOrTo:\tdefault\t/etc/MailScanner/filetype.rules.conf" >> /etc/MailScanner/filetype.rules

echo -e "From:\t127.0.0.1\tno" > /etc/MailScanner/rules/content.scanning.rules
echo -e "FromOrTo:\tdefault\tyes" >> /etc/MailScanner/rules/content.scanning.rules

echo -e "allow\t.*\t-\t-" > /etc/MailScanner/filename.rules.allowall.conf
echo -e "allow\t.*\t-\t-" >> /etc/MailScanner/filetype.rules.allowall.conf

echo -e "From:\t127.0.0.1\tno" > /etc/MailScanner/numeric.phishing.rules
echo -e "FromOrTo:\tDefault\tyes" >> /etc/MailScanner/numeric.phishing.rules
sed -i '/^Also Find Numeric Phishing =/ c\Also Find Numeric Phishing = %etc-dir%/numeric.phishing.rules' /etc/MailScanner/MailScanner.conf

sed -i '/^\/usr\/sbin\/ms-cron DAILY/ c\/usr/sbin/ms-cron DAILY >/dev/null 2>&1' /etc/cron.daily/mailscanner
sed -i '/^\/usr\/sbin\/ms-cron MAINT/ c\/usr/sbin/ms-cron MAINT >/dev/null 2>&1' /etc/cron.daily/mailscanner

sed -i '/^BADSRC=/ c\BADSRC="https://dl.efa-project.org/MailScanner/phishing.bad.sites.conf"' /usr/sbin/ms-update-phishing
sed -i '/^SAFESRC=/ c\SAFESRC="https://dl.efa-project.org/MailScanner/phishing.safe.sites.conf"' /usr/sbin/ms-update-phishing

echo "Configuring MailScanner...done"