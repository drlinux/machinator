FROM 		phusion/baseimage:0.9.12

MAINTAINER 	Ibrahim Yılmaz (a.k.a dr.linux) <ibrahim@drlinux.org>

VOLUME ["/data/mysql"]

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


# Install MySQL server

RUN         echo "mysql-server mysql-server/root_password password root" | debconf-set-selections

RUN         echo "mysql-server mysql-server/root_password_again password root" | debconf-set-selections

ADD         etc/my_init.d/99_mysql_setup.sh /etc/my_init.d/99_mysql_setup.sh

RUN         chmod +x /etc/my_init.d/99_mysql_setup.sh

RUN         apt-get install -y mysql-server

RUN         sed -i -e "s/skip-networking/\#skip-networking/g" /etc/mysql/my.cnf

RUN         sed -i -e "s/bind-address/\#bind-address/g" /etc/mysql/my.cnf

# Install Services

RUN  		/etc/my_init.d/00_regen_ssh_host_keys.sh

RUN 		/usr/sbin/enable_insecure_key

ADD 		mysql.sh /etc/service/mysql/run

RUN 		chmod a+x /etc/service/mysql/run

# Clean

RUN 		apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN 		apt-get clean

RUN 		rm -rf /tmp/*

EXPOSE      3306	

CMD 		["/sbin/my_init", "--quiet"]
