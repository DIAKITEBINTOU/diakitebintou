#!/bin/bash

echo "
Vagrant.configure(\"2\") do |config|
config.vm.box = \"ubuntu/xenial64\"
config.vm.network \"private_network\", ip: \"192.168.38.69\"
config.vm.provision \"shell\", path: \"scripts/auto-install.sh\"
config.vm.synced_folder \"./data\", \"/var/www/html\", type: \"virtualbox\"
end" > Vagrantfile;
mkdir data;
mkdir scripts;
echo "
sudo apt-get install -y apache2 git cmatrix vim curl
sudo apt-get update
sudo add-apt-repository ppa:ondrej/php
sudo apt-get update
sudo apt install -y php7.2 php7.2-common php7.2-cli php7.2-fpm libapache2-mod-php7.2 php7.2-zip php7.2-mbstring php7.2-dom
export UBUNTU_FRONTEND=\"noninteractive\"
sudo debconf-set-selections <<< \"mysql-server mysql-server/root_password password 0000\";
sudo debconf-set-selections <<< \"mysql-server mysql-server/root_password_again password 0000\";
sudo apt-get install -y mysql-server php7.2-mysql
sudo a2enmod rewrite
sudo sed -i '477s/Off/On/' /etc/php/7.2/apache2/php.ini
sudo sed -i '488s/Off/On/' /etc/php/7.2/apache2/php.ini
sudo sed -i '16s/.*/export APACHE_RUN_USER=vagrant/' /etc/apache2/envvars
sudo sed -i '17s/.*/export APACHE_RUN_GROUP=vagrant/' /etc/apache2/envvars
sudo sed -i '/DocumentRoot .*/ s/$/\/publicnb/' /etc/apache2/sites-available/000-default.conf 
sudo sed -i '12s/nb/\n\t\<Directory \/var\/www\/html\>\n\t\tOptions Indexes FollowSymLinks MultiViews\n\t\tAllowOverride All\n\t\tRequire all granted\n\t\<\/Directory\>/' /etc/apache2/sites-available/000-default.conf
sudo sed -i '221s/$/\n\<ifModule mod_rewrite.c\>\nRewriteEngine On\n\<\/ifModule\>/' /etc/apache2/apache2.conf 
sudo service apache2 restart" > ./scripts/auto-install.sh;
echo "
cd /var/www/
php -r \"copy('https://getcomposer.org/installer', 'composer-setup.php');\"
php composer-setup.php
php -r \"unlink('composer-setup.php');\"
sudo mv composer.phar /usr/local/bin/composer
cd /var/www/html
rm index.html
rm composer+laravel.sh
composer create-project --prefer-dist laravel/laravel ./"> ./data/composer+laravel.sh;
