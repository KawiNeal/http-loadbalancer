#! /bin/bash

sudo apt-get update 
sudo apt-get install -y apache2 php
sudo apt-get install -y wget
cd /var/www/html
sudo rm index.html -f
sudo rm index.php -f
sudo wget https://raw.githubusercontent.com/KawiNeal/http-loadbalancer/master/compute/instance_template/index.php
META_REGION_STRING=$(curl "http://metadata.google.internal/computeMetadata/v1/instance/zone" -H "Metadata-Flavor: Google")
REGION=`echo "$META_REGION_STRING" | awk -F/ '{print $4}'`
sudo sed -i "s|region-here|$REGION|" index.php


