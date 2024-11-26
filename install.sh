#!/bin/bash

## INSTALL DEPS
sudo yum install -y httpd mariadb-server php git php-mysqlnd zip

## CREATE BACKUP
./backup.sh

## INSTALL WP FILES
if test -d /var/www/html; then
    echo "THIS OPERATION WILL DELETE THE CURRENT SITE"
    read -p "Continue? [y/(n)]: " yn

    case $yn in 
	y) sudo rm -R /var/www/html;;
	*) exit 1;;
    esac
fi

sudo git clone https://github.com/WordPress/WordPress /var/www/html

sudo setenforce 0                            # Allow WP to access files (redhat policy)
sudo chown -R apache:apache /var/www/html    # Set ownership to apache user
sudo chmod -R 777 /var/www/html              # Set permissions to max during setup

## SETUP DATABASE
dbname="wp"
dbuser="dbuser"
dbpass="dbpass"

sudo mariadb --execute "DROP DATABASE IF EXISTS $dbname;"

sudo mariadb --execute "CREATE DATABASE $dbname;"
sudo mariadb --execute "GRANT ALL PRIVILEGES ON $dbname.* TO '$dbuser'@'localhost' IDENTIFIED BY '$dbpass';"
echo "Created database \"$dbname\" with user \"$dbuser\" and password \"$dbpass\""

## START WP AND LET USER CONFIGURE
./start.sh
read -p "Configure WP and press ENTER..." _

## CLEANUP
sudo find /var/www/html -type d -exec chmod 755 {} \;        # Clean directory permissions
sudo find /var/www/html -type f -exec chmod 644 {} \;        # Clean file permissions

## DOWNTIME PREVENTION
echo "@reboot $PWD/start.sh" | sudo crontab -               # Add start task on crontab
crashpolicy="[Service]\nRestart=on-failure\nRestartSec=5s"  # Make service restart on crash

./stop.sh

sudo mkdir -p /etc/systemd/system/httpd.service.d
echo -e "$crashpolicy" | sudo tee /etc/systemd/system/httpd.service.d/override.conf > /dev/null

sudo mkdir -p /etc/systemd/system/mariadb.service.d
echo -e "$crashpolicy" | sudo tee /etc/systemd/system/mariadb.service.d/override.conf > /dev/null

sudo mkdir -p /etc/systemd/system/php-fpm.service.d
echo -e "$crashpolicy" | sudo tee /etc/systemd/system/php-fpm.service.d/override.conf > /dev/null

sudo systemctl daemon-reload
./start.sh