#!/bin/sh
#-----------------------------------------------------------------------------#
# eFa 4.0.0 initial apache-configuration script
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
# Start configuration of apache
#-----------------------------------------------------------------------------#
rm -f /etc/httpd/conf.d/welcome.conf

# Remove unwanted modules
sed -i '/LoadModule ldap_module modules\/mod_ldap.so/d' /etc/httpd/conf/httpd.conf
sed -i '/LoadModule authnz_ldap_module modules\/mod_authnz_ldap.so/d' /etc/httpd/conf/httpd.conf
sed -i '/LoadModule dav_module modules\/mod_dav.so/d' /etc/httpd/conf/httpd.conf
sed -i '/LoadModule autoindex_module modules\/mod_autoindex.so/d' /etc/httpd/conf/httpd.conf
sed -i '/LoadModule info_module modules\/mod_info.so/d' /etc/httpd/conf/httpd.conf
sed -i '/LoadModule dav_fs_module modules\/mod_dav_fs.so/d' /etc/httpd/conf/httpd.conf
sed -i '/LoadModule userdir_module modules\/mod_userdir.so/d' /etc/httpd/conf/httpd.conf
sed -i '/LoadModule proxy_module modules\/mod_proxy.so/d' /etc/httpd/conf/httpd.conf
sed -i '/LoadModule proxy_balancer_module modules\/mod_proxy_balancer.so/d' /etc/httpd/conf/httpd.conf
sed -i '/LoadModule proxy_ftp_module modules\/mod_proxy_ftp.so/d' /etc/httpd/conf/httpd.conf
sed -i '/LoadModule proxy_http_module modules\/mod_proxy_http.so/d' /etc/httpd/conf/httpd.conf
sed -i '/LoadModule proxy_ajp_module modules\/mod_proxy_ajp.so/d' /etc/httpd/conf/httpd.conf
sed -i '/LoadModule proxy_connect_module modules\/mod_proxy_connect.so/d' /etc/httpd/conf/httpd.conf
sed -i '/LoadModule version_module modules\/mod_version.so/d' /etc/httpd/conf/httpd.conf

# Remove config for disabled modules
sed -i '/IndexOptions /d' /etc/httpd/conf/httpd.conf
sed -i '/AddIconByEncoding /d' /etc/httpd/conf/httpd.conf
sed -i '/AddIconByType /d' /etc/httpd/conf/httpd.conf
sed -i '/AddIcon /d' /etc/httpd/conf/httpd.conf
sed -i '/DefaultIcon /d' /etc/httpd/conf/httpd.conf
sed -i '/ReadmeName /d' /etc/httpd/conf/httpd.conf
sed -i '/HeaderName /d' /etc/httpd/conf/httpd.conf
sed -i '/IndexIgnore /d' /etc/httpd/conf/httpd.conf
sed -i "/^SSLProtocol/ c\SSLProtocol all -SSLv2 -SSLv3" /etc/httpd/conf.d/ssl.conf

sed -i '/^#Listen 443/ c\Listen 443' /etc/httpd/conf.d/ssl.conf
echo -e "RewriteEngine On" > /etc/httpd/conf.d/redirectssl.conf
echo -e "RewriteCond %{HTTPS} !=on" >> /etc/httpd/conf.d/redirectssl.conf
echo -e "RewriteRule ^/?(.*) https://%{SERVER_NAME}/\$1 [R,L]" >> /etc/httpd/conf.d/redirectssl.conf

sed -i '/disable_functions =/ c\disable_functions = apache_child_terminate,apache_setenv,define_syslog_variables,escapeshellcmd,eval,fp,fput,ftp_connect,ftp_exec,ftp_get,ftp_login,ftp_nb_fput,ftp_put,ftp_raw,ftp_rawlist,highlight_file,ini_alter,ini_get_all,ini_restore,inject_code,openlog,phpAds_remoteInfo,phpAds_XmlRpc,phpAds_xmlrpcDecode,phpAds_xmlrpcEncode,posix_getpwuid,posix_kill,posix_mkfifo,posix_setpgid,posix_setsid,posix_setuid,posix_setuid,posix_uname,proc_close,proc_get_status,proc_nice,proc_open,proc_terminate,syslog,system,xmlrpc_entity_decode,curl_multi_exec' /etc/php.ini
