#!/usr/bin/env bash

DEBIANPLATFORM="DEBIAN"
CENTOSPLATFORM="CENTOS"

if [ -n "$(. /etc/os-release; echo $NAME | grep -i Ubuntu)" -o -n "$(. /etc/os-release; echo $NAME | grep -i Debian)" ]; then
	PLATFORM=$DEBIANPLATFORM

	IPTABLES_PACKAGE="iptables"
	CRON_PACKAGE="cron"
	INSTALLER="apt-get -y install"
	UNINSTALLER="apt-get purge --auto-remove"
fi

if [ -n "$(. /etc/os-release; echo $NAME | grep -i CentOS)" ]; then
	PLATFORM=$CENTOSPLATFORM

	IPTABLES_PACKAGE="iptables-services"
	CRON_PACKAGE="cronie"
	INSTALLER="yum -y install"
	UNINSTALLER="yum remove"
fi

SYSCTLCONFIG=/etc/sysctl.conf
OPENVPNDIR=/etc/openvpn
OPENVPNCONFIG=$OPENVPNDIR/openvpn-server.conf
CADIR=$OPENVPNDIR/easy-rsa
IPTABLES=/etc/iptables.rules
NOBODYGROUP=nogroup
CHECKSERVER=$OPENVPNDIR/checkserver.sh
IPTABLES_COMMENT="OPENVPN"

if [ "$PLATFORM" == "$CENTOSPLATFORM" ]; then
	NOBODYGROUP=nobody
fi

LOCALPREFIX="172.20"
LOCALIP="$LOCALPREFIX.0.0"
LOCALMASK="/24"

LOCALIPMASK="$LOCALIP$LOCALMASK"

IP=$(ip addr | grep 'inet' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -o -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1)
if [[ "$IP" = "" ]]; then
	IP=$(wget -4qO- "http://whatismyip.akamai.com/")
fi
