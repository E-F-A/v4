#!/bin/sh
#-----------------------------------------------------------------------------#
# eFa 4.0.0 initial service-configuration script
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
# Start configuration of services
#-----------------------------------------------------------------------------#

# Copy eFa-Init into apache
echo "Configuring eFaInit..."

cd /var/www/eFaInit
composer install --quiet

# Grant apache permissions to cache/logs/sessions
chown apache /var/www/eFaInit/var/{cache,logs,sessions}

cat > /etc/httpd/conf.d/eFaInit.conf << 'EOF'
Alias /eFaInit /var/www/eFaInit/web
<Directory /var/www/eFaInit/web>
   AllowOverride None
   Require all granted
   
    <IfModule mod_rewrite.c>
        Options -MultiViews
        RewriteEngine On
        RewriteCond %{REQUEST_FILENAME} !-f
        RewriteRule ^(.*)$ app.php [QSA,L]
    </IfModule>
</Directory>
EOF

# Set up a redirect in web root to eFaInit
cat > /var/www/html/index.html < 'EOF'
<!DOCTYPE html>
<html>
    <head>
    <title>eFaInit</title>
    <meta http-equiv="refresh" content="0; url=/eFaInit/" />
    </head>
    <body>
    </body>
</html>
EOF

echo "Configuring eFaInit...done"
