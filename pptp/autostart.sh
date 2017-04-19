#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $DIR/env.sh

if [[ "$EUID" -ne 0 ]]; then
	echo "Sorry, you need to run this as root"
	exit 1
fi

TMPFILE=$(mktemp crontab.XXXXX)
crontab -l > $TMPFILE

RESTOREPATH=$(which iptables-restore)
RESTORPRESENTS=$(grep iptables-restore $TMPFILE)
if [ $? -ne 0 ]; then
	echo "@reboot $RESTOREPATH <$IPTABLES >/dev/null 2>&1" >> $TMPFILE
fi

SERVERSPRESENTS=$(grep "$CHECKSERVER" $TMPFILE)
if [ $? -ne 0 ]; then
	echo "*/5 * * * * $CHECKSERVER >/dev/null 2>&1" >> $TMPFILE
fi

crontab $TMPFILE > /dev/null
rm $TMPFILE
