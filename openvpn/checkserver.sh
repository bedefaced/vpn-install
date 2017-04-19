#!/usr/bin/env bash

RET=$(pgrep openvpn)

if [ $? -eq 1 ]; then
	/etc/init.d/openvpn restart
fi
