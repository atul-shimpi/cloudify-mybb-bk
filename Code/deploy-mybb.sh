#!/bin/bash

#
# Instalation script for MYBB
#

# Configuration variables
CONFIG="./Code"
MYBB_PACKAGE="./Code/mybb_1809.zip"
DEPLOYMENT_DIR="/var/www/html"

# Assert that apache deployment dir is clean
rm -rf "$DEPLOYMENT_DIR"/*

# Unzip MYBB installation files inside apache deployment dir
unzip "$MYBB_PACKAGE"

# Copy extracted files into installation directory
cp -r ./Upload/* "$DEPLOYMENT_DIR"/

# Replace variables in prepared configuration files
sed -e "s/MYBB_ADMINEMAIL/${CNF_PARAM_ADMINEMAIL}/g" -e "s/MYBB_DOMAINNAME/${CNF_PARAM_DOMAINNAME}/g" "${CONFIG}/settings.php" > "${DEPLOYMENT_DIR}/inc/settings.php"

sed -e "s/MYBB_DBNAME/${CNF_PARAM_DBNAME}/g" -e "s/MYBB_DBUSERNAME/${CNF_PARAM_DBUSERNAME}/g" -e "s/MYBB_DBPASSWORD/${CNF_PARAM_DBPASSWORD}/g" \
    -e "s/MYBB_DBHOSTNAME/${CNF_PARAM_DBHOSTNAME}/g" -e "s/MYBB_DBPORT/${CNF_PARAM_DBPORT}/g" "${CONFIG}/config.php" > "${DEPLOYMENT_DIR}/inc/config.php"

# Configure database with ADMIN and DOMAIN variables
sed -e "s/MYBB_ADMINEMAIL/${CNF_PARAM_ADMINEMAIL}/g" -e "s/MYBB_DOMAINNAME/${CNF_PARAM_DOMAINNAME}/g" "${CONFIG}/mybb.sql" 

# Load configured DUMP file into RDS database
mysql --user="$CNF_PARAM_DBUSERNAME" --password="$CNF_PARAM_DBPASSWORD" --host="$CNF_PARAM_DBHOSTNAME" --port="$CNF_PARAM_DBPORT" --database="$CNF_PARAM_DBNAME" < "${CONFIG}/mybb.sql" || echo "Schema Already Exists!"

# Set proper ownership and permissions.
cd "$DEPLOYMENT_DIR"
chmod 666 inc/config.php inc/settings.php
chmod 666 inc/languages/english/*.php inc/languages/english/admin/*.php
chmod 777 cache/ cache/themes/ uploads/ uploads/avatars/
chmod 777 cache/ cache/themes/ uploads/ uploads/avatars/ admin/backups/

# Remove install directory
rm -rf /var/www/html/install