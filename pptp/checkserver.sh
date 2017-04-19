#!/usr/bin/env bash

RET=$(pgrep pptpd)

if [ $? -eq 1 ]; then
	/etc/init.d/pptpd restart
fi
