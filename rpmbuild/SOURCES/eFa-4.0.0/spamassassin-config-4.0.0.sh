#!/bin/sh
#-----------------------------------------------------------------------------#
# eFa 4.0.0 initial spamassasin-configuration script
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
# Start configuration of spamassassin
#-----------------------------------------------------------------------------#
echo "Configuring spamassassin..."

# Symlink spamassassin.conf (previously handled by tarball)
ln -s -f /etc/MailScanner/spamassassin.conf /etc/mail/spamassassin/mailscanner.cf

# Configure *.pre files (previously handled by tarball)
sed -i "/^# loadplugin Mail::Spamassassin::Plugin::RelayCountry$/ c\loadplugin Mail::Spamassassin::Plugin::RelayCountry" /etc/mail/spamassassin/init.pre

# Symlink for Geo::IP
rm -f /usr/share/GeoIP/GeoLiteCountry.dat
ln -s /var/www/html/mailscanner/temp/GeoIP.dat /usr/share/GeoIP/GeoLiteCountry.dat

# PDFInfo (now included in SA 3.4.1)
cp $srcdir/spamassassin/pdfinfo.cf /etc/mail/spamassassin/pdfinfo.cf
sed -i "/^# loadplugin Mail::SpamAssassin::Plugin::PDFInfo$/ c\loadplugin Mail::SpamAssassin::Plugin::PDFInfo" /etc/mail/spamassassin/v341.pre

# Download an initial KAM.cf file updates are handled by EFA-SA-Update.
cp $srcdir/spamassassin/KAM.cf /etc/mail/spamassassin/KAM.cf

# Configure spamassassin bayes and awl DB settings
echo '' >> /etc/MailScanner/spamassassin.conf
echo '#Begin eFa mods for MySQL' >> /etc/MailScanner/spamassassin.conf
echo '' >> /etc/MailScanner/spamassassin.conf
echo 'bayes_store_module              Mail::SpamAssassin::BayesStore::SQL' >> /etc/MailScanner/spamassassin.conf
echo 'bayes_sql_dsn                   DBI:mysql:sa_bayes:localhost' >> /etc/MailScanner/spamassassin.conf
echo 'bayes_sql_username              sa_user' >> /etc/MailScanner/spamassassin.conf
echo "bayes_sql_password              $password" >> /etc/MailScanner/spamassassin.conf
echo 'bayes_sql_override_username     postfix' >> /etc/MailScanner/spamassassin.conf

# Use TxRep instead
#echo '' >> /etc/MailScanner/spamassassin.conf
#echo 'ifplugin Mail::SpamAssassin::Plugin::AWL' >> /etc/MailScanner/spamassassin.conf
#echo '    auto_whitelist_factory          Mail::SpamAssassin::SQLBasedAddrList' >> /etc/MailScanner/spamassassin.conf
#echo '    user_awl_dsn                    DBI:mysql:sa_bayes:localhost' >> /etc/MailScanner/spamassassin.conf
#echo '    user_awl_sql_username           sa_user' >> /etc/MailScanner/spamassassin.conf
#echo "    user_awl_sql_password           $password" >> /etc/MailScanner/spamassassin.conf
#echo 'endif' >> /etc/MailScanner/spamassassin.conf

echo '' >> /etc/MailScanner/spamassassin.conf
echo 'ifplugin Mail::SpamAssassin::Plugin::TxRep' >> /etc/MailScanner/spamassassin.conf
echo '    txrep_factory                   Mail::SpamAssassin::SQLBasedAddrList' >> /etc/MailScanner/spamassassin.conf
#echo '    txrep_track_messages            0' >> /etc/MailScanner/spamassassin.conf
echo '    user_awl_sql_override_username  postfix' >> /etc/MailScanner/spamassassin.conf
echo '    user_awl_dsn                    DBI:mysql:sa_bayes:localhost' >> /etc/MailScanner/spamassassin.conf
echo '    user_awl_sql_username           sa_user' >> /etc/MailScanner/spamassassin.conf
echo "    user_awl_sql_password           $password" >> /etc/MailScanner/spamassassin.conf
echo '    user_awl_sql_table              txrep' >> /etc/MailScanner/spamassassin.conf
echo '    use_txrep                       1' >> /etc/MailScanner/spamassassin.conf
echo 'endif' >> /etc/MailScanner/spamassassin.conf
echo '' >> /etc/MailScanner/spamassassin.conf
echo '#End eFa mods for MySQL' >> /etc/MailScanner/spamassassin.conf

