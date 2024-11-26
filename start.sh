#!/bin/bash

sudo systemctl start mariadb.service
sudo systemctl start httpd.service
sudo systemctl start php-fpm.service