#!/bin/bash
if [[ $(id -u) -ne 0 ]] ; then echo "Please run as root" ; exit 1 ; fi
clear

docker rm -f "machinator-reverse-proxy" > /dev/null

docker run -i -d --name="machinator-reverse-proxy" -p 80:80 -t "machinator/nginx-reverse-proxy" > /dev/null

echo "Congrats! Reverse Proxy Container Successfully Started!";
