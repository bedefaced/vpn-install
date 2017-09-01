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
echo "Installing PPTP server..."
eval $PCKTMANAGER update
if [ "$PLATFORM" == "$CENTOSPLATFORM" ]; then
	eval $INSTALLER epel-release
fi
eval $INSTALLER ppp pptpd $CRON_PACKAGE $IPTABLES_PACKAGE procps net-tools

ADDUSER="no"
ANSUSER="yes"

echo
echo "Configuring iptables firewall..."
$DIR/iptables-setup.sh

echo
echo "Configuring routing..."
$DIR/sysctl.sh

echo
echo "Installing configuration files for PPTP..."
yes | cp -rf $DIR/options.pptp.dist $PPTPOPTIONS
yes | cp -rf $DIR/pptpd.conf.dist $PPTPDCONFIG

sed -i -e "s@PPTPOPTIONS@$PPTPOPTIONS@g" $PPTPDCONFIG
sed -i -e "s@LOCALPREFIX@$LOCALPREFIX@g" $PPTPDCONFIG

echo
echo "Configuring DNS parameters..."
$DIR/dns.sh

echo
echo "Adding cron jobs..."
yes | cp -rf $DIR/checkserver.sh $CHECKSERVER
$DIR/autostart.sh

echo
echo "Configuring VPN users..."
$DIR/adduser.sh

echo
echo "Starting pptpd..."
service pptpd restart

echo
echo "Installation script has been completed!"

