---
layout: post
title:  "openvpn deployment with Debian Stretch"
date:   2017-04-07 07:00 +0200
tags:	[debian, debian stretch, openvpn]
---

![Debian Openvpn][debian-openvpn]

Debian Stretch feels like an excellent release by the Debian project.
The final [stable release][release] is about to happen in the short term.

Among the great things you can do with Debian, you could set up a VPN using
the [openvpn][openvpn] software. 

In this blog post I will describe how I've deployed myself an openvpn server
using Debian Stretch, my network environment and my configurations & workflow.

<!--more-->

Before all, I would like to reference my requisites and the characteristics of
what I needed:

* a VPN server which allows internet clients to access our datacenter internal
network (intranet) securely
* strong authentications mechanisms for the users (user/password + client
certificate)
* the user/password information is stored in a LDAP server of the datacenter
* support for several (hundreds?) of clients
* only need to route certain subnets (intranet) through the VPN, not the entire
network traffic of the clients
* full IPv4 & IPv6 dual stack support, of course
* a group of system admins will perform changes to the configurations, adding
and deleting clients

I agree this is a rather complex scenario and not all the people will face
these requirements.

The service diagram has this shape:

![VPN diagram][vpn]
[_(DIA source file)_][dia]

So, it works like this:

1. clients connect via internet to our openvpn server, *vpn.example.com*
2. the openvpn server validates the connection and the tunnel is established (green)
3. now the client is virtually *inside* our network (blue)
4. the client wants to access some intranet resource, the tunnel traffic is NATed (red)

Our datacenter intranet is using public IPv4 addressing, but the VPN tunnels
use private IPv4 addresses. To don't mix public and private address NAT is used.
Obviously we don't want to invest public IPv4 addresses in our internal tunnels.
We don't have this limitations in IPv6, we could use public IPv6 addresses
within the tunnels. But we prefer sticking to a hard dual stack IPv4/IPv6
approach and also use private IPv6 addresses inside the tunnels and also NAT
the IPv6 from private to public.

This way, there are no differences in how IPv4 and IPv6 network are managed.

We follow this approach for the addressing:

* client 1 tunnel: 192.168.100.11, fd00:0:1::11
* client 1 public NAT: x.x.x.11, x:x::11
* client 2 tunnel: 192.168.100.12, fd00:0:1::12
* client 2 public NAT: x.x.x.12, x:x::12
* [...]

The NAT runs in the VPN server, since this is kind of a router. We use
[nftables][nft] for this task.

As the final win, I will describe how we manage all this configuration using
the git version control system. Using git we can track which admin made which
change. A git hook will deploy the files from the git repo itself to /etc/
so the services can read them.

The VPN server networking configuration is as follows (`/etc/network/interfaces`
file, adjust to your network environments):

```
auto lo
iface lo inet loopback

# main public IPv4 address of vpn.example.com
allow-hotplug eth0
iface eth0 inet static
        address x.x.x.4
        netmask 255.255.255.0
        gateway x.x.x.1

# main public IPv6 address of vpn.example.com
iface eth0 inet6 static
        address x:x:x:x::4
        netmask 64
        gateway x:x:x:x::1

# NAT Public IPv4 addresses (used to NAT tunnel of client 1)
auto eth0:11
iface eth0:11 inet static
        address x.x.x.11
        netmask 255.255.255.0

# NAT Public IPv6 addresses (used to NAT tunnel of client 1)
iface eth0:11 inet6 static
        address x:x:x:x::11
        netmask 64

# NAT Public IPv4 addresses (used to NAT tunnel of client 2)
auto eth0:12
iface eth0:12 inet static
        address x.x.x.12
        netmask 255.255.255.0

# NAT Public IPv6 addresses (used to NAT tunnel of client 2)
iface eth0:12 inet6 static
        address x:x:x:x::12
        netmask 64
```

