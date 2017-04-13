#!/usr/bin/env bash

SYSCTLCONFIG=/etc/sysctl.conf
IPSECCONFIG=/etc/ipsec.conf
XL2TPDCONFIG=/etc/xl2tpd/xl2tpd.conf
PPPCONFIG=/etc/ppp/options.xl2tpd
CHAPSECRETS=/etc/ppp/chap-secrets
IPTABLES=/etc/iptables.rules
RCLOCAL=/etc/rc.local
SECRETSFILE=/etc/ipsec.secrets

LOCALPREFIX="172.18"
LOCALIP="$LOCALPREFIX.0.0"
LOCALMASK="/24"

LOCALIPMASK="$LOCALIP$LOCALMASK"
