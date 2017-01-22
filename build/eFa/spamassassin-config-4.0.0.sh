#!/bin/sh
#-----------------------------------------------------------------------------#
# eFa 4.0.0 initial spamassasin-configuration script
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
# Start configuration of spamassassin
#-----------------------------------------------------------------------------#
# Symlink spamassassin.conf (previously handled by tarball)
ln -s -f /etc/MailScanner/spamassassin.conf /etc/mail/spamassassin/mailscanner.cf

# Configure *.pre files (previously handled by tarball)
sed -i "/^# loadplugin Mail::Spamassassin::Plugin::RelayCountry$/ c\loadplugin Mail::Spamassassin::Plugin::RelayCountry" /etc/mail/spamassassin/init.pre

# Symlink for Geo::IP
rm -f /usr/share/GeoIP/GeoLiteCountry.dat
ln -s /var/www/html/mailscanner/temp/GeoIP.dat /usr/share/GeoIP/GeoLiteCountry.dat

# PDFInfo (now included in SA 3.4.1)
cp $srcdir/spamassassin/pdfinfo.cf
sed -i "/^# loadplugin Mail::SpamAssassin::Plugin::PDFInfo$/ c\loadplugin Mail::SpamAssassin::Plugin::PDFInfo" /etc/mail/spamassassin/v341.pre

# Download an initial KAM.cf file updates are handled by EFA-SA-Update.
cp $srcdir/spamassassin/KAM.cf /etc/mail/spamassassin/KAM.cf

# Configure spamassassin bayes and awl DB settings
cat >> /etc/MailScanner/spamassassin.conf << 'EOF'
#Begin E.F.A. mods for MySQL
bayes_store_module              Mail::SpamAssassin::BayesStore::SQL
bayes_sql_dsn                   DBI:mysql:sa_bayes:localhost
bayes_sql_username              sa_user"
bayes_sql_password              $password
auto_whitelist_factory          Mail::SpamAssassin::SQLBasedAddrList
user_awl_dsn                    DBI:mysql:sa_bayes:localhost
user_awl_sql_username           sa_user
user_awl_sql_password           $password
bayes_sql_override_username     mailwatch
txrep_factory                   Mail::SpamAssassin::SQLBasedAddrList
txrep_track_messages            0
user_awl_sql_override_username  TxRep
user_awl_sql_table              txrep
use_txrep                       0
#End E.F.A. mods for MySQL
EOF

# Enable Auto White Listing
sed -i '/^#loadplugin Mail::SpamAssassin::Plugin::AWL/ c\loadplugin Mail::SpamAssassin::Plugin::AWL' /etc/mail/spamassassin/v310.pre

# Enable TxRep Plugin
sed -i "/^# loadplugin Mail::SpamAssassin::Plugin::TxRep/ c\loadplugin Mail::SpamAssassin::Plugin::TxRep" /etc/mail/spamassassin/v341.pre

# Add example spam to db
# source: http://spamassassin.apache.org/gtube/gtube.txt
/usr/bin/sa-learn --spam /usr/src/eFa/spamassassin/gtube.txt

# AWL cleanup tools (just a bit different then esva)
# http://notes.sagredo.eu/node/86
echo '#!/bin/sh'>/usr/sbin/trim-awl
echo "/usr/bin/mysql -usa_user -p$password < /etc/trim-awl.sql">>/usr/sbin/trim-awl
echo 'exit 0 '>>/usr/sbin/trim-awl
chmod +x /usr/sbin/trim-awl

echo "USE sa_bayes;">/etc/trim-awl.sql
echo "DELETE FROM awl WHERE ts < (NOW() - INTERVAL 28 DAY);">>/etc/trim-awl.sql

cd /etc/cron.weekly
echo '#!/bin/sh'>trim-sql-awl-weekly
echo '#'>>trim-sql-awl-weekly
echo '#  Weekly maintenance of auto-whitelist for'>>trim-sql-awl-weekly
echo '#  SpamAssassin using MySQL'>>trim-sql-awl-weekly
echo '/usr/sbin/trim-awl'>>trim-sql-awl-weekly
echo 'exit 0'>>trim-sql-awl-weekly
chmod +x trim-sql-awl-weekly

# Create .spamassassin directory (error reported in lint test)
mkdir /var/www/.spamassassin
chown postfix:mtagroup /var/www/.spamassassin

# Issue #82 re2c spamassassin rule complilation
sed -i "/^# loadplugin Mail::SpamAssassin::Plugin::Rule2XSBody/ c\loadplugin Mail::SpamAssassin::Plugin::Rule2XSBody" /etc/mail/spamassassin/v320.pre

# Issue #326 MCP not functional
ln -s /etc/mail/spamassassin/init.pre /etc/MailScanner/mcp/init.pre
ln -s /etc/mail/spamassassin/v310.pre /etc/MailScanner/mcp/v310.pre
ln -s /etc/mail/spamassassin/v312.pre /etc/MailScanner/mcp/v312.pre
ln -s /etc/mail/spamassassin/v320.pre /etc/MailScanner/mcp/v320.pre
ln -s /etc/mail/spamassassin/v330.pre /etc/MailScanner/mcp/v330.pre
ln -s /etc/mail/spamassassin/v340.pre /etc/MailScanner/mcp/v340.pre
ln -s /etc/mail/spamassassin/v341.pre /etc/MailScanner/mcp/v341.pre
mkdir -p /var/spool/postfix/.spamassassin
chown postfix:mtagroup /var/spool/postfix/.spamassassin

# and in the end we run sa-update just for the fun of it..
/usr/bin/sa-update --channel updates.spamassassin.org
/usr/bin/sa-compile

