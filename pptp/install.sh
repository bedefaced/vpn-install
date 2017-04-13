#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $DIR/env.sh

if [[ "$EUID" -ne 0 ]]; then
	echo "Sorry, you need to run this as root"
	exit 1
fi

echo
echo "Installing PPTP server..."
apt-get install pptpd

ADDUSER="no"
ANSUSER="yes"

echo
echo "Configuring VPN users..."
while [ "$ANSUSER" != "$ADDUSER" ]; 
do
	$DIR/adduser.sh

	read -p "Would you want add another user? [no] " ANSUSER
	: ${ANSUSER:=$ADDUSER}
done

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
echo "Starting pptpd..."
systemctl enable pptpd
service pptpd restart

IPTABLESRESTOR=$(which iptables-restore)
RESTORPRESENTS=$(grep iptables-restore $RCLOCAL)
if [ $? -ne 0 ]; then
	if [[ ! -z $IPTABLESRESTOR ]]; then
		sed -i -e "/exit 0/d" $RCLOCAL
		echo "$IPTABLESRESTOR < $IPTABLES" >> $RCLOCAL
		echo "exit 0" >> $RCLOCAL
	else
		echo "Cannot save iptables-restore from $IPTABLES to $RCLOCAL."
	fi
fi

echo
echo "Installation script completed!"

