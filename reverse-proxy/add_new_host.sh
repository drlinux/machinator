#!/bin/bash
#add_new_domain subdomain.testserver.com subdomain

PATTERN="^(([a-zA-Z]|[a-zA-Z][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z]|[A-Za-z][A-Za-z0-9\-]*[A-Za-z0-9])$";
TEMP=/tmp/answer.$$
MENU_INPUT=/tmp/menu.sh.$$
MENU_OUTPUT=/tmp/output.sh.$$
TEMP=/tmp/answer.$$
MYSQL_DATABASE_PASSWORD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 12 | head -n 1)
DOCKER_MAIN_IP=$(ip addr show docker0 | grep 172 | cut -c-20 | sed 's/inet/ /g' | sed -e 's/^[ \t]*//')

# if temp files exists, destroy`em all!

[ -f $MENU_OUTPUT ] && rm $MENU_OUTPUT
[ -f $MENU_INPUT ] && rm $MENU_INPUT

check_free_port(){

    PORT=$1


    while true

    do

        if (netstat -ln | grep ":$PORT " | grep "LISTEN" > /dev/null); then


            let "PORT++"


        else
            echo $PORT;

            break;

        fi;

    done

}

#add_new_domain alias domain.name

add_new_domain(){



    DOMAIN=$1

    FREE_PORT=$(check_free_port 81)
    MYSQL_DATABASE_USER="$2@%"

    cp templates/proxy.conf "$2".conf

    sed -i -e "s/DOMAIN/$1/g" "$2".conf

    sed -i -e "s/ALIAS/$2/g" "$2".conf

    sed -i -e "s/PORT/$FREE_PORT/g" "$2".conf

    cp mysql_command "$1"._mysql_command.sql

    sed -i -e "s/MYSQL_DATABASE_USER/$2/g" "$1"._mysql_command.sql

    sed -i -e "s/MYSQL_DATABASE_NAME/$2/g" "$1"._mysql_command.sql

    sed -i -e "s/MYSQL_DATABASE_PASSWORD/$MYSQL_DATABASE_PASSWORD/g" "$1"._mysql_command.sql



    #ssh-keygen -f "/root/.ssh/known_hosts" -R $(docker inspect --format="{{ .NetworkSettings.IPAddress }}" machinator-reverse-proxy)

    #ssh-keygen -f "/root/.ssh/known_hosts" -R $(docker inspect --format="{{ .NetworkSettings.IPAddress }}" machinator-mysql-server)

    scp -i insecure_key "$1"._mysql_command.sql root@$(docker inspect --format="{{ .NetworkSettings.IPAddress }}" machinator-mysql-server):/root/



    scp -i insecure_key "$2".conf root@$(docker inspect --format="{{ .NetworkSettings.IPAddress }}" machinator-reverse-proxy):/etc/nginx/conf.d/

    ssh -i insecure_key root@$(docker inspect --format="{{ .NetworkSettings.IPAddress }}" machinator-reverse-proxy) 'mkdir -p /var/log/nginx/log/; touch /var/log/nginx/log/'$1'.error.log; touch /var/log/nginx/log/'$1'.access.log; /etc/init.d/nginx reload'

    docker commit -m "ADD new host : $1" $(docker inspect --format="{{ .Config.Hostname }}" machinator-reverse-proxy) machinator/nginx-reverse-proxy:latest


    ssh -i insecure_key root@$(docker inspect --format="{{ .NetworkSettings.IPAddress }}" machinator-mysql-server) 'mysql -uroot -proot < /root/'$1'._mysql_command.sql'


    docker commit -m "ADD new MySQL user and database : $2 : $MYSQL_DATABASE_PASSWORD" $(docker inspect --format="{{ .Config.Hostname }}" machinator-mysql-server) machinator/nginx-mysql-server:latest

    rm -f "$2".conf

    #let's create docker host container for the domain.
    #but, we need some information for the host container such as php version, project type etc..
    #we need project type because nginx needs differend kind of virtual host configurations
    #for each project type
    #this section heavily inspired from the mynxer project

    #create a directory for the domain
    #we'll store the Dockerfile and (if there are some) neccessary files in the directory
    #for access easily later.

    mkdir -p ~/machinator-dockerfiles/$1/

    while true
    do

        ### ask for php version ###


        dialog --clear \
            --title "Project Type" \
            --menu "Please Choose the PHP Version" 15 50 4 \
            'PHP 5.5' "PHP 5.5 (Required)" \
            'PHP 5.4' "PHP 5.4" 2>"${MENU_INPUT}"

        usersphpselection=$(<"${MENU_INPUT}")


        if [ "$usersphpselection" = 'PHP 5.4'  ]; then

            cp -rf ../php-54/* ~/machinator-dockerfiles/$1/
                    elif [ "$usersphpselection" = 'PHP 5.5' ]; then

            cp -rf ../php-55/* ~/machinator-dockerfiles/$1/


        fi

        mv "$1"._mysql_command.sql ~/machinator-dockerfiles/$1/

        # if temp files exists, destroy`em all!


        [ -f $MENU_OUTPUT ] && rm $MENU_OUTPUT
        [ -f $MENU_INPUT ] && rm $MENU_INPUT

        project_type $1 $2


    done
    exit

}

project_type(){

    #ask for the project type

    while true
    do


        ### display main menu ###

        dialog --clear \
            --title "Project Type" \
            --menu "Please Choose the Project Type" 15 50 4 \
            Magento "Magento Project" \
            Prestashop "Prestashop Project" \
            Wordpress "Wordpress Project" \
            Laravel "Laravel Project" \
            Other "Generic PHP / HTML Project" 2>"${MENU_INPUT}"

        userselection=$(<"${MENU_INPUT}")

        if [ "$userselection" = 'Magento' ]; then

            THE_REPO="https://github.com/magento/magento2.git"

        elif [ "$userselection" = 'Prestashop' ]; then

            THE_REPO="https://github.com/PrestaShop/PrestaShop.git"

        elif [ "$userselection" = 'Laravel' ]; then

            THE_REPO="https://github.com/laravel/laravel.git"

        elif [ "$userselection" = 'Wordpress' ]; then

            THE_REPO="https://github.com/WordPress/WordPress.git"

        fi

        echo 'ADD www.conf /etc/php5/fpm/pool.d/www.conf' >> ~/machinator-dockerfiles/$1/Dockerfile


        echo 'ADD php.ini /etc/php5/fpm/php.ini' >> ~/machinator-dockerfiles/$1/Dockerfile

        rm -f  ~/machinator-dockerfiles/$1/nginx-site.conf

        cp -f ../virtual-host-templates/virtual_host_"$userselection".template ~/machinator-dockerfiles/$1/nginx-site.conf

        echo 'RUN rm -f /etc/nginx/sites-available/default' >> ~/machinator-dockerfiles/$1/Dockerfile

        echo 'ADD nginx-site.conf /etc/nginx/sites-available/default' >> ~/machinator-dockerfiles/$1/Dockerfile


        echo "RUN sed -i -e 's/^listen =.*/listen = \/var\/run\/php5-fpm.sock/' /etc/php5/fpm/pool.d/www.conf" >> ~/machinator-dockerfiles/$1/Dockerfile

        echo 'RUN sed -i "s/DOMAIN/'$DOMAIN'/g" /etc/nginx/sites-available/default' >> ~/machinator-dockerfiles/$1/Dockerfile

        echo 'RUN sed -i "s/ROOT/\/var\/www\/'$1'/g" /etc/nginx/sites-available/default' >> ~/machinator-dockerfiles/$1/Dockerfile

        echo 'RUN apt-get install -y screen' >> ~/machinator-dockerfiles/$1/Dockerfile


        echo 'RUN chmod 0777 /var/run/screen' >> ~/machinator-dockerfiles/$1/Dockerfile


        [ -f $MENU_OUTPUT ] && rm $MENU_OUTPUT
        [ -f $MENU_INPUT ] && rm $MENU_INPUT

        scm_type $1 $2 $THE_REPO

    done
    exit

}