Thanks to the amazing and tireless work of the **Alberto Gonzalez Iniesta**
(DD), the [openvpn package in debian is in very good shape][tracker], ready
to use.

In *vpn.example.com*, install the required packages:

```
% sudo aptitude install openvpn openvpn-auth-ldap nftables git sudo
```

Two git repositories will be used, one for the openvpn configuration and
another for nftables (the nftables config is described later):

```
% sudo mkdir -p /srv/git/vpn.example.com-nft.git
% sudo git init --bare /srv/git/vpn.example.com-nft.git
% sudo mkdir -p /srv/git/vpn.example.com-openvpn.git
% sudo git init --bare /srv/git/vpn.example.com-openvpn.git
% sudo chown -R :git /srv/git/*
% sudo chmod -R g+rw /srv/git/*
```

The repositories belong to the git group, a system group we create to let
systems admins operate the server using git:

```
% sudo addgroup --system git
% sudo adduser admin1 git
% sudo adduser admin2 git
```

For the openvpn git repository, we need at least this git hook
(file `/srv/git/vpn.example.com-openvpn.git/hooks/post-receive` with
execution permission):

```
#!/bin/bash

NAME="hooks/post-receive"
OPENVPN_ROOT="/etc/openvpn"
export GIT_WORK_TREE="$OPENVPN_ROOT"
UNAME=$(uname -n)

info()
{
        echo "${UNAME} ${NAME} $1 ..."
}

info "checkout latest data to $GIT_WORK_TREE"
sudo git checkout -f
info "cleaning untracked files and dirs at $GIT_WORK_TREE"
sudo git clean -f -d
```

For this hook to work, sudo permissions are required (file
`/etc/sudoers.d/openvpn-git`):

```
User_Alias      OPERATORS = admin1, admin2
Defaults        env_keep += "GIT_WORK_TREE"
 
OPERATORS       ALL=(ALL) NOPASSWD:/usr/bin/git checkout -f
OPERATORS       ALL=(ALL) NOPASSWD:/usr/bin/git clean -f -d
```

Please review this sudoers file to match your environment and security
requirements.

The openvpn package deploys several systemd services:

```
% dpkg -L openvpn | grep service
/lib/systemd/system/openvpn-client@.service
/lib/systemd/system/openvpn-server@.service
/lib/systemd/system/openvpn.service
/lib/systemd/system/openvpn@.service
```
We don't need all of them, we can use the simple `openvpn.service`:

```
% sudo systemctl edit --full openvpn.service
```

And put a content like this:

```
% systemctl cat openvpn.service
# /etc/systemd/system/openvpn.service
[Unit]
Description=OpenVPN server
Documentation=man:openvpn(8)
Documentation=https://community.openvpn.net/openvpn/wiki/Openvpn23ManPage
Documentation=https://community.openvpn.net/openvpn/wiki/HOWTO
 
[Service]
PrivateTmp=true
KillMode=mixed
Type=forking
ExecStart=/usr/sbin/openvpn --daemon ovpn --status /run/openvpn/%i.status 10 --cd /etc/openvpn --config /etc/openvpn/server.conf --writepid /run/openvpn/server.pid
PIDFile=/run/openvpn/server.pid
ExecReload=/bin/kill -HUP $MAINPID
WorkingDirectory=/etc/openvpn
ProtectSystem=yes
CapabilityBoundingSet=CAP_IPC_LOCK CAP_NET_ADMIN CAP_NET_BIND_SERVICE CAP_NET_RAW CAP_SETGID CAP_SETUID CAP_SYS_CHROOT CAP_DAC_READ_SEARCH CAP_AUDIT_WRITE
LimitNPROC=10
DeviceAllow=/dev/null rw
DeviceAllow=/dev/net/tun rw
 
[Install]
WantedBy=multi-user.target
```

We can move on now to configure nftables to perform the NATs.

First, it's good to load the NAT configuration at boot time, so you need a
service file like this (`/etc/systemd/system/nftables.service`): 

