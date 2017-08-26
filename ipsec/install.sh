#!/usr/bin/env bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $DIR/env.sh

if [[ "$EUID" -ne 0 ]]; then
	echo "Sorry, you need to run this as root"
	exit 1
fi

echo
echo "Installing strongSwan and xl2tp server..."
if [ "$PLATFORM" == "$DEBIANPLATFORM" ]; then
	apt-get -y install strongswan xl2tpd cron iptables procps net-tools
fi
if [ "$PLATFORM" == "$CENTOSPLATFORM" ]; then
	yum -y install epel-release
	yum -y install strongswan xl2tpd cronie iptables-services procps net-tools
fi

echo
echo "Configuring routing..."
$DIR/sysctl.sh

echo
echo "Installing configuration files..."
yes | cp -rf $DIR/options.xl2tpd.dist $PPPCONFIG
yes | cp -rf $DIR/xl2tpd.conf.dist $XL2TPDCONFIG
yes | cp -rf $DIR/ipsec.conf.dist $IPSECCONFIG

sed -i -e "s@PPPCONFIG@$PPPCONFIG@g" $XL2TPDCONFIG
sed -i -e "s@LOCALPREFIX@$LOCALPREFIX@g" $XL2TPDCONFIG

sed -i -e "s@LOCALIPMASK@$LOCALIPMASK@g" $IPSECCONFIG

echo
echo "Configuring iptables firewall..."
$DIR/iptables-setup.sh

echo
echo "Configuring DNS parameters..."
$DIR/dns.sh

echo
echo "Configuring PSK..."
$DIR/psk.sh

echo
echo "Adding cron jobs..."
yes | cp -rf $DIR/checkserver.sh $CHECKSERVER
$DIR/autostart.sh

echo
echo "Configuring VPN users..."
$DIR/adduser.sh

echo
echo "Starting strongSwan and xl2tp..."
service xl2tpd restart
service strongswan restart

echo
echo "Installation script completed!"

