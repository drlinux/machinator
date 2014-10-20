FROM 		phusion/baseimage:0.9.12

MAINTAINER 	Ibrahim Yılmaz (a.k.a dr.linux) <ibrahim@drlinux.org>

# Update Base System

RUN 		apt-get update
RUN 		apt-get -y upgrade

# Set Environment Variables

ENV 		HOME /root
# Set Language Environment

RUN 		apt-get install -y language-pack-en

ENV 		LANGUAGE en_US.UTF-8
ENV 		LANG en_US.UTF-8
ENV 		LC_ALL en_US.UTF-8
RUN 		locale-gen en_US.UTF-8
RUN 		dpkg-reconfigure locales
ENV 		DEBIAN_FRONTEND noninteractive

# Install Basic Packages

RUN 		apt-get install -y build-essential software-properties-common

RUN 		apt-get install -y wget curl git man unzip screen


# Clean

RUN 		apt-get install -y nginx-full 

RUN 		apt-get clean

RUN 		rm -rf /tmp/*

 

# Install Nginx Service

RUN 		apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN  		/etc/my_init.d/00_regen_ssh_host_keys.sh

RUN 		/usr/sbin/enable_insecure_key

ADD 		nginx-proxy.sh /etc/service/nginx/run

EXPOSE 		80

CMD 		["/sbin/my_init", "--quiet"]
