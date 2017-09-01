# vpn-install
Simple PPTP, L2TP/IPsec, OpenVPN installers for fast, user-friendly deployment.

## Features
* PPTP, OpenVPN, IPsec VPN support
* User-friendly installation and configuration process
* VPN client-side configs and script generating 
* Backup and uninstallion support
* Users control (add, check, delete) scripts, autorestarting, iptables automation.

## Requirements
* Ubuntu (tested on Ubuntu 16.04, Ubuntu 17.04)
* Debian (tested on Debian 9)
* CentOS (tested on CentOS 7)

## Installation
Download: `git clone --depth=1 https://github.com/bedefaced/vpn-install.git`

And then some of (under *root* or using *sudo*):
* `vpn-install/pptp/install.sh`
* `vpn-install/openvpn/install.sh`
* `vpn-install/ipsec/install.sh`

These "wizards" will install required packages, generate necessary config files, update network configurations (to enable routing), add iptables rules, add cron jobs (for restarting servers, restoring iptables rules after reboot).

You will be answered for login-passwords of VPN users, some network information, preferred DNS-resolvers, client-to-client routing possibility.


## PPTP
Only MS-CHAP v2 with MPPE-128 encryption is allowed. 

Note that PPTP is **NOT** recommended for transmission secret data, because all strong PPTP authentication algorithms have been already hacked: see [link](https://isc.sans.edu/forums/diary/End+of+Days+for+MSCHAPv2/13807/) for more information.

By default (see [pptpd.conf.dist](https://github.com/bedefaced/vpn-install/blob/master/pptp/pptpd.conf.dist) and [env.sh](https://github.com/bedefaced/vpn-install/blob/master/pptp/env.sh)) it uses 172.16.0.0/24 subnet.

### Files
* [adduser.sh](https://github.com/bedefaced/vpn-install/blob/master/pptp/adduser.sh) - script for user-friendly chap-secrets file editing and client-side setup script generating.
* [autostart.sh](https://github.com/bedefaced/vpn-install/blob/master/pptp/autostart.sh) - script for adding cron jobs (iptables restoring after boot and server running state checking).
* [backup.sh](https://github.com/bedefaced/vpn-install/blob/master/pptp/backup.sh) - script for backuping system config files, parameters, services and packages statuses and uninstall script generating.
* [checkserver.sh](https://github.com/bedefaced/vpn-install/blob/master/pptp/checkserver.sh) - script for cron job, which check server running state.
* [checkuser.sh](https://github.com/bedefaced/vpn-install/blob/master/pptp/checkuser.sh) - script for user-friendly chap-secrets file existing user checking.
* [deluser.sh](https://github.com/bedefaced/vpn-install/blob/master/pptp/deluser.sh) - script for user-friendly chap-secrets file existing user removing.
* [dns.sh](https://github.com/bedefaced/vpn-install/blob/master/pptp/dns.sh) - script for user-friendly modifiying of DNS-resolver settings which will be pushed to Windows clients.
* [env.sh](https://github.com/bedefaced/vpn-install/blob/master/pptp/env.sh) - common for all scripts config variables (packet manager, subnet, ip, config files paths).
* [install.sh](https://github.com/bedefaced/vpn-install/blob/master/pptp/install.sh) - main installation script (wizard).
* [iptables-setup.sh](https://github.com/bedefaced/vpn-install/blob/master/pptp/iptables-setup.sh) - iptables configuration script.
* [options.pptp.dist](https://github.com/bedefaced/vpn-install/blob/master/pptp/options.pptp.dist) - [PPP options](https://ppp.samba.org/pppd.html) template.
* [pptpd.conf.dist](https://github.com/bedefaced/vpn-install/blob/master/pptp/pptpd.conf.dist) - [PPTPD config](https://www.freebsd.org/cgi/man.cgi?query=pptpd.conf&sektion=5&manpath=FreeBSD+8.0-RELEASE+and+Ports) template.
* [setup.sh.dist](https://github.com/bedefaced/vpn-install/blob/master/pptp/setup.sh.dist) - client-side connection installer script template.
* [sysctl.sh](https://github.com/bedefaced/vpn-install/blob/master/pptp/sysctl.sh) - script for set up IP forwarding and disabling some packets due to security reasons (using sysctl).

### Client
**On Linux:**

During VPN server installation (more precisely: during *adding user* procedure) it will generate client-side *setup.sh* script in *%username%* directory. Client-side setup script was tested on Ubuntu 16.04.

You can also use Ubuntu standard Network Manager for PPTP VPN connection.

**On Windows:**

Create new VPN-connection using standart 'Set up a new connection or network' wizard, select PPTP VPN and provide host, login and password information. In the 'Security' tab of created connection check only MS-CHAP v2 protocol.


## IPsec
IPsec over L2TP VPN server with pre-shared key. 

Only MS-CHAP v2 is allowed on L2TP. 

IPsec implementation: strongSwan.

L2TP implementation: xl2tpd.

By default (see [xl2tpd.conf.dist](https://github.com/bedefaced/vpn-install/blob/master/ipsec/xl2tpd.conf.dist) and [env.sh](https://github.com/bedefaced/vpn-install/blob/master/ipsec/env.sh)) it uses 172.18.0.0/24 subnet.

IKE encryption algorithms: see [ipsec.conf.dist](https://github.com/bedefaced/vpn-install/blob/master/ipsec/ipsec.conf.dist).

### Files
* [adduser.sh](https://github.com/bedefaced/vpn-install/blob/master/ipsec/adduser.sh) - script for user-friendly chap-secrets file editing and client-side setup script generating.
* [autostart.sh](https://github.com/bedefaced/vpn-install/blob/master/ipsec/autostart.sh) - script for adding cron jobs (iptables restoring after boot and server running state checking).
* [backup.sh](https://github.com/bedefaced/vpn-install/blob/master/ipsec/backup.sh) - script for backuping system config files, parameters, services and packages statuses and uninstall script generating.
* [checkserver.sh](https://github.com/bedefaced/vpn-install/blob/master/ipsec/checkserver.sh) - script for cron job, which check servers running state.
* [checkuser.sh](https://github.com/bedefaced/vpn-install/blob/master/ipsec/checkuser.sh) - script for user-friendly chap-secrets file existing user checking.
* [client-options.xl2tpd.dist](https://github.com/bedefaced/vpn-install/blob/master/ipsec/client-options.xl2tpd.dist) - client-side ppp connection template.
* [client-xl2tpd.conf.dist](https://github.com/bedefaced/vpn-install/blob/master/ipsec/client-xl2tpd.conf.dist) - client-side xl2tpd config template.
* [connect.sh.dist](https://github.com/bedefaced/vpn-install/blob/master/ipsec/connect.sh.dist) - client-side connect script template.
* [deluser.sh](https://github.com/bedefaced/vpn-install/blob/master/ipsec/deluser.sh) - script for user-friendly chap-secrets file existing user removing.
* [disconnect.sh.dist](https://github.com/bedefaced/vpn-install/blob/master/ipsec/disconnect.sh.dist) - client-side disconnect script template.
* [dns.sh](https://github.com/bedefaced/vpn-install/blob/master/ipsec/dns.sh) - script for user-friendly modifiying of DNS-resolver settings which will be pushed to Windows clients.
* [env.sh](https://github.com/bedefaced/vpn-install/blob/master/ipsec/env.sh) - common for all scripts config variables (subnet, ip, config files paths).
* [install.sh](https://github.com/bedefaced/vpn-install/blob/master/ipsec/install.sh) - main installation script (wizard).
* [ipsec.conf.dist](https://github.com/bedefaced/vpn-install/blob/master/ipsec/ipsec.conf.dist) - [IPsec (strongSwan) config](https://wiki.strongswan.org/projects/strongswan/wiki/ConnSection) file template.
* [iptables-setup.sh](https://github.com/bedefaced/vpn-install/blob/master/ipsec/iptables-setup.sh) - iptables configuration script.
* [options.xl2tpd.dist](https://github.com/bedefaced/vpn-install/blob/master/ipsec/options.xl2tpd.dist) - [PPP options](https://ppp.samba.org/pppd.html) template.
* [psk.sh](https://github.com/bedefaced/vpn-install/blob/master/ipsec/psk.sh) - script for user-friendly creating pre-shared key in [ipsec.secrets](https://linux.die.net/man/5/ipsec.secrets) file.
* [setup.sh.dist](https://github.com/bedefaced/vpn-install/blob/master/ipsec/setup.sh.dist) - client-side connection installer script template.
* [sysctl.sh](https://github.com/bedefaced/vpn-install/blob/master/ipsec/sysctl.sh) - script for set up IP forwarding and disabling some packets due to security reasons (using sysctl).
* [xl2tpd.conf.dist](https://github.com/bedefaced/vpn-install/blob/master/ipsec/xl2tpd.conf.dist) - [xl2tpd config](https://linux.die.net/man/5/xl2tpd.conf) file template.

### Client
**On Linux:**

During VPN server installation (more precisely: during *adding user* procedure) it will generate client-side *setup.sh* script in *%username%* directory with necessary config files and *connect.sh* and *disconnect.sh* scripts. Client-side scripts was tested on Ubuntu 16.04.

You can also use Ubuntu standard Network Manager for IPsec VPN connection if you install [network-manager-l2tp plugin](https://github.com/nm-l2tp/network-manager-l2tp).

**On Windows:**

Create new VPN-connection using standart 'Set up a new connection or network' wizard, select 'L2TP/IPsec with pre-shared key', provide host, login and password information.

In the 'Security' tab of created connection check only MS-CHAP v2 protocol, then enter to 'Advanced settings' and enter your pre-shared key.


## OpenVPN
Server and client certificates and TLS auth are used for authentication (generating using Easy-RSA package, see [adduser.sh](https://github.com/bedefaced/vpn-install/blob/master/openvpn/adduser.sh) and [install.sh](https://github.com/bedefaced/vpn-install/blob/master/openvpn/install.sh)).

Used cipher: AES-256-CBC (see [openvpn-server.conf.dist](https://github.com/bedefaced/vpn-install/blob/master/openvpn/openvpn-server.conf.dist)).

By default (see [openvpn-server.conf.dist](https://github.com/bedefaced/vpn-install/blob/master/openvpn/openvpn-server.conf.dist) and [env.sh](https://github.com/bedefaced/vpn-install/blob/master/openvpn/env.sh)) it uses 172.20.0.0/24 subnet.
Port 1194 (default).

### Files
* [adduser.sh](https://github.com/bedefaced/vpn-install/blob/master/openvpn/adduser.sh) - script for user-friendly client config and key+certificate generating.
* [autostart.sh](https://github.com/bedefaced/vpn-install/blob/master/openvpn/autostart.sh) - script for adding cron jobs (iptables restoring after boot and server running state checking).
* [backup.sh](https://github.com/bedefaced/vpn-install/blob/master/openvpn/backup.sh) - script for backuping system config files, parameters, services and packages statuses and uninstall script generating.
* [checkserver.sh](https://github.com/bedefaced/vpn-install/blob/master/openvpn/checkserver.sh) - script for cron job, which check server running state.
* [checkuser.sh](https://github.com/bedefaced/vpn-install/blob/master/openvpn/checkuser.sh) - script for user-friendly existing user checking.
* [deluser.sh](https://github.com/bedefaced/vpn-install/blob/master/openvpn/deluser.sh) - script for user-friendly existing user removing (certificate revoking).
* [dns.sh](https://github.com/bedefaced/vpn-install/blob/master/openvpn/dns.sh) - script for user-friendly modifiying of DNS-resolver settings which will be pushed to Windows clients.
* [env.sh](https://github.com/bedefaced/vpn-install/blob/master/openvpn/env.sh) - common for all scripts config variables (subnet, ip, config files paths).
* [install.sh](https://github.com/bedefaced/vpn-install/blob/master/openvpn/install.sh) - main installation script (wizard).
* [iptables-setup.sh](https://github.com/bedefaced/vpn-install/blob/master/openvpn/iptables-setup.sh) - iptables configuration script.
* [openvpn-server-embedded.ovpn.dist](https://github.com/bedefaced/vpn-install/blob/master/openvpn/openvpn-server-embedded.ovpn.dist) - client config file with embedded keys and certificates template.
* [openvpn-server.conf.dist](https://github.com/bedefaced/vpn-install/blob/master/openvpn/openvpn-server.conf.dist) - OpenVPN server [config file](https://openvpn.net/index.php/open-source/documentation/howto.html) template.
* [openvpn-server.ovpn.dist](https://github.com/bedefaced/vpn-install/blob/master/openvpn/openvpn-server.ovpn.dist) - client config file template.
* [sysctl.sh](https://github.com/bedefaced/vpn-install/blob/master/openvpn/sysctl.sh) - script for set up IP forwarding and disabling some packets due to security reasons (using sysctl).

### Client
**On Linux:**

During VPN server installation (more precisely: during *adding user* procedure) it will generate client-side configs in *%username%* directory.

Then simply:
```
apt-get install openvpn
openvpn --config config.ovpn
```

You can also use Ubuntu standard Network Manager for OpenVPN connection if you install [network-manager-openvpn-gnome plugin](https://askubuntu.com/questions/187511/how-can-i-use-a-ovpn-file-with-network-manager).


**On Windows:**

Download OpenVPV GUI client: [https://openvpn.net/index.php/open-source/downloads.html](https://openvpn.net/index.php/open-source/downloads.html).

Import config and connect, or run explorer context menu command.


## Uninstallation

During installation script will backup config files which are in system and will create uninstall script. So use some of (under *root* or using *sudo*):
* `vpn-install/pptp/uninstall/uninstall.sh`
* `vpn-install/openvpn/uninstall/uninstall.sh`
* `vpn-install/ipsec/uninstall/uninstall.sh`

These "wizards" will uninstall installed packages, restore system config files (which was before installation), remove added iptables  rules and cron jobs.
