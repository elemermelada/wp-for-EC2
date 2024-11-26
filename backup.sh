#!/bin/bash

backuppath="backups/$(date | sed 's/ //g' | sed 's/://g')"
mkdir -p "$backuppath"

cp -R /var/www/html "$backuppath/html"
sudo mariadb-dump -x -A > "$backuppath/db.sql"