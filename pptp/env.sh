#!/usr/bin/env bash

DEBIANPLATFORM="DEBIAN"
CENTOSPLATFORM="CENTOS"

if [ -n "$(. /etc/os-release; echo $NAME | grep -i Ubuntu)" -o -n "$(. /etc/os-release; echo $NAME | grep -i Debian)" ]; then
	PLATFORM=$DEBIANPLATFORM

	IPTABLES_PACKAGE="iptables"
	CRON_PACKAGE="cron"
	PCKTMANAGER="apt-get"
	INSTALLER="$PCKTMANAGER -y install"
	UNINSTALLER="$PCKTMANAGER purge --auto-remove"
fi

if [ -n "$(. /etc/os-release; echo $NAME | grep -i CentOS)" ]; then
	PLATFORM=$CENTOSPLATFORM

	IPTABLES_PACKAGE="iptables-services"
	CRON_PACKAGE="cronie"
	PCKTMANAGER="yum"
	INSTALLER="$PCKTMANAGER -y install"
	UNINSTALLER="$PCKTMANAGER remove"
fi

SYSCTLCONFIG=/etc/sysctl.conf
PPTPDCONFIG=/etc/pptpd.conf
PPTPOPTIONS=/etc/ppp/options.pptp
CHAPSECRETS=/etc/ppp/chap-secrets
IPTABLES=/etc/iptables.rules
CHECKSERVER=/etc/ppp/checkserver.sh
IPTABLES_COMMENT="PPTP"

LOCALPREFIX="172.16"
LOCALIP="$LOCALPREFIX.0.0"
LOCALMASK="/24"

LOCALIPMASK="$LOCALIP$LOCALMASK"

IP=$(ip addr | grep 'inet' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -o -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1)
if [[ "$IP" = "" ]]; then
	IP=$(wget -4qO- "http://whatismyip.akamai.com/")
fi
