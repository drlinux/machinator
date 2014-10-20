#!/bin/sh
export HOME="/root"
exec /etc/init.d/php5-fpm start > /dev/null 2>&1
