# nginx + PHP5.5-FPM on Docker
#
# VERSION               0.0.1

FROM 		phusion/baseimage:0.9.12

MAINTAINER 	Ibrahim Yılmaz (a.k.a dr.linux) <ibrahim@drlinux.org>

VOLUME ["/data/www"]

ENV 		HOME /root
# Set Language Environment

RUN 		apt-get install -y language-pack-en

ENV 		LANGUAGE en_US.UTF-8
ENV 		LANG en_US.UTF-8
ENV 		LC_ALL en_US.UTF-8
RUN 		locale-gen en_US.UTF-8
RUN 		dpkg-reconfigure locales

ENV 		DEBIAN_FRONTEND noninteractive

# Update packages
RUN apt-get update

# install curl, wget
RUN apt-get install -y curl wget git subversion imagemagick

# Configure repos
RUN apt-get install -y python-software-properties
RUN apt-get install -y vim
RUN add-apt-repository -y ppa:nginx/stable
RUN apt-get update

# Install nginx
RUN apt-get -y install nginx

# tell Nginx to stay foregrounded
RUN echo "daemon off;" >> /etc/nginx/nginx.conf

# Install PHP5 and modules
#

RUN add-apt-repository -y ppa:ondrej/php5
RUN apt-get update
RUN apt-get install -y --force-yes php5-fpm php5-mysql php-apc php5-mcrypt php5-curl php5-gd php5-json php5-cli
RUN sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php5/fpm/php-fpm.conf
RUN sed -i -e "s/short_open_tag = Off/short_open_tag = On/g" /etc/php5/fpm/php.ini

RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer

# Configure nginx for PHP websites
RUN echo "cgi.fix_pathinfo = 0;" >> /etc/php5/fpm/php.ini
RUN echo "max_input_vars = 10000;" >> /etc/php5/fpm/php.ini
RUN echo "date.timezone = Europe/Istanbul;" >> etc/php5/fpm/php.ini
RUN chown -R www-data:www-data /data/www

#  Install ioncube
RUN cd /usr/local
RUN wget http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz

RUN tar zxvf ioncube_loaders_lin_x86-64.tar.gz

RUN cp ioncube/ioncube_loader_lin_5.5.so /usr/lib/
RUN rm -rf /usr/share/nginx/html/

RUN  		/etc/my_init.d/00_regen_ssh_host_keys.sh

RUN 		/usr/sbin/enable_insecure_key

ADD 		nginx.sh /etc/service/nginx/run

ADD 		php5-fpm.sh /etc/service/php5-fpm/run

RUN 		chmod a+x /etc/service/nginx/run

RUN 		chmod a+x /etc/service/php5-fpm/run

