#!/usr/bin/env bash

set -e


if [[ "$EUID" -ne 0 ]]; then
	echo "Sorry, you need to run this as root"
	exit 1
fi

ipsec up L2TP-PSK-NAT
sleep 2
echo "c L2TP-PSK-NAT" > /var/run/xl2tpd/l2tp-control     
sleep 2