# Enable Auto White Listing
#sed -i '/^#loadplugin Mail::SpamAssassin::Plugin::AWL/ c\loadplugin Mail::SpamAssassin::Plugin::AWL' /etc/mail/spamassassin/v310.pre

# Enable TxRep Plugin
sed -i "/^# loadplugin Mail::SpamAssassin::Plugin::TxRep/ c\loadplugin Mail::SpamAssassin::Plugin::TxRep" /etc/mail/spamassassin/v341.pre

# Enable HashBL Plugin
sed -i "/^# loadplugin Mail::SpamAssassin::Plugin::HashBL/ c\loadplugin Mail::SpamAssassin::Plugin::HashBL" /etc/mail/spamassassin/v342.pre

# Enable FromNameSpoof plugin
sed -i "/^# loadplugin Mail::SpamAssassin::Plugin::FromNameSpoof/ c\loadplugin Mail::SpamAssassin::Plugin::FromNameSpoof" /etc/mail/spamassassin/v342.pre

# Enable Phishing plugin
sed -i "/^# loadplugin Mail::SpamAssassin::Plugin::Phishing/ c\loadplugin Mail::SpamAssassin::Plugin::Phishing" /etc/mail/spamassassin/v342.pre

# Enable URILocalBL plugin
sed -i "/^# loadplugin Mail::SpamAssassin::Plugin::URILocalBL/ c\loadplugin Mail::SpamAssassin::Plugin::URILocalBL" /etc/mail/spamassassin/v341.pre

# Enable Shortcircuit plugin
sed -i "/^# loadplugin Mail::SpamAssassin::Plugin::Shortcircuit/ c\loadplugin Mail::SpamAssassin::Plugin::Shortcircuit" /etc/mail/spamassassin/v320.pre

# Enable ASM plugin
sed -i "/^# loadplugin Mail::SpamAssassin::Plugin::ASM/ c\loadplugin Mail::SpamAssassin::Plugin::ASM" /etc/mail/spamassassin/v320.pre

# Enable Av plugin
sed -i "/^# loadplugin Mail::SpamAssassin::Plugin::AntiVirus/ c\loadplugin Mail::SpamAssassin::Plugin::AntiVirus" /etc/mail/spamassassin/v310.pre

# TxRep cleanup tools
echo '#!/bin/sh'>/etc/cron.d/trim-txrep
echo "password=$(grep ^SAUSERSQLPWD /etc/eFa/SA-Config | awk -F':' '{print $2}')" >> /etc/cron.d/trim-txrep
echo "/usr/bin/mysql -usa_user -p$password -Dsa_bayes -e'DELETE FROM txrep WHERE last_hit <= (now() - INTERVAL 120 day);'" >> /etc/cron.d/trim-txrep
echo 'exit 0 '>>/etc/cron.d/trim-txrep
chmod +x /etc/cron.d/trim-txrep

# Create .spamassassin directory (error reported in lint test)
mkdir -p /var/www/.spamassassin
chown postfix:mtagroup /var/www/.spamassassin
mkdir -p /usr/share/httpd/.spamassassin
chown postfix:mtagroup /usr/share/httpd/.spamassassin

cat > /etc/cron.daily/eFa-SAClean << 'EOF'
#!/bin/sh
# MailScanner_incoming SA Cleanup
/usr/sbin/tmpwatch -u 48 /var/spool/MailScanner/incoming/SpamAssassin-Temp 
EOF
chmod ugo+x /etc/cron.daily/eFa-SAClean

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
ln -s /etc/mail/spamassassin/v342.pre /etc/MailScanner/mcp/v342.pre
mkdir -p /var/spool/postfix/.spamassassin
chown postfix:mtagroup /var/spool/postfix/.spamassassin

# not needed during this phase
# and in the end we run sa-update just for the fun of it..
# /usr/bin/sa-update --channel updates.spamassassin.org
# /usr/bin/sa-compile

echo "Configuring spamassassin...done"