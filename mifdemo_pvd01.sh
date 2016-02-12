#!/bin/bash
service firewalld stop
service named restart
service httpd restart

./configure_pvd01.sh

IP_PVD="2001:db8:1111::1/64"
DEV="eno16777736"
RADVD_CONF="mif-radvd/radvd-pvd01.conf"

ip addr add $IP_PVD dev $DEV
./mif-radvd/radvd -C $RADVD_CONF -n -d 1 -m stderr

