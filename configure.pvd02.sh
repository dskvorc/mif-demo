#!/bin/bash

IP="2001:db8:2222:2222::1/64"
DEV="eno16777736"
DNS_ZONE="pvdtest.com.pvd02.db"
WWW_INDEX="index.pvd02.html"
RADVD_CONF="radvd.pvd02.conf"

ip addr add $IP dev $DEV

cp named.conf /etc/named.conf
cp $DNS_ZONE /var/named/pvdtest.com.db
cp $WWW_INDEX /var/www/html/index.html

service firewalld stop
service named restart
service httpd restart

../mif-radvd/radvd -C $RADVD_CONF -n -d 1 -m stderr
