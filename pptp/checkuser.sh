#!/usr/bin/env bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $DIR/env.sh

if [[ ! -e $CHAPSECRETS ]] || [[ ! -r $CHAPSECRETS ]]; then
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

RET=$(grep -P "^$LOGIN\s+" $CHAPSECRETS)

exit $?
