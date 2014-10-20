Machinator
======

Machinator is a bash tool for easily creating docker.io based containers with LEMP stack. There are two main contain ers that managing to full structure. Firts of them is nginx-reverse-proxy container, second of them is mysql-container.
Currently supporting Magento, Prestashop, Laravel and Wordpress projects. mynxer also able to clone your projects from any Git or SVN repository.

##How to install?

This script assumes that you've already docker.io installed on your host. If you've already intalled, than:

$ cd reverse-proxy/ && sudo ./build.sh

# Now we need to install MySQL container.

$ cd mysql-server/ && sudo ./build.sh


Now we ready to create our first container image :

$ cd reverse-proxy/ && sudo ./add_new_host.sh mydevelopment.dev mydev

The script will ask you some questions, just follow the "white rabbit"!
Currently supporting Magento, PrestaShop, Laravel, and Wordpress projects.
The script is also able to clone SVN and Git based projects.
After all the script creates a mysql database and user on mysql-container.


Any pull request more than welcome!
