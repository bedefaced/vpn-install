#!/usr/bin/env bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $DIR/env.sh

if [ "$PLATFORM" == "$CENTOSPLATFORM" ]; then
	systemctl enable iptables
	systemctl stop firewalld
	systemctl disable firewalld
	systemctl start iptables
fi

COMMENT=" -m comment --comment \"OPENVPN\""

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
ifconfig -a | sed 's/[: \t].*//;/^\(lo\|\)$/d'
echo
GATE=$(route | grep '^default' | grep -o '[^ ]*$')
read -p "Enter your external network interface: " -i $GATE -e GATE

STATIC="yes"
read -p "Your external IP is $IP. Is this IP static? [yes] " ANSIP
: ${ANSIP:=$STATIC}

if [ "$STATIC" == "$ANSIP" ]; then
    # SNAT
    sed -i -e "s@PUBLICIP@$IP@g" $OPENVPNCONFIG
    eval iptables -t nat -A POSTROUTING -s $LOCALIPMASK -o $GATE -j SNAT --to-source $IP $COMMENT
else
    # MASQUERADE
    sed -i -e "/PUBLICIP/d" $OPENVPNCONFIG
    eval iptables -t nat -A POSTROUTING -o $GATE -j MASQUERADE $COMMENT
fi

DROP="yes"
read -p "Would you want to disable client-to-client routing? [yes] " ANSDROP
: ${ANSDROP:=$DROP}

if [ "$DROP" == "$ANSDROP" ]; then
    # disable forwarding
    sed -i -e "/client-to-client/d" $OPENVPNCONFIG
    eval iptables -I FORWARD -s $LOCALIPMASK -d $LOCALIPMASK -j DROP $COMMENT
    eval iptables -A FORWARD -i tun+ -o tun+ -j DROP $COMMENT
    eval iptables -A FORWARD -i tap+ -o tap+ -j DROP $COMMENT
else
    echo "Deleting DROP rules if exists..."
    eval iptables -D FORWARD -s $LOCALIPMASK -d $LOCALIPMASK -j DROP $COMMENT
    eval iptables -D FORWARD -i tap+ -o tap+ -j DROP $COMMENT
    eval iptables -D FORWARD -i tun+ -o tun+ -j DROP $COMMENT
fi

# Enable forwarding
eval iptables -A FORWARD -j ACCEPT $COMMENT

# MSS Clamping
eval iptables -t mangle -A FORWARD -p tcp -m tcp --tcp-flags SYN,RST SYN -j TCPMSS  --clamp-mss-to-pmtu $COMMENT

# TUN/TAP
eval iptables -A INPUT -i tun+ -j ACCEPT $COMMENT
eval iptables -A OUTPUT -o tun+ -j ACCEPT $COMMENT

# OpenVPN
eval iptables -A INPUT -p udp -m udp --dport 1194 -j ACCEPT $COMMENT
eval iptables -A OUTPUT -p udp -m udp --sport 1194 -j ACCEPT $COMMENT

iptables-save | awk '($0 !~ /^-A/)||!($0 in a) {a[$0];print}' > $IPTABLES
iptables -F
iptables-restore < $IPTABLES