scm_type(){

    THE_REPO=$3

    dialog --clear \
        --title "SCM" \
        --menu "Please Choose the Project Files Source" 15 50 4 \
        Github "Get most recent code from Github" \
        URL "Copy from an URL" \
        Git "Personal Git Repo" \
        SVN "Personal SVN Repo" 2>"${MENU_INPUT}"

    userscmselection=$(<"${MENU_INPUT}")

    if [ "$userscmselection" = 'Github' ]; then

        tput clear

        git clone $THE_REPO /data/www/$1

    elif [ "$userscmselection" = 'Git' ]; then

        tput clear

        dialog --screen-center --title "Personal / Private SCM URL" --inputbox "Enter your repo URL below:" 8 40 2> $TEMP

        REPO_URL=`cat $TEMP`

        rm -f $TEMP

        git clone $REPO_URL /data/www/$1

    elif [ "$userscmselection" = 'URL' ]; then

        tput clear

        mkdir -p /data/www/$1

        REPO_URL='http://www.magentocommerce.com/downloads/assets/1.9.0.1/magento-1.9.0.1.tar.gz'

        cd /data/www/$1 && wget $REPO_URL && tar zxvf magento-1.9.0.1.tar.gz && mv magento/* . && rm -rf magento/ && rm -rf magento-1.9.0.1.tar.gz

        chmod 0777 /data/www/'$1'/media
        chmod 0777 /data/www/'$1'/media/xmlconnect
        chmod 0777 /data/www/'$1'/media/xmlconnect/custom
        chmod 0777 /data/www/'$1'/media/xmlconnect/custom/ok.gif
        chmod 0777 /data/www/'$1'/media/xmlconnect/original
        chmod 0777 /data/www/'$1'/media/xmlconnect/original/ok.gif
        chmod 0777 /data/www/'$1'/media/xmlconnect/system
        chmod 0777 /data/www/'$1'/media/xmlconnect/system/ok.gif
        chmod 0777 /data/www/'$1'/media/dhl
        chmod 0777 /data/www/'$1'/media/dhl/logo.jpg
        chmod 0777 /data/www/'$1'/media/customer
        chmod 0777 /data/www/'$1'/media/downloadable


    elif [ "$userscmselection" = 'SVN' ]; then


        sudo apt-get install -y subversion
        svn checkout $REPO_URL /data/www/$1


    fi
    container_settings $1 $2
    exit

}

container_settings(){

    echo 'EXPOSE 80' >> ~/machinator-dockerfiles/$1/Dockerfile


    #RUN composer update for Laravel project

    if [ "$userselection" = 'Laravel' ]; then


        cd /data/www/$1 && composer update

    elif [ "$userselection" = 'Magento' ]; then

        echo 'ADD 		magento.sh /etc/service/magento/run' >> ~/machinator-dockerfiles/$1/Dockerfile

        echo 'RUN 		chmod a+x /etc/service/magento/run' >> ~/machinator-dockerfiles/$1/Dockerfile

    fi


    #And Start the services

    echo 'CMD nginx -c /etc/nginx/nginx.conf' >> ~/machinator-dockerfiles/$1/Dockerfile


    [ -f $MENU_OUTPUT ] && rm $MENU_OUTPUT

    [ -f $MENU_INPUT ] && rm $MENU_INPUT

    ### DOCKER FILE GENERATED ####

    #Now we'll create our host container from the Dockerfile

    #First we need to add runtime variables to start and build scripts.


    cd ~/machinator-dockerfiles/$1/

    sed -i -e "s/DOMAIN/$1/g" build.sh

    sed -i -e "s/DOMAIN/$1/g" start.sh

    sed -i -e "s/DOMAIN/$1/g" ssh-login.sh

    sed -i -e "s/PORT/$FREE_PORT/g" build.sh

    sed -i -e "s/PORT/$FREE_PORT/g" start.sh

    sed -i "s#ROOT#\/data\/www\/$1#g" build.sh

    sed -i "s#ROOT#\/data\/www\/$1#g" start.sh


    echo 'CMD ["/sbin/my_init", "--quiet"]' >> ~/machinator-dockerfiles/$1/Dockerfile

    #Build the container

    /bin/bash build.sh

    #Run the container!

    /bin/bash start.sh

    echo -e "Your container generated and running."
    echo -e "#####################################"
    echo -e "           MySQL User      : $2            "
    echo -e "           MySQL Password  : $MYSQL_DATABASE_PASSWORD "
    echo -e "           MySQL Database  : $2            "
    echo -e "           MySQL Server    : $DOCKER_MAIN_IP     "
    echo -e "#####################################"

    exit
}

check_sys(){

    if [[ $(id -u) -ne 0 ]] ; then echo "Please run as root" ; exit 1 ; fi

    if ( [[ "$1" =~ $PATTERN ]] && [[ "$2" =~ $PATTERN ]] ); then

        add_new_domain $1 $2

    else

        dialog  --screen-center --infobox "Invalid domainname or alias" 10 30 ; sleep 3
        exit

    fi
    exit
}

check_sys $1 $2
