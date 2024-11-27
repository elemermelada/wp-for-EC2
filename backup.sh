#!/bin/bash

sudo systemctl start mariadb.service

backuppath="backups/$(date | sed 's/ //g' | sed 's/://g')"
mkdir -p "$backuppath"

cp -R /var/www/html "$backuppath/html"

until sudo mariadb-dump -x -A > "$backuppath/db.sql"
do
    echo "Trying to connect to db..."
    sleep 1
done