```
[Unit]
Description=nftables
Documentation=man:nft(8) http://wiki.nftables.org
 
[Service]
Type=oneshot
RemainAfterExit=yes
StandardInput=null
ProtectSystem=full
ProtectHome=true
WorkingDirectory=/etc/nftables.d
ExecStart=/usr/sbin/nft -f ruleset.nft
ExecReload=/usr/sbin/nft -f ruleset.nft
ExecStop=/usr/sbin/nft flush ruleset
 
[Install]
WantedBy=multi-user.target
```

The nftables git hooks are implemented as described in
[nftables managed with git][nftables-git]. We are interested in the git hooks:

(file `/srv/git/vpn.example.com-nft.git/hooks/post-receive`):

```
#!/bin/bash

NAME="hooks/post-receive"
NFT_ROOT="/etc/nftables.d"
RULESET="${NFT_ROOT}/ruleset.nft"
export GIT_WORK_TREE="$NFT_ROOT"
UNAME=$(uname -n)

info()
{
        echo "${UNAME} ${NAME} $1 ..."
}

info "checkout latest data to $GIT_WORK_TREE"
sudo git checkout -f
info "cleaning untracked files and dirs at $GIT_WORK_TREE"
sudo git clean -f -d

info "deploying new ruleset"
set -e
cd $NFT_ROOT && sudo nft -f $RULESET
info "new ruleset deployment was OK"
```

This hook moves our nftables configuration to `/etc/nftables.d` and then
applies it to the kernel. So a single commit changes the runtime configuration
of the server.

You could implement some QA using the git hook `update`, check
[this file!][update]

Remember, git hooks requires exec permissions to work.
Of course, you will need again a [sudo policy for these nft hooks][sudo].

Finally, we can start configuring both openvpn and nftables using git.
For the VPN you will require the configure the PKI side: server certificates,
and the CA signing your client's certificates. You can check [openvpn's own
documentation][pki] about this.

Your first commit for openvpn could be the `server.conf` file:

```
plugin		/usr/lib/openvpn/openvpn-plugin-auth-pam.so common-auth
mode		server
user		nobody
group		nogroup
port		1194
proto		udp6
daemon
comp-lzo
persist-key
persist-tun

tls-server
cert		/etc/ssl/private/vpn.example.com_pub.crt
key		/etc/ssl/private/vpn.example.com_priv.pem
ca		/etc/ssl/cacert/clients_ca.pem
dh		/etc/ssl/certs/dh2048.pem
cipher		AES-128-CBC

dev		tun
topology	subnet
server		192.168.100.0 255.255.255.0
server-ipv6	fd00:0:1:35::/64

ccd-exclusive
client-config-dir ccd
max-clients	100
inactive	43200
keepalive	10 360

log-append	/var/log/openvpn.log
status		/var/log/openvpn-status.log
status-version	1
verb		4
mute		20
```

Don't forget the `ccd/` directory. This directory contains a file per user
using the VPN service. Each file is named after the CN of the client
certificate:

```
# private addresses for client 1
ifconfig-push		192.168.100.11 255.255.255.0
ifconfig-ipv6-push	fd00:0:1::11/64

# routes to the intranet network
push "route-ipv6 x:x:x:x::/64"
push "route x.x.3.128 255.255.255.240"
```

```
# private addresses for client 2
ifconfig-push		192.168.100.12 255.255.255.0
ifconfig-ipv6-push	fd00:0:1::12/64

# routes to the intranet network
push "route-ipv6 x:x:x:x::/64"
push "route x.x.3.128 255.255.255.240"
```

You end with at leats these files in the openvpn git tree:

```
server.conf
ccd/CN=CLIENT_1
ccd/CN=CLIENT_2
```

Please note that if you commit a change to `ccd/`, the changes are read
at **runtime** by openvpn. In the other hand, changes to `server.conf` require
you to restart the openvpn service by hand.

