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

	mkdir -p "$DIR/$LOGIN"
	DISTFILE=$DIR/$LOGIN/setup.sh
	cp -rf $DIR/setup.sh.dist "$DISTFILE"
	sed -i -e "s@_LOGIN_@$LOGIN@g" "$DISTFILE"
	sed -i -e "s@_PASSWORD_@$PASSWORD@g" "$DISTFILE"
	sed -i -e "s@_REMOTEIP_@$IP@g" "$DISTFILE"
	sed -i -e "s@_LOCALPREFIX_@$LOCALPREFIX@g" "$DISTFILE"
	chmod +x "$DISTFILE"
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
