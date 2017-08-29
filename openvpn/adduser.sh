#!/usr/bin/env bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $DIR/env.sh

if [[ "$EUID" -ne 0 ]]; then
	echo "Sorry, you need to run this as root"
	exit 1
fi

cd $CADIR
source ./vars

NOTADDUSER="no"
ANSUSER="yes"

while [ "$ANSUSER" != "$NOTADDUSER" ]; 
do
	if [[ $# -gt 0 ]]; then
	    LOGIN="$1"
	fi

	while [[ -z "$LOGIN" ]];
	do
	    read -p "Enter name: " LOGIN
	done

	$DIR/checkuser.sh $LOGIN

	if [[ $? -ne 0 ]]; then

		./build-key --batch $LOGIN

		if [ $? -eq 0 ]; then

			# copy files and OVPN config
			mkdir -p "$DIR/$LOGIN"
			cp $CADIR/keys/ca.crt $CADIR/keys/$LOGIN.key $CADIR/keys/$LOGIN.crt ta.key "$DIR/$LOGIN/"

			DIST="$DIR/$LOGIN/openvpn-server.ovpn"
			cp $DIR/openvpn-server.ovpn.dist $DIST
			sed -i -e "s@LOGIN@$LOGIN@g" $DIST
			sed -i -e "s@IP@$IP@g" $DIST

			SRC="$DIR/$LOGIN"
			DIST="$DIR/$LOGIN/openvpn-server-embedded.ovpn"
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
			echo "Directory $DIR/$LOGIN with necessary files has been created."
			USERNAME=${SUDO_USER:-$USER}
			chown -R $USERNAME:$USERNAME $DIR/$LOGIN/

		fi
	else
		echo "User $LOGIN already exists."
		unset LOGIN
	fi
	
	if [[ $# -eq 0 ]]; then
		echo
		read -p "Would you want to add another user? [no] " ANSUSER
		: ${ANSUSER:=$NOTADDUSER}
		unset LOGIN
	else
		ANSUSER=$NOTADDUSER
	fi
done

