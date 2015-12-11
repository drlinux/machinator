#!/bin/bash
clear
if [[ $(id -u) -ne 0 ]] ; then echo "Please run as root" ; exit 1 ; fi
if [[$( docker rm nginx-reverse-proxy)]]; then echo "Old container removed"; fi
echo "Building docker image... Please be patient... This may take some time..."

docker build -t machinator/nginx-reverse-proxy .

curl -o insecure_key -fSL https://github.com/phusion/baseimage-docker/raw/master/image/insecure_key

chmod 600 insecure_key

echo "Runing the container"

docker run -d -i --name="machinator-reverse-proxy" -t machinator/nginx-reverse-proxy

docker stop machinator-reverse-proxy

echo " ./run.sh"
