#!/usr/bin/env bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $DIR/env.sh

if [ "$PLATFORM" == "$CENTOSPLATFORM" ]; then
	systemctl enable iptables
	systemctl stop firewalld
	systemctl disable firewalld
	systemctl start iptables
fi

if [ "$PLATFORM" == "$DEBIANPLATFORM" ]; then
	systemctl stop ufw
	systemctl disable ufw
fi

COMMENT=" -m comment --comment \"$IPTABLES_COMMENT\""

if [[ ! -e $IPTABLES ]]; then
	touch $IPTABLES
fi

if [[ ! -e $IPTABLES ]] || [[ ! -r $IPTABLES ]] || [[ ! -w $IPTABLES ]]; then
    echo "$IPTABLES is not exist or not accessible (are you root?)"
    exit 1
fi

# clear existing rules
iptables-save | awk '($0 !~ /^-A/)||!($0 in a) {a[$0];print}' > $IPTABLES
sed -i -e "/--comment $IPTABLES_COMMENT/d" $IPTABLES
iptables -F
iptables-restore < $IPTABLES

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
    eval iptables -t nat -A POSTROUTING -s $LOCALIPMASK -o $GATE -j SNAT --to-source $IP $COMMENT
else
    # MASQUERADE
    eval iptables -t nat -A POSTROUTING -o $GATE -j MASQUERADE $COMMENT
fi

DROP="yes"
read -p "Would you want to disable client-to-client routing? [yes] " ANSDROP
: ${ANSDROP:=$DROP}

if [ "$DROP" == "$ANSDROP" ]; then
    # disable forwarding
    eval iptables -I FORWARD -s $LOCALIPMASK -d $LOCALIPMASK -j DROP $COMMENT
else
    echo "Deleting DROP rule if exists..."
    eval iptables -D FORWARD -s $LOCALIPMASK -d $LOCALIPMASK -j DROP $COMMENT
fi

# Enable forwarding
eval iptables -A FORWARD -j ACCEPT $COMMENT

# MSS Clamping
eval iptables -t mangle -A FORWARD -p tcp -m tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu $COMMENT

# PPP
eval iptables -A INPUT -i ppp+ -j ACCEPT $COMMENT
eval iptables -A OUTPUT -o ppp+ -j ACCEPT $COMMENT

# PPTP
eval iptables -A INPUT -p tcp -m tcp --dport 1723 -j ACCEPT $COMMENT
eval iptables -A OUTPUT -p tcp -m tcp --sport 1723 -j ACCEPT $COMMENT

# GRE
eval iptables -A INPUT -p gre -j ACCEPT $COMMENT
eval iptables -A OUTPUT -p gre -j ACCEPT $COMMENT

# remove standard REJECT rules
echo "Note: standard REJECT rules for INPUT and FORWARD will be removed."
iptables -D INPUT -j REJECT --reject-with icmp-host-prohibited 2>/dev/null
iptables -D FORWARD -j REJECT --reject-with icmp-host-prohibited 2>/dev/null

iptables-save | awk '($0 !~ /^-A/)||!($0 in a) {a[$0];print}' > $IPTABLES
iptables -F
iptables-restore < $IPTABLES
