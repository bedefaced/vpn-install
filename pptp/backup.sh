#!/usr/bin/env bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $DIR/env.sh

if [[ "$EUID" -ne 0 ]]; then
	echo "Sorry, you need to run this as root"
	exit 1
fi

UNINSTALLDIR="$DIR/uninstall"

if [[ -e "$UNINSTALLDIR" ]]; then
	echo "$UNINSTALLDIR exists. Skipping..."
	exit 0
fi

mkdir -p "$UNINSTALLDIR"

UNINSTALL_SCRIPT="$UNINSTALLDIR/uninstall.sh"

# backuping configs
yes | cp -rf $SYSCTLCONFIG "$UNINSTALLDIR/sysctl.conf" 2>/dev/null
yes | cp -rf $PPTPDCONFIG "$UNINSTALLDIR/pptpd.conf" 2>/dev/null
yes | cp -rf $PPTPOPTIONS "$UNINSTALLDIR/options.pptp" 2>/dev/null
yes | cp -rf $CHAPSECRETS "$UNINSTALLDIR/chap-secrets" 2>/dev/null

# restore system configuration
cat <<END >>$UNINSTALL_SCRIPT
#!/usr/bin/env bash

if [[ "\$EUID" -ne 0 ]]; then
	echo "Sorry, you need to run this as root"
	exit 1
fi

DIR=\$( cd "\$( dirname "\${BASH_SOURCE[0]}" )" && pwd )

echo "Removing cron task..."
TMPFILE=\$(mktemp crontab.XXXXX)
crontab -l > \$TMPFILE

sed -i -e "\@$IPTABLES@d" \$TMPFILE
sed -i -e "\@$CHECKSERVER@d" \$TMPFILE

crontab \$TMPFILE > /dev/null
rm \$TMPFILE

rm $CHECKSERVER

echo "Restoring sysctl parameters..."
cp -i \$DIR/sysctl.conf $SYSCTLCONFIG
sysctl -p
cat /etc/sysctl.d/*.conf /etc/sysctl.conf | sysctl -e -p -
END

# restore firewalls
cat <<END >>$UNINSTALL_SCRIPT

echo "Restoring firewall..."
iptables-save | awk '(\$0 !~ /^-A/)||!(\$0 in a) {a[\$0];print}' > $IPTABLES
sed -i -e "/--comment $IPTABLES_COMMENT/d" $IPTABLES
iptables -F
iptables-restore < $IPTABLES
rm $IPTABLES

END

if [ "$(systemctl status ufw; echo $?)" == "0" ]; then
	echo "systemctl enable ufw" >>$UNINSTALL_SCRIPT
	echo "systemctl start ufw" >>$UNINSTALL_SCRIPT
fi
if [ "$(systemctl status firewalld; echo $?)" == "0" ]; then
	echo "systemctl enable firewalld" >>$UNINSTALL_SCRIPT
	echo "systemctl start firewalld" >>$UNINSTALL_SCRIPT
fi
if [ "$PLATFORM" == "$CENTOSPLATFORM" ]; then
	# iptables
	if [ "$(systemctl status iptables; echo $?)" != "0" ]; then
		echo "systemctl stop iptables" >>$UNINSTALL_SCRIPT
		echo "systemctl disable iptables" >>$UNINSTALL_SCRIPT
	fi
fi

# remove packages
UNINST_PACKAGES=
if [[ ! -n "$(which pgrep)" ]]; then
	UNINST_PACKAGES+="procps "
fi
if [[ ! -n "$(which ifconfig)" ]]; then
	UNINST_PACKAGES+="net-tools "
fi
if [[ ! -n "$(which pppd)" ]]; then
	UNINST_PACKAGES+="ppp "
fi
if [[ ! -n "$(which pptpd)" ]]; then
	UNINST_PACKAGES+="pptpd "
fi
if [[ ! -n "$(which crontab)" ]]; then
	UNINST_PACKAGES+="$CRON_PACKAGE "
fi
if [[ ! -n "$(which iptables)" ]]; then
	UNINST_PACKAGES+="$IPTABLES_PACKAGE "
fi
if [ "$PLATFORM" == "$CENTOSPLATFORM" ]; then
	if [ "$(ls /etc/yum.repos.d/epel.repo 2>/dev/null; echo $?)" != "0" ]; then
		UNINST_PACKAGES+="epel-release "
	fi
fi
if [[ ! -z "$UNINST_PACKAGES" ]]; then	
	echo -e "echo \"Removing installed packages...\"" >>$UNINSTALL_SCRIPT
	echo "$UNINSTALLER $UNINST_PACKAGES" >>$UNINSTALL_SCRIPT
fi

# restore files
echo -e "echo \"Restoring configs...\"" >>$UNINSTALL_SCRIPT
if [[ -n "$(which pptpd)" ]]; then
	if [ -e "$DIR/pptpd.conf" ]; then
		echo -e "cp -i \"\$DIR/pptpd.conf\" $PPTPDCONFIG" >>$UNINSTALL_SCRIPT
	fi
fi
if [[ -n "$(which pppd)" ]]; then
	if [ -e "$DIR/options.pptp" ]; then
		echo -e "cp -i \"\$DIR/options.pptp\" $PPTPOPTIONS" >>$UNINSTALL_SCRIPT
	fi
	if [ -e "$DIR/chap-secrets" ]; then
		echo -e "cp -i \"\$DIR/chap-secrets\" $CHAPSECRETS" >>$UNINSTALL_SCRIPT
	fi
fi

# restore pptpd if necessary
if [ "$(systemctl status pptpd; echo $?)" == "0" ]; then
	echo -e "echo \"Restarting pptpd...\"" >>$UNINSTALL_SCRIPT
	echo "systemctl restart pptpd" >>$UNINSTALL_SCRIPT
fi

echo "echo" >>$UNINSTALL_SCRIPT
echo -e "echo \"Uninstall script has been completed!\"" >>$UNINSTALL_SCRIPT

chmod +x "$UNINSTALL_SCRIPT"
