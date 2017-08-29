#!/usr/bin/env bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $DIR/env.sh

if [[ "$EUID" -ne 0 ]]; then
	echo "Sorry, you need to run this as root"
	exit 1
fi

if [[ $# -gt 0 ]]; then
    LOGIN="$1"
fi

while [[ -z "$LOGIN" ]];
do
    read -p "Enter name: " LOGIN
done

cd $CADIR
source ./vars

./revoke-full $LOGIN

cp -rf $CADIR/keys/crl.pem $OPENVPNDIR
chown nobody:$NOBODYGROUP $OPENVPNDIR/crl.pem
