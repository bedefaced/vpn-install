#!/usr/bin/env bash

RET=$(pgrep openvpn)

if [ $? -eq 1 ]; then
	systemctl restart openvpn@openvpn-server
fi
