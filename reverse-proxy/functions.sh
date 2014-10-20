#!/bin/bash
check_free_port(){

PORT=81


while true

do

    if (netstat -ln | grep ":$PORT " | grep "LISTEN" > /dev/null); then


        let "PORT++"


    else

        echo "$PORT";

        break;

    fi;
done
}


#add_new_domain subdomain.testserver.com subdomain

add_new_domain(){

if [[ $(id -u) -ne 0 ]] ; then echo "Please run as root" ; exit 1 ; fi

    SERVER_PORT=check_free_port

    cp templates/proxy.conf "$2".conf

    sed -i -e "s/DOMAIN/$1/g" "$2".conf

    sed -i -e "s/ALIAS/$2/g" "$2".conf

    sed -i -e "s/PORT/$SERVER_PORT/g" "$2".conf

    scp -i insecure_key "$2".conf root@$(docker inspect --format="{{ .NetworkSettings.IPAddress }}" machinator-reverse-proxy):/etc/nginx/conf.d/

    ssh -i insecure_key root@$(docker inspect --format="{{ .NetworkSettings.IPAddress }}" machinator-reverse-proxy) '/etc/init.d/nginx reload'

    rm -f "$2".conf



}
