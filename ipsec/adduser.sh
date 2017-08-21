#!/usr/bin/env bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $DIR/env.sh

if [[ ! -e $CHAPSECRETS ]] || [[ ! -r $CHAPSECRETS ]] || [[ ! -w $CHAPSECRETS ]]; then
    echo "$CHAPSECRETS is not exist or not accessible (are you root?)"
    exit 1
fi

ADDUSER="no"
ANSUSER="yes"

while [ "$ANSUSER" != "$ADDUSER" ]; 
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
			continue
		else
			$DIR/deluser.sh $LOGIN
			DELETED=1
		fi
	fi

	echo -e "$LOGIN\t    *\t    $PASSWORD\t    *" >> $CHAPSECRETS

	if [ $DELETED -eq 0 ]; then
		echo "$CHAPSECRETS updated!"
	fi

	PSK=$(sed -n "s/^[^#]\+[[:space:]]\+PSK[[:space:]]\+\"\(.\+\)\"/\1/p" $SECRETSFILE)

	STARTDIR=$(pwd)

	mkdir "$STARTDIR/$LOGIN"
	DISTFILE=$STARTDIR/$LOGIN/setup.sh
	cp -rf setup.sh.dist "$DISTFILE"
	sed -i -e "s@_PSK_@$PSK@g" "$DISTFILE"
	sed -i -e "s@_SERVERLOCALIP_@$LOCALPREFIX.0.1@g" "$DISTFILE"

	DISTFILE=$STARTDIR/$LOGIN/ipsec.conf
	cp -rf ipsec.conf.dist "$DISTFILE"
	sed -i -e "s@LEFTIP@%any@g" "$DISTFILE"
	sed -i -e "s@LEFTPORT@%any@g" "$DISTFILE"
	sed -i -e "s@RIGHTIP@$IP@g" "$DISTFILE"
	sed -i -e "s@RIGHTPORT@1701@g" "$DISTFILE"

	DISTFILE=$STARTDIR/$LOGIN/xl2tpd.conf
	cp -rf client-xl2tpd.conf.dist "$DISTFILE"
	sed -i -e "s@REMOTEIP@$IP@g" "$DISTFILE"

	DISTFILE=$STARTDIR/$LOGIN/options.xl2tpd
	cp -rf client-options.xl2tpd.dist "$DISTFILE"
	sed -i -e "s@_LOGIN_@$LOGIN@g" "$DISTFILE"
	sed -i -e "s@_PASSWORD_@$PASSWORD@g" "$DISTFILE"

	cp -rf connect.sh.dist "$STARTDIR/$LOGIN/connect.sh"
	cp -rf disconnect.sh.dist "$STARTDIR/$LOGIN/disconnect.sh"

	chmod +x "$STARTDIR/$LOGIN/setup.sh" "$STARTDIR/$LOGIN/connect.sh" "$STARTDIR/$LOGIN/disconnect.sh"

	USERNAME=${SUDO_USER:-$USER}
	chown -R $USERNAME:$USERNAME $STARTDIR/$LOGIN/
	echo
	echo "Created directory $STARTDIR/$LOGIN with client-side installation file."

	
	if [[ $# -eq 0 ]]; then
		echo
		read -p "Would you want add another user? [no] " ANSUSER
		: ${ANSUSER:=$ADDUSER}
	else
		ANSUSER=$ADDUSER
	fi
done
