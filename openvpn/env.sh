#!/usr/bin/env bash

SYSCTLCONFIG=/etc/sysctl.conf
OPENVPNDIR=/etc/openvpn
OPENVPNCONFIG=$OPENVPNDIR/openvpn-server.conf
CADIR=$OPENVPNDIR/easy-rsa
IPTABLES=/etc/iptables.rules
RCLOCAL=/etc/rc.local
NOBODYGROUP=nogroup

LOCALPREFIX="172.20"
LOCALIP="$LOCALPREFIX.0.0"
LOCALMASK="/24"

LOCALIPMASK="$LOCALIP$LOCALMASK"

IP=$(ip addr | grep 'inet' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -o -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1)
if [[ "$IP" = "" ]]; then
	IP=$(wget -4qO- "http://whatismyip.akamai.com/")
fi
