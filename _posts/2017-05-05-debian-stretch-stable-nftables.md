---
layout: post
title:  "New in Debian stable Stretch: nftables"
date:   2017-05-05 07:00 +0200
tags:	[debian, debian stretch, nftables]
---

![Debian Openvpn][debian-netfilter]

Debian Stretch stable includes the nftables framework, ready to use.
Created by the Netfilter project itself, nftables is the firewalling tool
that replaces the old iptables, giving the users a powerful tool.

Back in October 2016, I wrote a [small post about the status of ntables in
Debian Stretch][oldpost]. Since then, several things have improved even
further, so this clearly deserves a new small post :-)

<!--more-->

Yes, nftables **replaces** iptables. You are highly encouraged to migrate from
iptables to nftables.

The version of nftables in Debian stable Stretch is **v0.7**, and the kernel
couterpart is **v4.9**. This is clearly a very recent release of both
components. In the case of nftables, is the last released version by the time
of this writting.

Also, after the Debian stable release, both kernel and nftables will likely
get backports of future releases. Yes, you will be able to easily run a newer
release of the framework after the stable release.

In case you are migrating from iptables, you should know that there are some
tools in place to help you in this task. Please read the official netfilter
docs: [Moving from iptables to nftables][wiki-moving].

By the way, the nftables docs are extensive, check the [whole wiki][wiki].
In case you don't know about nftables yet, here is a quick reference:

 * it's the tool/framework that replaces iptables (also ip6tables, arptables
 and ebtables)
 * it integrates advanced structures which allow to arrange your ruleset for
 optimal performance
 * all the system is more configurable than in iptables
 * the syntax is much better than in iptables
 * several actions in a single rule
 * simplified IPv4/IPv6 dual stack
 * less kernel updates required
 * great support for incremental, dynamic and atomic ruleset updates

To run nftables in Debian Stretch you need several components:

 1. nft: the command line interface
 2. libnftnl: the nftables-netlink library
 3. linux kernel: a least 4.9 is recommended

A simple aptitude run will put your system ready to go, out of the box, with
nftables:

```
root@debian:~# aptitude install nftables
```

Once installed, you can start using the nft command:

```
root@debian:~# nft list ruleset
```

A good starting point is to copy a simple workstation firewall configuration:

```
root@debian:~# cp /usr/share/doc/nftables/examples/syntax/workstation /etc/nftables.conf
```

And load it:

```
root@debian:~# nft -f /etc/nftables.conf
```

Your nftables ruleset is now firewalling your network:

```
root@debian:~# nft list ruleset
table inet filter {
        chain input {
                type filter hook input priority 0;
                iif lo accept
                ct state established,related accept
                ip6 nexthdr icmpv6 icmpv6 type { nd-neighbor-solicit,  nd-router-advert, nd-neighbor-advert } accept
                counter drop
        }
}
```
Several examples can be found at `/usr/share/doc/nftables/examples/`.

A simple systemd service is included to load your ruleset at boot time, which
is disabled by default.

![nft][nft]

Did you know that the nano editor includes nft syntax highlighting?

Starting with Debian stable Stretch and nftables, packet filtering and network
policing will never be the same.

[debian-netfilter]:	{{site.url}}/assets/debian-netfilter.png
[oldpost]:		{{site.url}}/2016/10/17/nftables-debian-stretch.html
[tracker_nftables]:	https://tracker.debian.org/pkg/nftables
[tracker_linux]:	https://tracker.debian.org/pkg/linux
[wiki-moving]:		https://wiki.nftables.org/wiki-nftables/index.php/Moving_from_iptables_to_nftables
[wiki]:			https://wiki.nftables.org/
[nft]:			{{site.url}}/assets/nft.png
