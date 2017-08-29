#!/usr/bin/env bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $DIR/env.sh

if [[ ! -e $CHAPSECRETS ]] || [[ ! -r $CHAPSECRETS ]] || [[ ! -w $CHAPSECRETS ]]; then
    echo "$CHAPSECRETS is not exist or not accessible (are you root?)"
    exit 1
fi

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

	unset PASSWORD

	while [[ -z "$PASSWORD" ]];
	do
	    read -p "Enter password: " PASSWORD
	    echo
	done

	DELETED=0

	$DIR/checkuser.sh $LOGIN

	if [[ $? -eq 0 ]]; then
		NOTREM="no"
		read -p "User '$LOGIN' already exists. Do you want to remove existing user? [no] " ANSREM
		: ${ANSREM:=$NOTREM}

		if [ "$NOTREM" == "$ANSREM" ]; then
			unset LOGIN PASSWORD
			if [[ $# -gt 0 ]]; then
				# exit, if script is called with params
				ANSUSER=$NOTADDUSER
			else
				read -p "Would you want to add another user? [no] " ANSUSER
				: ${ANSUSER:=$NOTADDUSER}
				unset LOGIN
			fi
			continue
		else
			$DIR/deluser.sh $LOGIN
			DELETED=1
		fi
	fi

	echo -e "$LOGIN\t    *\t    $PASSWORD\t    *" >> $CHAPSECRETS

	if [ $DELETED -eq 0 ]; then
		echo "$CHAPSECRETS has been updated!"
	fi

	PSK=$(sed -n "s/^[^#]\+[[:space:]]\+PSK[[:space:]]\+\"\(.\+\)\"/\1/p" $SECRETSFILE)

	mkdir -p "$DIR/$LOGIN"
	DISTFILE=$DIR/$LOGIN/setup.sh
	cp -rf $DIR/setup.sh.dist "$DISTFILE"
	sed -i -e "s@_PSK_@$PSK@g" "$DISTFILE"
	sed -i -e "s@_SERVERLOCALIP_@$LOCALPREFIX.0.1@g" "$DISTFILE"

	DISTFILE=$DIR/$LOGIN/ipsec.conf
	cp -rf $DIR/ipsec.conf.dist "$DISTFILE"
	sed -i -e "s@LEFTIP@%any@g" "$DISTFILE"
	sed -i -e "s@LEFTPORT@%any@g" "$DISTFILE"
	sed -i -e "s@RIGHTIP@$IP@g" "$DISTFILE"
	sed -i -e "s@RIGHTPORT@1701@g" "$DISTFILE"

	DISTFILE=$DIR/$LOGIN/xl2tpd.conf
	cp -rf $DIR/client-xl2tpd.conf.dist "$DISTFILE"
	sed -i -e "s@REMOTEIP@$IP@g" "$DISTFILE"

	DISTFILE=$DIR/$LOGIN/options.xl2tpd
	cp -rf $DIR/client-options.xl2tpd.dist "$DISTFILE"
	sed -i -e "s@_LOGIN_@$LOGIN@g" "$DISTFILE"
	sed -i -e "s@_PASSWORD_@$PASSWORD@g" "$DISTFILE"

	cp -rf $DIR/connect.sh.dist "$DIR/$LOGIN/connect.sh"
	cp -rf $DIR/disconnect.sh.dist "$DIR/$LOGIN/disconnect.sh"

	chmod +x "$DIR/$LOGIN/setup.sh" "$DIR/$LOGIN/connect.sh" "$DIR/$LOGIN/disconnect.sh"

	USERNAME=${SUDO_USER:-$USER}
	chown -R $USERNAME:$USERNAME $DIR/$LOGIN/
	echo
	echo "Directory $DIR/$LOGIN with client-side installation script has been created."

	
	if [[ $# -eq 0 ]]; then
		echo
		read -p "Would you want to add another user? [no] " ANSUSER
		: ${ANSUSER:=$NOTADDUSER}
		unset LOGIN
	else
		ANSUSER=$NOTADDUSER
	fi
done
