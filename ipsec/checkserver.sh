#!/usr/bin/env bash

RET=$(pgrep xl2tpd)

if [ $? -eq 1 ]; then
	/etc/init.d/xl2tpd restart
fi

RET=$(pgrep starter)

if [ $? -eq 1 ]; then
	/etc/init.d/strongswan restart
fi
