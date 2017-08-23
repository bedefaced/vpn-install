#!/usr/bin/env bash

RET=$(pgrep pptpd)

if [ $? -eq 1 ]; then
	systemctl restart pptpd
fi
