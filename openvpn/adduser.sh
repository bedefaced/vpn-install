#!/usr/bin/env bash

STARTDIR=$(pwd)

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $DIR/env.sh

if [[ "$EUID" -ne 0 ]]; then
	echo "Sorry, you need to run this as root"
	exit 1
fi

cd $CADIR
source ./vars

ADDUSER="no"
ANSUSER="yes"

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

		SRC="$STARTDIR/$LOGIN"
		DIST="$STARTDIR/$LOGIN/openvpn-server-embedded.ovpn"
		cp $DIR/openvpn-server-embedded.ovpn.dist $DIST
		sed -i -e "s@IP@$IP@g" $DIST

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
		USERNAME=${SUDO_USER:-$USER}
		chown -R $USERNAME:$USERNAME $STARTDIR/$LOGIN/

	fi
	
	read -p "Would you want add another user? [no] " ANSUSER
	: ${ANSUSER:=$ADDUSER}
done

