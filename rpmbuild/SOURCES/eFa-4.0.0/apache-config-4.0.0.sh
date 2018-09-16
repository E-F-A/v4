#!/bin/sh
#-----------------------------------------------------------------------------#
# eFa 4.0.0 initial apache-configuration script
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
# Start configuration of apache
#-----------------------------------------------------------------------------#
echo "Configuring Apache..."
rm -f /etc/httpd/conf.d/welcome.conf

# Remove not needed modules from Apache config 00-base.conf
sed -i 's/LoadModule version_module modules\/mod_version.so/#&/' /etc/httpd/conf.modules.d/00-base.conf
sed -i 's/LoadModule actions_module modules\/mod_actions.so/#&/' /etc/httpd/conf.modules.d/00-base.conf
sed -i 's/LoadModule authn_anon_module modules\/mod_authn_anon.so/#&/' /etc/httpd/conf.modules.d/00-base.conf
sed -i 's/LoadModule authn_dbd_module modules\/mod_authn_dbd.so/#&/' /etc/httpd/conf.modules.d/00-base.conf
sed -i 's/LoadModule authn_dbm_module modules\/mod_authn_dbm.so/#&/' /etc/httpd/conf.modules.d/00-base.conf
sed -i 's/LoadModule authn_socache_module modules\/mod_authn_socache.so/#&/' /etc/httpd/conf.modules.d/00-base.conf
sed -i 's/LoadModule authz_dbd_module modules\/mod_authz_dbd.so/#&/' /etc/httpd/conf.modules.d/00-base.conf
sed -i 's/LoadModule authz_dbm_module modules\/mod_authz_dbm.so/#&/' /etc/httpd/conf.modules.d/00-base.conf
sed -i 's/LoadModule autoindex_module modules\/mod_autoindex.so/#&/' /etc/httpd/conf.modules.d/00-base.conf
sed -i 's/LoadModule cache_module modules\/mod_cache.so/#&/' /etc/httpd/conf.modules.d/00-base.conf
sed -i 's/LoadModule cache_disk_module modules\/mod_cache_disk.so/#&/' /etc/httpd/conf.modules.d/00-base.conf
sed -i 's/LoadModule data_module modules\/mod_data.so/#&/' /etc/httpd/conf.modules.d/00-base.conf
sed -i 's/LoadModule dbd_module modules\/mod_dbd.so/#&/' /etc/httpd/conf.modules.d/00-base.conf
sed -i 's/LoadModule dumpio_module modules\/mod_dumpio.so/#&/' /etc/httpd/conf.modules.d/00-base.conf
sed -i 's/LoadModule echo_module modules\/mod_echo.so/#&/' /etc/httpd/conf.modules.d/00-base.conf
sed -i 's/LoadModule env_module modules\/mod_env.so/#&/' /etc/httpd/conf.modules.d/00-base.conf
sed -i 's/LoadModule expires_module modules\/mod_expires.so/#&/' /etc/httpd/conf.modules.d/00-base.conf
sed -i 's/LoadModule ext_filter_module modules\/mod_ext_filter.so/#&/' /etc/httpd/conf.modules.d/00-base.conf
sed -i 's/LoadModule filter_module modules\/mod_filter.so/#&/' /etc/httpd/conf.modules.d/00-base.conf
sed -i 's/LoadModule headers_module modules\/mod_headers.so/#&/' /etc/httpd/conf.modules.d/00-base.conf
sed -i 's/LoadModule include_module modules\/mod_include.so/#&/' /etc/httpd/conf.modules.d/00-base.conf
sed -i 's/LoadModule info_module modules\/mod_info.so/#&/' /etc/httpd/conf.modules.d/00-base.conf
sed -i 's/LoadModule negotiation_module modules\/mod_negotiation.so/#&/' /etc/httpd/conf.modules.d/00-base.conf
sed -i 's/LoadModule remoteip_module modules\/mod_remoteip.so/#&/' /etc/httpd/conf.modules.d/00-base.conf
sed -i 's/LoadModule socache_dbm_module modules\/mod_socache_dbm.so/#&/' /etc/httpd/conf.modules.d/00-base.conf
sed -i 's/LoadModule socache_memcache_module modules\/mod_socache_memcache.so/#&/' /etc/httpd/conf.modules.d/00-base.conf
#sed -i 's/LoadModule socache_shmcb_module modules\/mod_socache_shmcb.so/#&/' /etc/httpd/conf.modules.d/00-base.conf
sed -i 's/LoadModule status_module modules\/mod_status.so/#&/' /etc/httpd/conf.modules.d/00-base.conf
sed -i 's/LoadModule status_module modules\/mod_status.so/#&/' /etc/httpd/conf.modules.d/00-base.conf
sed -i 's/LoadModule userdir_module modules\/mod_userdir.so/#&/' /etc/httpd/conf.modules.d/00-base.conf

# Remove not needed modules from Apache config 00-dav.conf
sed -i 's/LoadModule dav_module modules\/mod_dav.so/#&/' /etc/httpd/conf.modules.d/00-dav.conf
sed -i 's/LoadModule dav_fs_module modules\/mod_dav_fs.so/#&/' /etc/httpd/conf.modules.d/00-dav.conf
sed -i 's/LoadModule dav_lock_module modules\/mod_dav_lock.so/#&/' /etc/httpd/conf.modules.d/00-dav.conf

# Remove not needed modules from Apache config 00-lua.conf
sed -i 's/LoadModule lua_module modules\/mod_lua.so/#&/' /etc/httpd/conf.modules.d/00-lua.conf

# We don't use auto index so remove the file
mv /etc/httpd/conf.d/autoindex.conf /etc/httpd/conf.d/autoindex.conf.orig

