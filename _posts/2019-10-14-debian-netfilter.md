---
layout: post
title:  "What to expect in Debian 11 Bullseye for nftables/iptables"
date:   2019-10-14 19:00 +0200
tags:	[debian, netfilter, nftables, iptables]
---

![Logo][netfilter]

Debian 11 codename Bullseye is already in the works. Is interesting to make
decision early in the development cycle to give people time to accommodate and
integrate accordingly, and this post brings you the latest update on the plans
for Netfilter software in Debian 11 Bullseye. Mind that Bullseye is expected
to be released somewhere in 2021, so still plenty of time ahead.

<!--more-->

The situation with the release of Debian 10 Buster is that iptables was using
by default the `-nft` backend and one must explicitly select `-legacy` in the
alternatives system in case of any problem. That was intended to help people
migrate from iptables to nftables. Now the question is what to do next.

Back in July 2019, I started an [email thread in the
debian-devel@lists.debian.org mailing lists][devel] looking for consensus on
lowering the archive priority of the iptables package in Debian 11 Bullseye.
My proposal is to drop iptables from `Priority: important` and promote nftables
instead.

In general, having such a priority level means the package is installed by
default in every single Debian installation. Given that we aim to deprecate
iptables and that starting with Debian 10 Buster iptables is not even using the
x_tables kernel subsystem but nf_tables, having such priority level seems
pointless and inconsistent. There was agreement, and I already made the changes
to both packages.

This is another step in deprecating iptables and welcoming nftables. But it
does not mean that iptables won't be available in Debian 11 Bullseye. If you
need it, you will need to use `aptitude install iptables` to download and
install it from the package repository.

The second part of my proposal was to promote [firewalld][firewalld] as the
default 'wrapper' for firewaling in Debian. I think this is in line with the
direction other distros are moving. It turns out `firewalld` integrates pretty
well with the system, includes a DBus interface and many system daemons (like
[libvirt][libvirt]) already has native integration with firewalld.
Also, I believe the days of creating custom-made scripts and hacks to handle
the local firewall may be long gone, and `firewalld` should be very helpful
here too.

[devel]:	https://lists.debian.org/debian-devel/2019/07/msg00332.html
[firewalld]:	https://firewalld.org/
[libvirt]:	https://www.libvirt.org/news.html#v5.1.0
[netfilter]:	{{site.url}}/assets/debian-netfilter.png
