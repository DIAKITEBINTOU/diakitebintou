#!/bin/bash
#ProjectKB

echo "
#!/bin/sh

Vagrant.configure(\"2\") do |config|
config.vm.box = \"ubuntu/xenial64\"
config.vm.network \"private_network\", ip: \"192.168.33.10\"
config.vm.provision \"shell\", path: \"scripts/auto-install.sh\"
config.vm.synced_folder \"./data\", \"/var/www/html\", type: \"virtualbox\"
end" > Vagrantfile;

mkdir data;
mkdir scripts;

echo "
#!/bin/sh

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
sudo service apache2 restart;" > ./scripts/auto-install.sh;

echo "
#!/bin/sh
#Use this script to ssh mod

rm index.html
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp
wp core download --locale=fr_FR
echo 'create database wordpress;' > wordpress.sql
mysql -u root -p0000 < wordpress.sql
rm wordpress.sql
wp config create --dbname=wordpress --dbuser=root --dbpass=0000
echo 'Enter title of your website'
read title
echo 'Enter admin user.'
read user
echo 'Enter password.'
read password
echo 'Enter password again'
read verifyPassword
if [: \$password == \$verifyPassword ]
then
	wp core install --url=192.168.33.10 --title=\$title --admin_user=\$user --admin_password=\$password --admin_email=admin@admin.com
	else

		while [ \$password != \$verifyPassword ]
		do
			echo 'Error. Please put two similar password.'
			echo 'Enter password.'
			read password
			echo 'Enter password again'
			read verifyPassword
		done
		wp core install --url=192.168.33.10 --title=\$title --admin_user=admin --admin_password=\$password --admin_email=admin@admin.com
fi" > ./data/install_wordpress.sh

echo "
#!/bin/bash
#Use this script to ssh mod

PS3='Choose an option : '
options=(\"Manage themes\" \"Manage plugins\" \"Quit\")
select opt in \"\${options[@]}\"
do
    case \$opt in
        \"Manage themes\")
            echo \"You've choose to manage themes.\"
            options=(\"Search/Add\" \"Add\" \"Remove\" \"Activate\" \"Precedent\")
            select opt in \"\${options[@]}\"
            do
                case \$opt in
                \"Search/Add\")
                echo \"Enter the name of theme you are looking for\"
                read searchtheme
                wp theme search \$searchtheme
                                echo \"Which theme (by slug) do you want to add ?\"
                                read addTheme
                                echo \"Are you sure to want to add \$addTheme ? y/n\"
                                read answer
                                if [ \$answer == 'y' ]
                                then
                                        wp theme install \$addTheme
                                        echo \"| 1-Search/Add | 2-Add | 3-Remove | 4-Activate | 5-Precedent |\"
                                else
                                        echo \"| 1-Search/Add | 2-Add | 3-Remove | 4-Activate | 5-Precedent |\"           
                                        break
                                fi
                ;;
                \"Add\")
                wp theme list
                echo \"Which theme (by slug) do you want to add ?\"
                read slug
                wp theme install \$slug
                                echo \"| 1-Search/Add | 2-Add | 3-Remove | 4-Activate | 5-Precedent |\"
                ;;
                \"Remove\")
                wp theme list
                echo \"Which theme (by slug) do you want to remove ?\"
                read deleteSlug
                wp theme delete \$deleteSlug
                                echo \"| 1-Search/Add | 2-Add | 3-Remove | 4-Activate | 5-Precedent |\"
                ;;
                \"Activate\")
                wp theme list
                echo \"Which theme do you want to activate ?\"
                read activatetheme
                wp theme activate \$activatetheme
                                echo \"| 1-Search/Add | 2-Add | 3-Remove | 4-Activate | 5-Precedent |\"
                ;;
                \"Precedent\")
                echo \"You asked to go back to precedent menu : | 1-Manage themes | 2-Manage plugins | 3-Quit |\"
                break
                ;;
                *) echo  \"Unvalid option. | 1-Search/Add | 2-Add | 3-Remove | 4-Activate | 5-Precedent |\";;
                esac
            done
            ;;
        \"Manage plugins\")
            echo \"You've choose to manage plugins\"

            options=(\"Search/Add\" \"Add\" \"Remove\" \"Activate\" \"Desactivate\" \"Precedent\")
            select opt in \"\${options[@]}\"
            do
                case \$opt in
               \"Search/Add\")
                echo \"Enter the name of plugin you are looking for\"
                read searchplugin
                wp plugin search \$searchplugin
                                echo \"Which plugin \(by slug\) do you want to add ?\"
                                read addPlugin
                                echo \"Are you sure to want to add \$addPlugin ? y/n\"
                                read answer
                                if [ \$answer == 'y' ]
                                then
                                        wp plugin install \$addPlugin
                                        echo \"| 1-Search/Add | 2-Add | 3-Remove | 4-Activate | 5-Desactivate | 6-Precedent |\"
                                else
                                        echo \"| 1-Search/Add | 2-Add | 3-Remove | 4-Activate | 5-Desactivate | 6-Precedent |\"
                                        break
                                fi
                ;;
                \"Add\")
                wp plugin list
                echo \"Which plugin (by slug) do you want to add ?\"
                read slug
                wp plugin install \$slug
                echo \"| 1-Search/Add | 2-Add | 3-Remove | 4-Activate | 5-Desactivate | 6-Precedent |\"
                ;;
                \"Remove\")
                wp plugin list
                echo \"Which plugin (by slug) do you want to remove ?\"
                read deleteplugin
                wp plugin delete \$deleteplugin
                echo \"| 1-Search/Add | 2-Add | 3-Remove | 4-Activate | 5-Desactivate | 6-Precedent |\"
                ;;
                \"Activate\")
                wp theme list
                echo \"Which plugin do you want to activate ?\"
                read activateplugin
                wp plugin activate \$activateplugin
                echo \"| 1-Search/Add | 2-Add | 3-Remove | 4-Activate | 5-Desactivate | 6-Precedent |\"
                ;;
                \"Desactivate\")
                wp theme list
                echo \"Which plugin do you want to desactivate ?\"
                read deactivateplugin
                wp plugin deactivate \$deactivateplugin
                echo \"| 1-Search/Add | 2-Add | 3-Remove | 4-Activate | 5-Desactivate | 6-Precedent |\"
                ;;
                \"Precedent\")
                echo \"You asked to go back to precedent menu : | 1-Manage themes | 2-Manage plugins | 3-Quit |\"
                break
                ;;
                *) echo  \"Unvalid option. | 1-Search/Add | 2-Add | 3-Remove | 4-Activate | 5-Desactivate | 6-Precedent |\";;
                esac
            done
            ;;
            \"Quit\")
            break
            ;;
        *) echo  \"Unvalid option. | 1-Manage themes | 2-Manage plugins | 3-Quit |\";;
    esac
done" > ./data/manageTP.sh
