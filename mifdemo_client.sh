#!/bin/bash
#ip addr add 2001:db8:1111::2/64 dev eno16777736
#service firewalld stop

#PVD01_IP="2001:db8:1111::1"
#PVD02_IP="2001:db8:2222::1"

#iptables -A OUTPUT -p udp -s 0/0 --sport 0 -d $PVD01_IP --dport 53 -m state --state NEW,ESTABLISHED -j ACCEPT
#iptables -A INPUT -p udp -s $PVD01_IP --sport 53 -d 0/0 --dport 0 -m state --state ESTABLISHED -j ACCEPT

#iptables -A OUTPUT -p udp -s 0/0 --sport 0 -d $PVD02_IP --dport 53 -m state --state NEW,ESTABLISHED -j ACCEPT
#iptables -A INPUT -p udp -s $PVD02_IP --sport 53 -d 0/0 --dport 0 -m state --state ESTABLISHED -j ACCEPT

