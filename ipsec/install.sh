#!/usr/bin/env bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $DIR/env.sh

if [[ "$EUID" -ne 0 ]]; then
	echo "Sorry, you need to run this as root"
	exit 1
fi

echo
echo "Creating backup..."
$DIR/backup.sh

echo
echo "Installing strongSwan and xl2tp server..."
eval $PCKTMANAGER update
if [ "$PLATFORM" == "$CENTOSPLATFORM" ]; then
	eval $INSTALLER epel-release
fi
eval $INSTALLER strongswan xl2tpd ppp $CRON_PACKAGE $IPTABLES_PACKAGE procps net-tools

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
echo "Installation script has been completed!"

