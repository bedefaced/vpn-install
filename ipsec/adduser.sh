#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $DIR/env.sh

if [[ ! -e $CHAPSECRETS ]] || [[ ! -r $CHAPSECRETS ]] || [[ ! -w $CHAPSECRETS ]]; then
    echo "$CHAPSECRETS is not exist or not accessible (are you root?)"
    exit 1
fi

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

$DIR/checkuser.sh $LOGIN

if [[ $? -eq 0 ]]; then
	NOTREM="no"
	read -p "User '$LOGIN' already exists. Do you want to remove existing user? [no] " ANSREM
	: ${ANSREM:=$NOTREM}
	
	if [ "$NOTREM" == "$ANSREM" ]; then
		exit 1
	else
		$DIR/deluser.sh $LOGIN
		# to avoid dublicate message
		echo -e "$LOGIN\t    *\t    $PASSWORD\t    *" >> $CHAPSECRETS
		exit 0
	fi
fi

echo -e "$LOGIN\t    *\t    $PASSWORD\t    *" >> $CHAPSECRETS

echo "$CHAPSECRETS updated!"
