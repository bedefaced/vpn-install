#!/usr/bin/env bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $DIR/env.sh

if [[ ! -e $OPENVPNCONFIG ]] || [[ ! -r $OPENVPNCONFIG ]] || [[ ! -w $OPENVPNCONFIG ]]; then
    echo "$PPPCONFIG is not exist or not accessible (are you root?)"
    exit 1
fi

DEFAULTDNS1="8.8.8.8"
DEFAULTDNS2="8.8.4.4"

read -p "Preffered DNS resolver #1: " -e -i $DEFAULTDNS1 DNS1
: ${DNS1:=$DEFAULTDNS1}

read -p "Preffered DNS resolver #2: " -e -i $DEFAULTDNS2 DNS2
: ${DNS2:=$DEFAULTDNS2}

sed -i -e "/dhcp-option DNS/d" $OPENVPNCONFIG

echo "push \"dhcp-option DNS $DNS1\"" >> $OPENVPNCONFIG
echo "push \"dhcp-option DNS $DNS2\"" >> $OPENVPNCONFIG

echo "$OPENVPNCONFIG updated!"
