---
layout:	post
title:	"Netfilter virtual workshop 2020 summary"
date:	2020-11-27 15:30 +0200
tags:	[netfilter]
---

![Netfilter logo][logo]

Once a year folks interested in Netfilter technologies gather together to discuss past, ongoing and
future works. The Netfilter Workshop is an opportunity to share and discuss new ideas, the state of
the project, bring people together to work & hack and to put faces to people who otherwise are just
email names. This is an event that [has been happening since at least 2001][nfws], so we are
talking about a genuine community thing here.

It was decided there would be an online format, split in 3 short meetings, once per week on
Fridays. I was unable to attend the first session on 2020-11-06 due to scheduling conflict, but I
made it to the sessions on 2020-11-13 and 2020-11-20. I would say the sessions were joined by about
8 to 10 people, depending on the day. This post is a summary with some notes on what happened in
this edition, with no special order.

<!--more-->

Pablo did the classical review of all the changes and updates that happened in all the Netfilter
project software components since last workshop. I was unable to watch this presentation, so I have
nothing special to comment. However, I've been following the development of the project very
closely, and there are several interesting things going on, some of them commented below.

Florian Westphal brought to the table status on some open/pending work for mptcp option matching,
systemd integration and finally interfacing from nft with cgroupv2. I was unable to participate in
the talk for the first two items, so I cannot comment a lot more. On the cgroupv2 side, several
options were evaluated to how to match them, identification methods, the hierarchical tree that
cgroups present, etc. We will have to wait a bit more to see how the final implementation looks
like.

Also, Florian presented his concerns on conntrack hash collisions. There are no real-world known
issues at the moment, but there is an [old paper][paper] that suggests we should keep and eye on
this and introduce improvements to prevent future DoS attack vectors. Florian mentioned
these attacks are not practical at the moment, but who knows in a few years. He wants to explore
introducing [RB trees][rbtree] for conntrack. It will probably be a rbtree structure of hash
tables in order to keep supporting parallel insertions. He was encouraged by others to go ahead and
play/explore with this.

Phil Sutter shared his past and future iptables development efforts. He highlighted fixed bugs and
his short/midterm TODO list. I know Phil has been busy lately fixing iptables-legacy/iptables-nft
incompatibilities. Basically addressing annoying bugs discovered by all ruleset managers out there
(kubernetes, docker, openstack neutron, etc). Lots of work has been done to improve the situation;
moreover I myself reported, or forwarded from the Debian bug tracker, several bugs. Anyway I was
unable to attend this talk, only learnt a few bits in the following sessions, so I don't have a lot
to comment here.

But when I was fully present, I was asked by Phil about the status of netfilter components in
Debian, and future plans. I shared my information. The idea for the next Debian stable release is
to don't include iptables in the installer, and [include nftables instead][debian]. Since Debian
Buster, nftables is  the default firewalling tool anyway. He shared the plans for the RedHat-related
ecosystem, and we were able to confirm that we are basically in sync.

Pablo commented on the latest Netfilter flowtable enhancements happening. Using the flowtable
infrastructure, one can create kernel network bypasses to speed up packet throughput. The latest
changes are aimed for bridge and VLAN enabled setups. The flowtable component will now know how
to bypass in these 2 network architectures as well as the previously supported ingress hook. This
is basically aimed for virtual machines and containers scenarios. There was some debate on use
cases and supported setups. I commented that a bunch of virtual machines connected to a classic
linux bridge and then doing NAT is basically what Openstack Neutron does, specifically in DVR
setups. Same can be found in some container-based environments. Early/simple benchmarks done by
Pablo suggest there could be huge performance improvements for those use cases.
There was some inevitable comparison of this approach to what others, like DPDK/XDP can do. A
point was raised about this being a more generic and operating system-integrated solution, which
should make it more extensible and easier to use.

![flowtable for bridges][flowtable]

