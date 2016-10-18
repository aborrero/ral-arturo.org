---
layout: post
title:  "nftables in Debian Stretch"
date:   2016-10-17 15:30:00 +0200
tags:	[debian, nftables, netfilter]
---

![Debian - Netfilter][debian-netfilter]

The next Debian stable release is codenamed Stretch, which I would expect
to be [released in less than a year][stretch_release].

The Netfilter Project has been developing nftables for years now, and the
status of the framework has been improved to a good point: it's ready for
wide usage and adoption, even in high-demand production environments.

<!--more-->

The last released version of nft was 0.6, and the Debian package was updated
just a day after Netfilter announced it.

With the 0.6 version the software freamework reached a good state of maturity,
and I myself encourage users to migrate from iptables to nftables.

In case [you don't know about nftables][nftables_wiki] yet, here is a quick
reference:

 * it's the tool/framework meant to replace iptables (also ip6tables, arptables
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
 3. linux kernel: a least 4.7 is recommended

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

If you are running Debian Jessie and want to give a try, you can use
[nftables from jessie-backports][debian_wiki].

If you want to migrate your ruleset from iptables to nftables, good news.
There are some tools in place to help in the task of translating from
iptables to nftables, but that doesn't belong to this post :-)

![nft][nft]

The nano editor includes nft syntax highlighting.
What are you waiting for to use nftables?

[debian-netfilter]:	{{site.url}}/assets/debian-netfilter.png
[stretch_release]:	https://wiki.debian.org/DebianStretch
[nftables_wiki]:	https://wiki.nftables.org
[debian_wiki]:		https://wiki.debian.org/nftables
[nft]:			{{site.url}}/assets/nft.png
