#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $DIR/env.sh

if [[ ! -e $IPTABLES ]]; then
	touch $IPTABLES
fi

if [[ ! -e $IPTABLES ]] || [[ ! -r $IPTABLES ]] || [[ ! -w $IPTABLES ]]; then
    echo "$IPTABLES is not exist or not accessible (are you root?)"
    exit 1
fi

# backup and remove rules with $LOCALIP
iptables-save > $IPTABLES.backup

IFS=$'\n'

iptablesclear=$(iptables -S -t nat | sed -n -e '/$LOCALPREFIX/p' | sed -e 's/-A/-D/g')
for line in $iptablesclear
do
    cmd="iptables -t nat $line"
    eval $cmd
done

# detect default gateway interface
echo "Found next network interfaces:"
ifconfig -a | sed 's/[ \t].*//;/^\(lo\|\)$/d'
echo
GATE=$(route | grep '^default' | grep -o '[^ ]*$')
read -p "Enter your external network interface: " -i $GATE -e GATE

STATIC="yes"
read -p "Your external IP is $IP. Is this IP static? [yes] " ANSIP
: ${ANSIP:=$STATIC}

if [ "$STATIC" == "$ANSIP" ]; then
    # SNAT
    sed -i -e "s@PUBLICIP@$IP@g" $OPENVPNCONFIG
    iptables -t nat -A POSTROUTING -s $LOCALIPMASK -o $GATE -j SNAT --to-source $IP
else
    # MASQUERADE
    sed -i -e "/PUBLICIP/d" $OPENVPNCONFIG
    iptables -t nat -A POSTROUTING -o $GATE -j MASQUERADE
fi

DROP="yes"
read -p "Would you want to disable client-to-client routing? [yes] " ANSDROP
: ${ANSDROP:=$DROP}

if [ "$DROP" == "$ANSDROP" ]; then
    # disable forwarding
    sed -i -e "/client-to-client/d" $OPENVPNCONFIG
    iptables -I FORWARD -s $LOCALIPMASK -d $LOCALIPMASK -j DROP
    iptables -A FORWARD -i tun+ -o tun+ -j DROP
    iptables -A FORWARD -i tap+ -o tap+ -j DROP
else
    echo "Deleting DROP rules if exists..."
    iptables -D FORWARD -s $LOCALIPMASK -d $LOCALIPMASK -j DROP
    iptables -D FORWARD -i tap+ -o tap+ -j DROP
    iptables -D FORWARD -i tun+ -o tun+ -j DROP
fi

# MSS Clamping
iptables -t mangle -A FORWARD -p tcp -m tcp --tcp-flags SYN,RST SYN -j TCPMSS  --clamp-mss-to-pmtu

# TUN/TAP
iptables -A INPUT -i tun+ -j ACCEPT
iptables -A INPUT -i tap+ -j ACCEPT
iptables -A OUTPUT -o tun+ -j ACCEPT
iptables -A OUTPUT -o tap+ -j ACCEPT

# OpenVPN
iptables -A INPUT -p udp --dport 1194 -j ACCEPT

iptables-save | awk '($0 !~ /^-A/)||!($0 in a) {a[$0];print}' > $IPTABLES

RESTORPRESENTS=$(grep iptables-restore $RCLOCAL)
if [ $? -ne 0 ]; then
	sed -i -e "/exit 0/d" $RCLOCAL
	echo "iptables-restore < $IPTABLES" >> $RCLOCAL
	echo "exit 0" >> $RCLOCAL
fi

iptables -F
iptables-restore < $IPTABLES