Remember, the addressing is like this:

![Addressing][addr]
[_(DIA source file)_][addr-dia]

In the nftables git tree, you should put a ruleset like this (a single file
named `ruleset.nft` is valid):

```
flush ruleset
table ip nat {
	map mapping_ipv4_snat {
		type ipv4_addr : ipv4_addr
		elements = {	192.168.100.11 : x.x.x.11,
				192.168.100.12 : x.x.x.12 }
	}

	map mapping_ipv4_dnat {
		type ipv4_addr : ipv4_addr
		elements = {	x.x.x.11 : 192.168.100.11,
				x.x.x.12 : 192.168.100.12 }
	}

	chain prerouting {
		type nat hook prerouting priority -100; policy accept;
		dnat to ip daddr map @mapping_ipv4_dnat
	}

	chain postrouting {
		type nat hook postrouting priority 100; policy accept;
		oifname "eth0" snat to ip saddr map @mapping_ipv4_snat
	}
}
table ip6 nat {
	map mapping_ipv6_snat {
		type ipv6_addr : ipv6_addr
		elements = {	fd00:0:1::11 : x:x:x::11,
				fd00:0:1::12 : x:x:x::12 }
	}

	map mapping_ipv6_dnat {
		type ipv6_addr : ipv6_addr
		elements = {	x:x:x::11 : fd00:0:1::11,
				x:x:x::12 : fd00:0:1::12 }
	}

	chain prerouting {
		type nat hook prerouting priority -100; policy accept;
		dnat to ip6 daddr map @mapping_ipv6_dnat
	}

	chain postrouting {
		type nat hook postrouting priority 100; policy accept;
		oifname "eth0" snat to ip6 saddr map @mapping_ipv6_snat
	}
}
table inet filter {
	chain forward {
		type filter hook forward priority 0; policy accept;
		# some forwarding filtering policy, if required, for both IPv4 and IPv6
	}
}
```

Since the server is in fact routing packets between the tunnel and the public
network, we require forwarding enabled in sysctl:

```
net.ipv4.conf.all.forwarding = 1
net.ipv6.conf.all.forwarding = 1
```

Of course, the VPN clients will require a `client.conf` file which looks
like this:

```
client
remote vpn.example.com 1194
dev tun
proto udp
resolv-retry infinite
comp-lzo
verb 5
nobind
persist-key
persist-tun
user nobody
group nogroup
 
tls-client
ca      /etc/ssl/cacert/server_ca.crt
pkcs12  /home/user/mycertificate.p12
verify-x509-name vpn.example.com name
cipher AES-128-CBC
auth-user-pass
auth-nocache
```

Workflow for the system admins:

1. git clone the openvpn repo
2. modify ccd/ and server.conf
3. git commit the changes, push to the server
4. if server.conf was modified, restart openvpn
5. git clone the nftables repo
6. modify ruleset
7. git commit the changes, push to the server

Comments via email welcome!

[debian-openvpn]:	{{site.url}}/assets/debian-openvpn.png
[release]:		https://release.debian.org/
[openvpn]:		https://openvpn.net/index.php/open-source.html
[vpn]:			{{site.url}}/assets/vpn.png
[dia]:			{{site.url}}/assets/vpn.dia
[nft]:			https://wiki.nftables.org
[tracker]:		https://tracker.debian.org/pkg/openvpn
[pki]:			https://openvpn.net/index.php/open-source/documentation/howto.html#pki
[nftables-git]:		https://github.com/aborrero/nftables-managed-with-git
[update]:		https://github.com/aborrero/nftables-managed-with-git/blob/master/git_hooks/update
[sudo]:			https://github.com/aborrero/nftables-managed-with-git/blob/master/sudo_policy/nft-git
[addr-dia]:		{{site.url}}/assets/vpn-addresses.dia
[addr]:			{{site.url}}/assets/vpn-addresses.png
