#!/bin/bash

IP="2001:db8:1111::1/64"
DEV="eno16777736"
RADVD_CONF="mif-radvd/radvd-pvd01.conf"
WWW_INDEX="index-pvd01.html"

ip addr add $IP dev $DEV

cp named.conf /etc/named.conf
cp pvdtest.com.db /var/named/pvdtest.com.db
cp $WWW_INDEX /var/www/html/index.html

service firewalld stop
service named restart
service httpd restart

./mif-radvd/radvd -C $RADVD_CONF -n -d 1 -m stderr

