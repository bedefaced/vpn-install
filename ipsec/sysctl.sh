#!/usr/bin/env bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $DIR/env.sh

if [[ ! -e $SYSCTLCONFIG ]] || [[ ! -r $SYSCTLCONFIG ]] || [[ ! -w $SYSCTLCONFIG ]]; then
    echo "$SYSCTLCONFIG is not exist or not accessible (are you root?)"
    exit 1
fi

sed -i -e "/net.ipv4.ip_forward/d" $SYSCTLCONFIG
echo "net.ipv4.ip_forward=1" >> $SYSCTLCONFIG

sed -i -e "/net.ipv4.conf.all.accept_redirects/d" $SYSCTLCONFIG
echo "net.ipv4.conf.all.accept_redirects=0" >> $SYSCTLCONFIG

sed -i -e "/net.ipv4.conf.all.send_redirects/d" $SYSCTLCONFIG
echo "net.ipv4.conf.all.send_redirects=0" >> $SYSCTLCONFIG

sed -i -e "/net.ipv4.conf.default.rp_filter/d" $SYSCTLCONFIG
echo "net.ipv4.conf.default.rp_filter=0" >> $SYSCTLCONFIG

sed -i -e "/net.ipv4.conf.default.accept_source_route/d" $SYSCTLCONFIG
echo "net.ipv4.conf.default.accept_source_route=0" >> $SYSCTLCONFIG

sed -i -e "/net.ipv4.conf.default.send_redirects/d" $SYSCTLCONFIG
echo "net.ipv4.conf.default.send_redirects=0" >> $SYSCTLCONFIG

sed -i -e "/net.ipv4.icmp_ignore_bogus_error_responses/d" $SYSCTLCONFIG
echo "net.ipv4.icmp_ignore_bogus_error_responses=1" >> $SYSCTLCONFIG

sysctl -p

cat /etc/sysctl.d/*.conf /etc/sysctl.conf | sysctl -e -p -