# Disable proxy modules
# Needed for php-fpm
#sed -i 's/LoadModule proxy_module modules\/mod_proxy.so/#&/' /etc/httpd/conf.modules.d/00-proxy.conf
sed -i 's/LoadModule lbmethod_bybusyness_module modules\/mod_lbmethod_bybusyness.so/#&/' /etc/httpd/conf.modules.d/00-proxy.conf
sed -i 's/LoadModule lbmethod_byrequests_module modules\/mod_lbmethod_byrequests.so/#&/' /etc/httpd/conf.modules.d/00-proxy.conf
sed -i 's/LoadModule lbmethod_bytraffic_module modules\/mod_lbmethod_bytraffic.so/#&/' /etc/httpd/conf.modules.d/00-proxy.conf
sed -i 's/LoadModule lbmethod_heartbeat_module modules\/mod_lbmethod_heartbeat.so/#&/' /etc/httpd/conf.modules.d/00-proxy.conf
sed -i 's/LoadModule proxy_ajp_module modules\/mod_proxy_ajp.so/#&/' /etc/httpd/conf.modules.d/00-proxy.conf
sed -i 's/LoadModule proxy_balancer_module modules\/mod_proxy_balancer.so/#&/' /etc/httpd/conf.modules.d/00-proxy.conf
sed -i 's/LoadModule proxy_connect_module modules\/mod_proxy_connect.so/#&/' /etc/httpd/conf.modules.d/00-proxy.conf
sed -i 's/LoadModule proxy_express_module modules\/mod_proxy_express.so/#&/' /etc/httpd/conf.modules.d/00-proxy.conf
# Needed for php-fpm
#sed -i 's/LoadModule proxy_fcgi_module modules\/mod_proxy_fcgi.so/#&/' /etc/httpd/conf.modules.d/00-proxy.conf
sed -i 's/LoadModule proxy_fdpass_module modules\/mod_proxy_fdpass.so/#&/' /etc/httpd/conf.modules.d/00-proxy.conf
sed -i 's/LoadModule proxy_ftp_module modules\/mod_proxy_ftp.so/#&/' /etc/httpd/conf.modules.d/00-proxy.conf
sed -i 's/LoadModule proxy_http_module modules\/mod_proxy_http.so/#&/' /etc/httpd/conf.modules.d/00-proxy.conf
sed -i 's/LoadModule proxy_scgi_module modules\/mod_proxy_scgi.so/#&/' /etc/httpd/conf.modules.d/00-proxy.conf
sed -i 's/LoadModule proxy_wstunnel_module modules\/mod_proxy_wstunnel.so/#&/' /etc/httpd/conf.modules.d/00-proxy.conf

# Configure HTTP
sed -i '/    Options Indexes FollowSymLinks/ c\    Options None' /etc/httpd/conf/httpd.conf

# Configure SSL
sed -i '/^#Listen 443/ c\Listen 443 https' /etc/httpd/conf.d/ssl.conf
sed -i "/^SSLProtocol/ c\SSLProtocol all -SSLv2 -SSLv3" /etc/httpd/conf.d/ssl.conf
echo -e "RewriteEngine On" > /etc/httpd/conf.d/redirectssl.conf
echo -e "RewriteCond %{SERVER_PORT} 80" >> /etc/httpd/conf.d/redirectssl.conf
echo -e "RewriteCond %{REQUEST_URI} !^/\.well\-known/acme\-challenge/" >> /etc/httpd/conf.d/redirectssl.conf
echo -e "RewriteRule ^/?(.*) https://%{SERVER_NAME}/\$1 [R,L]" >> /etc/httpd/conf.d/redirectssl.conf

# Harden Apache
sed -i "/^SSLCipherSuite/ c\SSLCipherSuite ECDSA+AESGCM:ECDH+AESGCM:ECDSA+AES:ECDH+AES:RSA+AESGCM:RSA+AES:\!aNULL:\!MD5:\!DSS:\!3DES:\!EXP" /etc/httpd/conf.d/ssl.conf
sed -i '/^SSLCipherSuite ECDSA+AESGCM:ECDH+AESGCM:ECDSA+AES:ECDH+AES:RSA+AESGCM:RSA+AES:\!aNULL:\!MD5:\!DSS:\!3DES:\!EXP/a SSLHonorCipherOrder on'  /etc/httpd/conf.d/ssl.conf

# Disable PHP functions
sed -i '/disable_functions =/ c\disable_functions = apache_child_terminate,apache_setenv,define_syslog_variables,escapeshellcmd,eval,fp,fput,ftp_connect,ftp_exec,ftp_get,ftp_login,ftp_nb_fput,ftp_put,ftp_raw,ftp_rawlist,highlight_file,ini_alter,ini_get_all,ini_restore,inject_code,openlog,phpAds_remoteInfo,phpAds_XmlRpc,phpAds_xmlrpcDecode,phpAds_xmlrpcEncode,posix_getpwuid,posix_kill,posix_mkfifo,posix_setpgid,posix_setuid,posix_setuid,posix_uname,syslog,system,xmlrpc_entity_decode,curl_multi_exec' /etc/php.ini

# Configure php-fpm
cat > /etc/httpd/conf.d/fpm.conf << 'EOF'
# PHP scripts setup
<FilesMatch \.php$>
    SetHandler "proxy:fcgi://127.0.0.1:9000"
</FilesMatch>


Alias / /var/www/html/
EOF
# Pass a PATH environment variable to php-fpm for exec to call binaries
sed -i '/^;env[PATH] =/ c\env[PATH] = /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin' /etc/php-fpm.d/www.conf
echo "Configuring Apache...Done"