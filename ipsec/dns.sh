#!/usr/bin/env bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $DIR/env.sh

if [[ ! -e $PPPCONFIG ]] || [[ ! -r $PPPCONFIG ]] || [[ ! -w $PPPCONFIG ]]; then
    echo "$PPPCONFIG is not exist or not accessible (are you root?)"
    exit 1
fi

DEFAULTDNS1="8.8.8.8"
DEFAULTDNS2="8.8.4.4"

read -p "Preffered DNS resolver #1: " -e -i $DEFAULTDNS1 DNS1
: ${DNS1:=$DEFAULTDNS1}

read -p "Preffered DNS resolver #2: " -e -i $DEFAULTDNS2 DNS2
: ${DNS2:=$DEFAULTDNS2}

sed -i -e "/ms-dns/d" $PPPCONFIG

echo "ms-dns $DNS1" >> $PPPCONFIG
echo "ms-dns $DNS2" >> $PPPCONFIG

echo "$PPPCONFIG updated!"
