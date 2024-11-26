#!/bin/bash

sudo systemctl stop mariadb.service
sudo systemctl stop httpd.service
sudo systemctl stop php-fpm.service