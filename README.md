# vpn-install
Simple PPTP, L2TP/IPsec, OpenVPN installers for fast, user-friendly deployment.

## Requirements
Tested only on Ubuntu 16.04. All packages will be installed from Ubuntu repository.

## Installation
Download: `git clone --depth=1 https://github.com/bedefaced/vpn-install.git`

And then some of (under root or using *sudo*):
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
* [adduser.sh](https://github.com/bedefaced/vpn-install/blob/master/pptp/adduser.sh) - script for user-friendly chap-secrets file editing.
* [autostart.sh](https://github.com/bedefaced/vpn-install/blob/master/pptp/autostart.sh) - script for adding cron jobs (iptables restoring after boot and server running state checking).
* [checkserver.sh](https://github.com/bedefaced/vpn-install/blob/master/pptp/checkserver.sh) - script for cron job, which check server running state.
* [checkuser.sh](https://github.com/bedefaced/vpn-install/blob/master/pptp/checkuser.sh) - script for user-friendly chap-secrets file existing user checking.
* [deluser.sh](https://github.com/bedefaced/vpn-install/blob/master/pptp/deluser.sh) - script for user-friendly chap-secrets file existing user removing.
* [dns.sh](https://github.com/bedefaced/vpn-install/blob/master/pptp/dns.sh) - script for user-friendly modifiying of DNS-resolver settings which will be pushed to Windows clients.
* [env.sh](https://github.com/bedefaced/vpn-install/blob/master/pptp/env.sh) - common for all scripts config variables (subnet, ip, config files paths).
* [install.sh](https://github.com/bedefaced/vpn-install/blob/master/pptp/install.sh) - main installation script (wizard).
* [iptables-setup.sh](https://github.com/bedefaced/vpn-install/blob/master/pptp/iptables-setup.sh) - iptables configuration script.
* [options.pptp.dist](https://github.com/bedefaced/vpn-install/blob/master/pptp/options.pptp.dist) - [PPP options](https://ppp.samba.org/pppd.html) template.
* [pptpd.conf.dist](https://github.com/bedefaced/vpn-install/blob/master/pptp/pptpd.conf.dist) - [PPTPD config](https://www.freebsd.org/cgi/man.cgi?query=pptpd.conf&sektion=5&manpath=FreeBSD+8.0-RELEASE+and+Ports) template.
* [sysctl.sh](https://github.com/bedefaced/vpn-install/blob/master/pptp/sysctl.sh) - script for set up IP forwarding and disabling some packets due to security reasons (using sysctl).

### Client
**On Linux:**

Use default Network Manager (if Ubuntu) VPN-connection creation wizard or set it up manually:

`apt-get install pptp`

Create a new file (for example) **/etc/ppp/peers/pptpserver** and add the following lines, replacing name and password with your own values:
```
pty "pptp [IP of VPN] --nolaunchpppd"
name [LOGIN]
remotename pptp
noauth
require-mppe-128
```
Add `[LOGIN] * [PASSWORD] *` line to **/etc/ppp/chap-secrets**.

then
`pppd call pptpserver` and `poff pptpserver` to close connection.

**On Windows:**

Create new VPN-connection using standart 'Set up a new connection or network' wizard, select PPTP VPN and provide host, login and password information. In the 'Security' tab of created connection check only MS-CHAP v2 protocol.


## IPsec
IPsec over L2TP VPN server with pre-shared key. 

Only MS-CHAP v2 is allowed on L2TP. 

IPsec implementation: strongSwan.

L2TP implementation: xl2tpd.

By default (see [xl2tpd.conf.dist](https://github.com/bedefaced/vpn-install/blob/master/ipsec/xl2tpd.conf.dist) and [env.sh](https://github.com/bedefaced/vpn-install/blob/master/ipsec/env.sh)) it uses 172.18.0.0/24 subnet.

IKE encryption algorithms: aes256-sha1, aes128-sha1, 3des-sha1. 

See [ipsec.conf.dist](https://github.com/bedefaced/vpn-install/blob/master/ipsec/ipsec.conf.dist) for more information.

### Files
* [adduser.sh](https://github.com/bedefaced/vpn-install/blob/master/ipsec/adduser.sh) - script for user-friendly chap-secrets file editing.
* [autostart.sh](https://github.com/bedefaced/vpn-install/blob/master/ipsec/autostart.sh) - script for adding cron jobs (iptables restoring after boot and server running state checking).
* [checkserver.sh](https://github.com/bedefaced/vpn-install/blob/master/ipsec/checkserver.sh) - script for cron job, which check servers running state.
* [checkuser.sh](https://github.com/bedefaced/vpn-install/blob/master/ipsec/checkuser.sh) - script for user-friendly chap-secrets file existing user checking.
* [deluser.sh](https://github.com/bedefaced/vpn-install/blob/master/ipsec/deluser.sh) - script for user-friendly chap-secrets file existing user removing.
* [dns.sh](https://github.com/bedefaced/vpn-install/blob/master/ipsec/dns.sh) - script for user-friendly modifiying of DNS-resolver settings which will be pushed to Windows clients.
* [env.sh](https://github.com/bedefaced/vpn-install/blob/master/ipsec/env.sh) - common for all scripts config variables (subnet, ip, config files paths).
* [install.sh](https://github.com/bedefaced/vpn-install/blob/master/ipsec/install.sh) - main installation script (wizard).
* [ipsec.conf.dist](https://github.com/bedefaced/vpn-install/blob/master/ipsec/ipsec.conf.dist) - [IPsec (strongSwan) config](https://wiki.strongswan.org/projects/strongswan/wiki/ConnSection) file template.
* [iptables-setup.sh](https://github.com/bedefaced/vpn-install/blob/master/ipsec/iptables-setup.sh) - iptables configuration script.
* [options.xl2tpd.dist](https://github.com/bedefaced/vpn-install/blob/master/ipsec/options.xl2tpd.dist) - [PPP options](https://ppp.samba.org/pppd.html) template.
* [psk.sh](https://github.com/bedefaced/vpn-install/blob/master/ipsec/psk.sh) - script for user-friendly creating pre-shared key in [ipsec.secrets](https://linux.die.net/man/5/ipsec.secrets) file.
* [sysctl.sh](https://github.com/bedefaced/vpn-install/blob/master/ipsec/sysctl.sh) - script for set up IP forwarding and disabling some packets due to security reasons (using sysctl).
* [xl2tpd.conf.dist](https://github.com/bedefaced/vpn-install/blob/master/ipsec/xl2tpd.conf.dist) - [xl2tpd config](https://linux.die.net/man/5/xl2tpd.conf) file template.

### Client
**On Linux:**

`apt-get install strongswan xl2tpd`

Download config files from server and follow [guide](https://smekkley.wordpress.com/2015/07/25/ipsec-over-l2tp-access-from-arch-linux-with-strongswan-and-xl2tpd/).

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
* [checkserver.sh](https://github.com/bedefaced/vpn-install/blob/master/openvpn/checkserver.sh) - script for cron job, which check server running state.
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

```
apt-get install openvpn
openvpn --config config.ovpn
```

**On Windows:**

Download OpenVPV GUI client: [https://openvpn.net/index.php/open-source/downloads.html](https://openvpn.net/index.php/open-source/downloads.html).

Import config and connect, or run explorer context menu command.

## TODO
* more testing
* support other OSs
* PPTP Linux client files autogenerating
* L2TP/IPsec Linux client files autogenerating
