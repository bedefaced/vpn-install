#!/usr/bin/env bash

STARTDIR=$(pwd)

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $DIR/env.sh

if [[ "$EUID" -ne 0 ]]; then
	echo "Sorry, you need to run this as root"
	exit 1
fi

echo
echo "Installing OpenVPN..."
apt-get install openvpn easy-rsa cron iptables procps

echo
echo "Configuring routing..."
$DIR/sysctl.sh

echo
echo "Installing configuration files..."
yes | cp -rf $DIR/openvpn-server.conf.dist $OPENVPNCONFIG

sed -i -e "s@CADIR@$CADIR@g" $OPENVPNCONFIG
sed -i -e "s@LOCALPREFIX@$LOCALPREFIX@g" $OPENVPNCONFIG
sed -i -e "s@NOBODYGROUP@$NOBODYGROUP@g" $OPENVPNCONFIG

echo
echo "Configuring iptables firewall..."
$DIR/iptables-setup.sh

echo
echo "Configuring DNS parameters..."
$DIR/dns.sh

echo
echo "Creating server keys..."
make-cadir $CADIR
cd $CADIR
source ./vars
./clean-all
./build-ca
./build-key-server --batch openvpn-server
./build-dh
openvpn --genkey --secret ta.key

cd $STARTDIR

echo
echo "Configuring VPN users..."
$DIR/adduser.sh

echo
echo "Adding cron jobs..."
yes | cp -rf $DIR/checkserver.sh $CHECKSERVER
$DIR/autostart.sh

echo
echo "Starting OpenVPN..."
systemctl enable openvpn
service openvpn restart

echo
echo "Installation script completed!"