Stefano Bravio commented on several open topics for nftables that he is interested on working on.
One of them, issues related to concatenations + vmap issues. He also addressed concerns with
people's expectations when migrating from ipset to nftables. There are several corner features in
ipset that aren't currently supported in nftables, and we should document them. Stefano is also
wondering about some tools to help in the migration. A translation layer like there is in place
for iptables. Eric Gaver commented there are a couple of semantics that will not be suitable for
translation, such as global sets, or sets of sets. But ipset is way simpler than iptables, so a
translation mechanism should probably be created. In any case, there was agreement that anything
that helps people migrate is more than welcome, even if it doesn't support 100% of the use cases.

Stefano is planning to write documentation in the [nftables wiki][wiki] on how the pipapo algorithm
works and the supported use cases. Other plans by Stefano include to work on some optimisations for
faster matches. He mentioned using architecture specific instruction to speed up sets operations,
like lookups.

Finally, he commented that some folks working with eBPF have showed interest in reusing some parts
of the nftables sets infrastructure (pipapo) because they have detected performance issues in their
own data structures in some cases. It is not clear how to best achieve it, how to better bridge the
two things together. Probably the ideal is to generalize the pipapo data structures and integrate
it into the generic bitmap library or something which can be used by anyone. Anyway, he hopes to
get some more time to focus on Netfilter stuff begining with the next year, in a couple of months.

Moving a bit away from the pure software development topics, Pablo commented on the
[netfilter.org][netfilter] infrastructure. Right now the servers are running on [gandi.net][gandi],
on virtual machines that are being basically donated to us. He pointed that the plan is to
simplify the infrastructure. For that reason, for example, FTP services has been shut down. Rsync
services have been shut down as well, so basically we no longer have a mirrors infrastructure. The
bugzilla and wikis we have need some attention, given they are old software pieces, and we need
to migrate them to be more modern. Finally, the new logo that was created was presented.

Later on, we spent a good chunk of the meeting discussing options on how to address the inevitable
iptables deprecation situation. There are some open questions, and we discussed several approaches.
From doing nothing at all, which means keeping the current status-quo, to setting a deadline date
for the deprecation like the python community did with python2. I personally like this deadline
idea, but it is perceived like a negative push by other. We all agree that the current 'do nothing'
approach is not sustainable either. Probably the way to go is basically to be more informative. We
need to clearly communicate that choosing iptables for anything in 2020 is a bad idea. There are
additional initiatives to help on this topic, without being too aggressive. A FAQ will probably be
introduced. Eric Garver suggested we should bring nftables front and center. Given the website
still mentions iptables everywhere, we will probably refresh the web content, introduce additional
informative banners and similar things.

There was an interesting talk on the topic of nft table ownership. The idea is to attach a table,
and all the child objects, to a process. Then, we prevent any modifications to the table or the
child objects by external entities. Basically, allocating and locking a table for a certain
netlink socket. This is a nice way for ruleset managers, like [firewalld][firewalld], to ensure
they have full control of what's happening to their ruleset, reducing the chances for ending with
an inconsistent configuration. There is a proof-of-concept patch by Pablo to support this, and Eric
mentioned he is pretty much interested in any improvements to support this use case.

The final time block in the final workshop day was dedicated to talk about the next workshop.
We are all very happy we could meet. Meeting virtually is way easier (and cheaper) than in person.
Perhaps we can make it online every 3 or 6 months instead of, or in addition to, one big annual
physical event. We will see what happens next year.


[nfws]:			https://workshop.netfilter.org/
[paper]:		https://www.eng.tau.ac.il/~yash/C2_039_Wool.pdf
[rbtree]:		https://en.wikipedia.org/wiki/Red%E2%80%93black_tree
[gandi]:		https://www.gandi.net
[netfilter]:		https://www.netfilter.org
[wiki]:			https://wiki.nftables.org
[logo]:			{{site.url}}/assets/netfilter-logo3.png
[debian]:		{{site.url}}/2019/10/14/debian-netfilter.html
[firewalld]:		https://firewalld.org/
[flowtable]:		{{site.url}}/assets/flowtable_bridge.png
