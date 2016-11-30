---
layout: post
title:  "Creating a team for netfilter packages in debian"
date:   2016-11-30 07:00 +0200
tags:	[debian, netfilter]
---

![Debian - Netfilter][debian-netfilter]

There are about 15 Netfilter packages in Debian, and they are maintained
by separate people.

Yersterday, I contacted the maintainers of the main packages to propose
the creation of a **pkg-netfilter** team to maintain all the packages together.

<!--more-->

The benefits of maintaining packages in a team is already known to all, and
I would expect to rise the overall quality of the packages due to this
movement.

By now, the involved packages and maintainers are:

 * maintained or co-maintained by Laurence J. Lane:
   * [iptables][tracker-iptables]
   * [nfacct][tracker-nfacct]
   * [libnetfilter-acct][tracker-libnetfilter-acct]

 * maintained by Chris Boot:
   * [ulogd2][tracker-ulogd2]

 * maintained or co-maintained by Alexander Wirt:
   * [conntrack-tools][tracker-conntrack-tools]
   * [libnetfilter-conntrack][tracker-libnetfilter-conntrack]
   * [libnetfilter-cthelper][tracker-libnetfilter-cthelper]
   * [libnetfilter-cttimeout][tracker-libnetfilter-cttimeout]
   * [libnetfilter-log][tracker-libnetfilter-log]
   * [libnetfilter-queue][tracker-libnetfilter-queue]
   * [libnfnetlink][tracker-libnfnetlink]

 * maintained or co-maintained by Neutron Soutmun:
   * [ipset][tracker-ipset]
   * [libmnl][tracker-libmnl]

 * maintained or co-maintained by Anibal Monsalve Salazar:
   * [libmnl][tracker-libmnl]

 * maintained or co-maintained by myself:
   * [iptables][tracker-iptables]
   * [nftables][tracker-nftables]
   * [libnftnl][tracker-libnftnl]
   * [conntrack-tools][tracker-conntrack-tools]
   * [libnetfilter-conntrack][tracker-libnetfilter-conntrack]

We should probably ping Jochen Friedrich as well who maintains arptables
and ebtables. Also, there are some other non-official Netfilter packages, like
iptables-persistent. I'm undecided to what to do with them, as my primary
impulse is to only put in the team upstream packages.

Given the release of Stretch is just some months ahead, the creation of
this packaging team will happen after the release, so we don't have any hurry
moving things now.


[debian-netfilter]:			{{site.url}}/assets/debian-netfilter.png
[tracker-iptables]:			https://tracker.debian.org/pkg/iptables
[tracker-nftables]:			https://tracker.debian.org/pkg/nftables
[tracker-libnftnl]:			https://tracker.debian.org/pkg/libnftnl
[tracker-conntrack-tools]:		https://tracker.debian.org/pkg/conntrack-tools
[tracker-libnetfilter-conntrack]:	https://tracker.debian.org/pkg/libnetfilter-conntrack
[tracker-ulogd2]:			https://tracker.debian.org/pkg/ulogd2
[tracker-libnetfilter-cthelper]:	https://tracker.debian.org/pkg/libnetfilter-cthelper
[tracker-libnetfilter-cttimeout]:	https://tracker.debian.org/pkg/libnetfilter-cttimeout
[tracker-libnetfilter-log]:		https://tracker.debian.org/pkg/libnetfilter-log
[tracker-libnetfilter-queue]:		https://tracker.debian.org/pkg/libnetfilter-queue
[tracker-libnfnetlink]:			https://tracker.debian.org/pkg/libnfnetlink
[tracker-ipset]:			https://tracker.debian.org/pkg/ipset
[tracker-libmnl]:			https://tracker.debian.org/pkg/libmnl
[tracker-nfacct]:			https://tracker.debian.org/pkg/nfacct
[tracker-libnetfilter-acct]:		https://tracker.debian.org/pkg/libnetfilter-acct
[tracker-iptables-persistent]:		https://tracker.debian.org/pkg/iptables-persistent
