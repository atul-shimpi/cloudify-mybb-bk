#!/bin/bash

# extract mybb and copy it to install directory
INSTALL_DIR="/var/www/html"

rm -rf "$INSTALL_DIR"/*
unzip "./code/mybb_1809.zip"
cp -r ./Upload/* "$INSTALL_DIR"/

# Configure mybb with parameters passed from command line
CODE_DIR="./code"
sed -e "s/MYBB_ADMINEMAIL/${ADMIN_EMAIL}/g" -e "s/MYBB_DOMAINNAME/${DOMAIN_NAME}/g" "${CODE_DIR}/settings.php" > "${INSTALL_DIR}/inc/settings.php"
sed -e "s/MYBB_DBNAME/${DB_NAME}/g" -e "s/MYBB_DBUSERNAME/${DB_USER_NAME}/g" -e "s/MYBB_DBPASSWORD/${DB_PASSWORD}/g" \
    -e "s/MYBB_DBHOSTNAME/${DB_HOST_NAME}/g" -e "s/MYBB_DBPORT/${DB_PORT}/g" "${CODE_DIR}/config.php" > "${INSTALL_DIR}/inc/config.php"

# Configure database
sed -e "s/MYBB_ADMINEMAIL/${ADMIN_EMAIL}/g" -e "s/MYBB_DOMAINNAME/${DOMAIN_NAME}/g" "${CODE_DIR}/mybb.sql" 

# populate database
mysql --user="$DB_USER_NAME" --password="$DB_PASSWORD" --host="$DB_HOST_NAME" --port="$DB_PORT" --database="$DB_NAME" < "${CONFIG}/mybb.sql" || echo "Schema Already Exists!"

# Set permissions
cd "$INSTALL_DIR"
chmod 666 inc/config.php inc/settings.php
chmod 666 inc/languages/english/*.php inc/languages/english/admin/*.php
chmod 777 cache/ cache/themes/ uploads/ uploads/avatars/
chmod 777 cache/ cache/themes/ uploads/ uploads/avatars/ admin/backups/

# Thats all