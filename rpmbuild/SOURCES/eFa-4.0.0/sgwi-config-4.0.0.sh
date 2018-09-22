#!/bin/sh
#-----------------------------------------------------------------------------#
# eFa 4.0.0 initial sqlgrey-configuration script
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
# Start configuration of sqlgrey
#-----------------------------------------------------------------------------#
echo "Configuring sgwi..."

    # add db credential
    # Issue #66 Grab all passwords from EFA-Config
    sed -i '/^$db_user/ c\$db_user        = "sqlgrey";' /var/www/html/sgwi/includes/config.inc.php
    sed -i "/^\$db_pass/ c\$efa_array = preg_grep('/^SQLGREYSQLPWD/', file('/etc/EFA-Config'));\nforeach(\$efa_array as \$num => \$line) {\n  if (\$line) {\n    \$db_pass = chop(preg_replace('/^SQLGREYSQLPWD:(.*)/','\$1',\$line));\n  }\n}" /var/www/html/sgwi/includes/config.inc.php

    # Add greylist to mailwatch menu
    # hide from non-admins
    sed -i "/^        \$nav\['docs.php'\] =/{N;s/$/\n        \/\/Begin EFA\n        if \(\$_SESSION\['user_type'\] == 'A' \&\& SHOW_GREYLIST == true\) \{\n            \$nav\['grey.php'\] = \"greylist\";\n        \}\n        \/\/End EFA/}" /var/www/html/mailscanner/functions.php

    # add SHOW_GREYLIST to conf.php
    echo "" >> /var/www/html/mailscanner/conf.php
    echo "// Greylisting menu item" >> /var/www/html/mailscanner/conf.php
    echo "define('SHOW_GREYLIST', true);" >> /var/www/html/mailscanner/conf.php

    # Create wrapper
    touch /var/www/html/mailscanner/grey.php
    echo "<?php" > /var/www/html/mailscanner/grey.php
    echo "" >> /var/www/html/mailscanner/grey.php
    echo "require_once(\"./functions.php\");" >> /var/www/html/mailscanner/grey.php
    echo "session_start();" >> /var/www/html/mailscanner/grey.php
    echo "require('login.function.php');" >> /var/www/html/mailscanner/grey.php
    echo "\$refresh = html_start(\"greylist\",0,false,false);" >> /var/www/html/mailscanner/grey.php
    echo "?>" >> /var/www/html/mailscanner/grey.php
    echo "<iframe src=\"../sgwi/index.php\" width=\"960px\" height=\"1024px\">" >> /var/www/html/mailscanner/grey.php
    echo " <a href=\"..\sgwi/index.php\">Click here for SQLGrey Web Interface</a>" >> /var/www/html/mailscanner/grey.php
    echo "</iframe>" >> /var/www/html/mailscanner/grey.php
    echo "<?php" >> /var/www/html/mailscanner/grey.php
    echo "html_end();" >> /var/www/html/mailscanner/grey.php
    echo "dbclose();" >> /var/www/html/mailscanner/grey.php

    # Secure sgwi from direct access
    cd /var/www/html/sgwi
    ln -s ../mailscanner/login.function.php login.function.php
    ln -s ../mailscanner/login.php login.php
    ln -s ../mailscanner/functions.php functions.php
    ln -s ../mailscanner/checklogin.php checklogin.php
    ln -s ../mailscanner/conf.php conf.php
    mkdir images
    ln -s ../../mailscanner/images/EFAlogo-79px.png ./images/mailwatch-logo.png
    cp ../mailscanner/images/favicon.png ./images/favicon.png
    sed -i "/^<?php/ a\//Begin EFA\nsession_start();\nrequire('login.function.php');\n\nif (\$_SESSION['user_type'] != 'A') die('Access Denied');\n//End EFA" /var/www/html/sgwi/index.php
    sed -i "/^<?php/ a\//Begin EFA\nsession_start();\nrequire('login.function.php');\n\nif (\$_SESSION['user_type'] != 'A') die('Access Denied');\n//End EFA" /var/www/html/sgwi/awl.php
    sed -i "/^<?php/ a\//Begin EFA\nsession_start();\nrequire('login.function.php');\n\nif (\$_SESSION['user_type'] != 'A') die('Access Denied');\n//End EFA" /var/www/html/sgwi/connect.php
    sed -i "/^<?php/ a\//Begin EFA\nsession_start();\nrequire('login.function.php');\n\nif (\$_SESSION['user_type'] != 'A') die('Access Denied');\n//End EFA" /var/www/html/sgwi/opt_in_out.php

echo "Configuring sgwi...done"
