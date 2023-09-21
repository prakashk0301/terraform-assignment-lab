#!/bin/bash
sudo apt-get update -y
sudo apt-get install apache2 -y
sudo echo "<h1>this is intellipaat assignment</h1>" > /var/www/html/index.html
sudo systemctl start apache2
sudo systemctl enable apache2
