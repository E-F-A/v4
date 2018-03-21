#!/bin/sh
#-----------------------------------------------------------------------------#
# eFa 4.0.0 initial mariadb-configuration script
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
# Start configuration of MariaDB
#-----------------------------------------------------------------------------#
echo "Configuring mariadb..."
systemctl start mariadb

# remove default security flaws from MySQL.
/usr/bin/mysqladmin -u root password "$password"
/usr/bin/mysqladmin -u root -p"$password" -h localhost.localdomain password "$password"
echo y | /usr/bin/mysqladmin -u root -p"$password" drop 'test'
/usr/bin/mysql -u root -p"$password" -e "DELETE FROM mysql.user WHERE User='';"
/usr/bin/mysql -u root -p"$password" -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"

# Create the databases
/usr/bin/mysql -u root -p"$password" -e "CREATE DATABASE sa_bayes"
/usr/bin/mysql -u root -p"$password" -e "CREATE DATABASE sqlgrey"

# Create and populate the mailscanner db
/usr/bin/mysql -u root -p"$password" < $srcdir/mariadb/create.sql

# Create and populate efa db
/usr/bin/mysql -u root -p"$password" < $srcdir/mariadb/efatokens.sql

# Create the users
/usr/bin/mysql -u root -p"$password" -e "GRANT SELECT,INSERT,UPDATE,DELETE on sa_bayes.* to 'sa_user'@'localhost' identified by '$password'"

# mailwatch mysql user and login user
/usr/bin/mysql -u root -p"$password" -e "GRANT ALL ON mailscanner.* TO mailwatch@localhost IDENTIFIED BY '$password';"
/usr/bin/mysql -u root -p"$password" -e "GRANT FILE ON *.* to mailwatch@localhost IDENTIFIED BY '$password';"

# sqlgrey user
/usr/bin/mysql -u root -p"$password" -e "GRANT ALL on sqlgrey.* to 'sqlgrey'@'localhost' identified by '$password'"

# efa user for token handling
/usr/bin/mysql -u root -p"$password" -e "GRANT ALL on efa.* to 'efa'@'localhost' identified by '$password'"

# flush
/usr/bin/mysql -u root -p"$password" -e "FLUSH PRIVILEGES;"

# populate the sa_bayes DB
/usr/bin/mysql -u root -p"$password" sa_bayes < $srcdir/mariadb/bayes_mysql.sql

# add the AWL table to sa_bayes
/usr/bin/mysql -u root -p"$password" sa_bayes < $srcdir/mariadb/awl_mysql.sql

sed -i "/^\[mysqld\]/ a\character-set-server = utf8mb4" /etc/my.cnf.d/server.cnf
sed -i "/^\[mysqld\]/ a\init-connect = 'SET NAMES utf8mb4'" /etc/my.cnf.d/server.cnf
sed -i "/^\[mysqld\]/ a\collation-server = utf8mb4_unicode_ci" /etc/my.cnf.d/server.cnf

mkdir /var/lib/mysql/temp
chown mysql:mysql /var/lib/mysql/temp
sed -i "/^\[mysqld\]/ a\tmpdir = /var/lib/mysql/temp" /etc/my.cnf.d/server.cnf

echo "Configuring mariadb...done"