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
apt-get install openvpn easy-rsa

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
echo "Do you want to create routing or bridging OpenVPN mode? "
echo "More information at: https://community.openvpn.net/openvpn/wiki/309-what-is-the-difference-between-bridging-and-routing"
echo "    1) routing"
echo "    2) bridging"
echo
read -p "Your choice [1 or 2]: " -e -i 1 MODE
case $MODE in
	1)
	DEVICE="tun"
	sed -i -e "s/DEVICE/tun/g" $OPENVPNCONFIG
	sed -i -e "/server-bridge/d" $OPENVPNCONFIG
	;;
	2)
	DEVICE="tap"
	sed -i -e "s/DEVICE/tap/g" $OPENVPNCONFIG
	sed -i -e "/server /d" $OPENVPNCONFIG
	;;
	*)
	echo "Hm... Strange answer..."
	exit
	;;
esac

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

ADDUSER="no"
ANSUSER="yes"

echo
echo "Configuring VPN users..."
while [ "$ANSUSER" != "$ADDUSER" ]; 
do
	while [[ -z "$LOGIN" ]];
	do
	    read -p "Enter name: " LOGIN
	done

	./build-key --batch $LOGIN

	if [ $? -eq 0 ]; then

		# copy files and OVPN config
		mkdir "$STARTDIR/$LOGIN"
		cp $CADIR/keys/ca.crt $CADIR/keys/$LOGIN.key $CADIR/keys/$LOGIN.crt ta.key "$STARTDIR/$LOGIN/"

		DIST="$STARTDIR/$LOGIN/openvpn-server.ovpn"
		cp $DIR/openvpn-server.ovpn.dist $DIST
		sed -i -e "s@LOGIN@$LOGIN@g" $DIST
		sed -i -e "s@IP@$IP@g" $DIST
		sed -i -e "s@DEVICE@$DEVICE@g" $DIST

		SRC="$STARTDIR/$LOGIN"
		DIST="$STARTDIR/$LOGIN/openvpn-server-embedded.ovpn"
		cp $DIR/openvpn-server-embedded.ovpn.dist $DIST
		sed -i -e "s@IP@$IP@g" $DIST
		sed -i -e "s@DEVICE@$DEVICE@g" $DIST

		echo "<ca>" >> $DIST
		cat $SRC/ca.crt >> $DIST
		echo "</ca>" >> $DIST

		echo "<cert>" >> $DIST
		cat $SRC/$LOGIN.crt >> $DIST
		echo "</cert>" >> $DIST

		echo "<key>" >> $DIST
		cat $SRC/$LOGIN.key >> $DIST
		echo "</key>" >> $DIST

		echo "<tls-auth>" >> $DIST
		cat $SRC/ta.key >> $DIST
		echo "</tls-auth>" >> $DIST

		echo
		echo "Created directory $STARTDIR/$LOGIN with necessary files."
		chown -R ${USER:=$(/usr/bin/id -run)}:$USER $STARTDIR/$LOGIN/

	fi
	
	read -p "Would you want add another user? [no] " ANSUSER
	: ${ANSUSER:=$ADDUSER}
done

echo
echo "Starting OpenVPN..."
systemctl enable openvpn
service openvpn restart

echo
echo "Installation script completed!"

